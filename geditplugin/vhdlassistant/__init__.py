#   (C) 2014 Florian Huemer	
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>



from gi.repository import GObject, Gtk, Gdk, Gedit, GtkSource
import subprocess
import re
import sys, traceback
import os
import configparser
import random #TODO: TEST ONLY
from .PyVhdlUtil import VhdlEntity, CodeGenerator, VhdlParser, search_for_potential_clock_names, CodeSnippetManager, CodeSnippet, CodeSnippetCategory
from .PluginCFGWindow import PluginCFGWindow
from .CodeSnippetsWindow import CodeSnippetsWindow


#TODO:
# map the status of the treeview map_expanded_rows()

class vhdlassistant(GObject.Object, Gedit.WindowActivatable):
	__gtype_name__ = "vhdlassistant"
	window = GObject.property(type=Gedit.Window)

	def __init__(self):
		GObject.Object.__init__(self)
		self.path_ui_file = os.path.dirname(os.path.realpath(__file__))+"/ui.glade"
		self.vhdl_parser = VhdlParser();

	def do_activate(self):
		# load configuration
		self.load_cfg()
		self.register_handlers()
		
		
		self.pluginCFGWindow = PluginCFGWindow(self.path_ui_file, self.on_cfg_changed)
	
		self.codeSnippetsWindow = None # lacy loading
		
		#load side panel
		builder = Gtk.Builder()
		builder.add_objects_from_file(self.path_ui_file, ["sidepanel"])
		
		self.sidepanel_ui = builder.get_object("sidepanel")
		self.code_hierarchy_treeview = builder.get_object("treeviewCodeHierarchy")
		
		
		ui_handlers = { "onRowActivated":self.on_row_activated, 
		                "onTreeviewButtonRelease":self.on_treeview_keyevent,
		                "onSidepanelCFGButtonClicked":self.on_cfg_button_clicked,
		                "onToolbuttonAddCodeSnippetClicked":self.onToolbuttonAddCodeSnippetClicked }
		builder.connect_signals(ui_handlers)
		
		
		self.gedit_side_panel = self.window.get_side_panel()
		
		if(isinstance(self.gedit_side_panel, Gtk.Stack)): # version 3.14 or higher
			self.gedit_side_panel.add_titled(self.sidepanel_ui, "VHDLAssistant", "VHDLAssistant")
			self.gedit_side_panel.set_visible_child (self.sidepanel_ui)
			print("i'm here")
		else:
			self.icon = Gtk.Image.new_from_stock(Gtk.STOCK_YES, Gtk.IconSize.MENU)
			self.gedit_side_panel.add_item(self.sidepanel_ui, "side_panel_ui", "VHDL Assistant", self.icon)
		
		self.sidepanel_ui.show_all()
		self.gedit_side_panel.show_all()
		
		
		#create snippets menu
		snippetmenu = Gtk.Menu()
		self.csm = CodeSnippetManager(use_uppercase_keywords=self.use_uppercase_keywords, tab_size=self.tab_size, use_spaces=self.use_spaces)
		
#		item_open = Gtk.MenuItem("Open")
#		snippetmenu.append(item_open)

		self.create_snippet_menu(snippetmenu, self.csm.snippets)

		snippetmenu.show_all()
		
		snippetbutton = builder.get_object("toolbuttonAddCodeSnippet")
		snippetbutton.set_menu(snippetmenu)
		
		#load context menus
		builder = Gtk.Builder()
		builder.add_objects_from_file(self.path_ui_file, ["menuEntity", "menuComponent"])
		self.entity_context_menu = builder.get_object("menuEntity")
		self.component_context_menu = builder.get_object("menuComponent")
		builder.connect_signals(
		{"menuitemEntityTestbenchActivated":self.on_entity_testbench_activated,
		"menuitemEntityPackageActivated":self.on_entity_package_activated,
		"menuitemEntityInstanceActivated":self.on_entity_instance_activated,
		"menuitemEntityComponentActivated":self.on_entity_component_activated,
		"menuitemComponentInstanceActivated":self.on_component_instance_activated})
		
		
		#handle the already existing documents
		for doc in self.window.get_documents():
			self.update_document_vhdl_info(doc); 

		active_document = self.window.get_active_document()
		self.set_side_panel_ui(active_document)

	#Code Snippets Code
	def create_snippet_menu(self, gtkmenu, category):
		
		for c in category.subcategories :
			category_menu_item = Gtk.MenuItem(c.name)
			category_submenu = Gtk.Menu()
			self.create_snippet_menu(category_submenu, c)
			category_menu_item.set_submenu(category_submenu)
			gtkmenu.append(category_menu_item)
			
		for s in category.snippets :
			snippet_menu_item = Gtk.MenuItem(s.name)
			snippet_menu_item.code_snippet = s
			snippet_menu_item.connect("activate", self.on_code_snippet_menu_clicked )
			gtkmenu.append(snippet_menu_item)

	def on_code_snippet_menu_clicked(self, widget):
		tab = self.window.create_tab(True) 
		snippet_content = widget.code_snippet.content;
		snippet_content = self.csm.format_sippet_content(snippet_content)
		tab.get_document().insert_at_cursor(snippet_content) 
		lm = GtkSource.LanguageManager()
		tab.get_document().set_language(lm.get_language("vhdl"))
	
	def on_insert_snippet(self, content, destination):
		
		if (destination == 0):
			self.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
			self.clipboard.set_text(content, -1)
		elif(destination == 1):
			tab = self.window.create_tab(True) 
			tab.get_document().insert_at_cursor(content) 
			lm = GtkSource.LanguageManager()
			tab.get_document().set_language(lm.get_language("vhdl"))
		elif(destination == 2):
			tab = self.window.get_active_document().insert_at_cursor(content) 
		else:
			print("Error")
			
	def onToolbuttonAddCodeSnippetClicked(self, widget):
		if ( self.codeSnippetsWindow == None ):
			self.codeSnippetsWindow = CodeSnippetsWindow(self.path_ui_file, self.csm, self.on_insert_snippet)
		
		self.codeSnippetsWindow.show()

	def do_deactivate(self):
		self.store_cfg()
		self.remove_handlers()
		
		if(isinstance(self.gedit_side_panel, Gtk.Stack)):
			self.gedit_side_panel.remove(self.sidepanel_ui)
		else:
			self.gedit_side_panel.remove_item(self.sidepanel_ui)
		print("do_deactivate")
		

	def do_update_state(self):
		pass
	
	
	def on_cfg_button_clicked(self, widget):
		self.pluginCFGWindow.use_spaces = self.use_spaces
		self.pluginCFGWindow.use_uppercase_keywords = self.use_uppercase_keywords
		self.pluginCFGWindow.tab_size = self.tab_size
		self.pluginCFGWindow.auto_show_sidepanel = self.auto_show_sidepanel
		self.pluginCFGWindow.show()
	
	def on_cfg_changed(self, cfg_window):
		self.use_spaces = cfg_window.use_spaces
		self.use_uppercase_keywords = cfg_window.use_uppercase_keywords
		self.tab_size = cfg_window.tab_size
		self.auto_show_sidepanel = cfg_window.auto_show_sidepanel
		
		self.csm.use_spaces = self.use_spaces
		self.csm.use_uppercase_keywords = self.use_uppercase_keywords
		self.csm.tab_size = self.tab_size
	
	def register_handlers(self):
		self.handlers = []
		handler_id = self.window.connect("tab-added", self.on_tab_added)
		self.handlers.append(handler_id)
		#print("Connected handler " + str(handler_id) )

		handler_id = self.window.connect("tab-removed", self.on_tab_removed)
		self.handlers.append(handler_id)
		#print("Connected handler " + str(handler_id) )

		handler_id = self.window.connect("active-tab-changed", self.on_active_tab_changed)
		self.handlers.append(handler_id)
		#print("Connected handler " + str(handler_id) )

		handler_id = self.window.connect("active-tab-state-changed", self.on_active_tab_state_changed)
		self.handlers.append(handler_id)
		#print("Connected handler " + str(handler_id) )

	def remove_handlers(self) :
		handlers = self.handlers
		for handler_id in self.handlers :
			self.window.disconnect(handler_id)
			#print( "Disconnected handler " + str(handler_id))

	def set_side_panel_ui(self, document):
		print("set_side_panel_ui")
		if(document != None ) : 
			print("document != None")
			if(document.is_vhdl_file == True):
				print("document.is_vhdl_file == True")
				self.code_hierarchy_treeview.set_model(document.code_hierarchy_treestore)
				self.code_hierarchy_treeview.expand_all()
				self.sidepanel_ui.show_all()
				if(self.auto_show_sidepanel == True):
					self.activate_sidepanel()
			else:
				print("document.is_vhdl_file == False")
				self.sidepanel_ui.hide()
		else:
			self.sidepanel_ui.hide()

	#handlers
	def on_tab_added(self, window, tab, data=None) :
		print("on_tab_added")
		doc = tab.get_document()
		
		doc.remove_source_marks (doc.get_start_iter(), doc.get_end_iter(), "vhdl") 
		tab.get_view().set_show_line_marks(True)
		mark_attributes = GtkSource.MarkAttributes()
		mark_attributes.set_stock_id(Gtk.STOCK_CANCEL)
		mark_attributes.connect("query_tooltip_text", self.tooltip_callback )
		tab.get_view().set_mark_attributes("vhdl", mark_attributes, 1) 
		
		
		doc.connect("saved", self.on_document_saved);
		self.update_document_vhdl_info(doc)
		self.set_side_panel_ui(doc);

	
	def on_tab_removed(self, window, tab, data=None) :
		#print("on_tab_removed")
		#print("active document is now "+str(self.window.get_active_document()))
		
		active_document = self.window.get_active_document()
		self.set_side_panel_ui(active_document)


	#called when the selected/active/current tab changed
	def on_active_tab_changed(self, window, tab, data=None) :
		print("on_active_tab_changed");
		active_document = self.window.get_active_document()
		self.set_side_panel_ui(active_document)

	#called when
	# >> active tab is saved
	# >> a file is opened in the current tab (the current tab is a empty unsaved document)
	def on_active_tab_state_changed(self, window, data=None) :
		#print("on_active_tab_state_changed");
		active_document = self.window.get_active_document()
		self.update_document_vhdl_info(active_document)
		self.set_side_panel_ui(active_document)


	def on_document_saved(self, document, error=None) :
		print("on_document_saved");
		self.update_document_vhdl_info(document);
		#self.set_side_panel_ui(document)
	
	# row was double-clicked in treeview --> jump to line
	def on_row_activated(self, treeview, path, column):
		model = treeview.get_model()
		iterator = model.get_iter(path)
		
		document = self.window.get_active_document()
		document.goto_line(model.get_value(iterator, 2)-1);
		self.window.get_active_view().scroll_to_cursor()

	def on_treeview_keyevent(self, widget, event):
		if ( event.button == 3 ):
			(model, pathlist) = widget.get_selection().get_selected()
			#print(str(model.get_value(pathlist, 0))+"  "+str(model.get_value(pathlist, 1)))
			if (str(model.get_value(pathlist, 0)) == "Entity"):
				self.temp_entity_name = str(model.get_value(pathlist, 1)) 
				self.entity_context_menu.popup(parent_menu_shell=None, parent_menu_item=None, func=None, button=event.button, activate_time=event.time, data=None)
				self.entity_context_menu.show_all()
			elif (str(model.get_value(pathlist, 0)) == "Comp."):
				self.temp_component_name = str(model.get_value(pathlist, 1))
				self.component_context_menu.popup(parent_menu_shell=None, parent_menu_item=None, func=None, button=event.button, activate_time=event.time, data=None)
				self.component_context_menu.show_all()
			else:
				print("something else selected")
	

	def update_document_vhdl_info(self, document):
		print("update_document_vhdl_info")
		lang_name = ""
		if (document.get_language() != None) :
			print("document.get_language() != None") # the bug is here. document.get_language() returns None 
			lang_name = document.get_language().get_name();
		if (lang_name == "VHDL") :
			print("lang_name == \"VHDL\"")
			if (document.is_untitled ()):
				print("file untitled")
				document.code_hierarchy_treestore = None
				document.is_vhdl_file = True
			else:
				try:
					path = document.get_location().get_path()
					code_hierarchy = self.vhdl_parser.get_code_hierarchy_from_file(path)
					treestore = Gtk.TreeStore(str, str, int)
					self.create_treestore(treestore, None, code_hierarchy)
					document.code_hierarchy_treestore = treestore
					self.create_source_marks(document, self.vhdl_parser.get_error_list());
					document.is_vhdl_file = True
				except:
					exc_type, exc_value, exc_traceback = sys.exc_info()
					dialog = Gtk.MessageDialog(self.window);
					dialog.set_markup(""+repr(traceback.format_exception(exc_type, exc_value, exc_traceback)))
					dialog.run()
					dialog.destroy()
		else :
			document.code_hierarchy_treestore = None
			document.is_vhdl_file = False
		
	def create_treestore(self, treestore, piter, code_hierarchy):
		
		if (code_hierarchy ==  None):
			return
		
		for code_hierarchy_entry in code_hierarchy:
			piter_new = treestore.append(piter, [code_hierarchy_entry.entry_type, code_hierarchy_entry.name, code_hierarchy_entry.line])
			self.create_treestore(treestore, piter_new, code_hierarchy_entry.childeren)
		
	
	def create_source_marks(self, document, error_list) :
		document.remove_source_marks (document.get_start_iter(), document.get_end_iter(), "vhdl") 
		
		for error in error_list :
			text_iter = document.get_iter_at_line(error.line-1);
			src_mark = document.create_source_mark(None, "vhdl", text_iter);
			src_mark.error_message = error.text
		
		
	def tooltip_callback(self, data, mark) :
		return mark.error_message;
	
	def activate_sidepanel(self):
		if(isinstance(self.gedit_side_panel, Gtk.Stack)):
			self.gedit_side_panel.set_visible_child (self.sidepanel_ui)
			print(""+self.gedit_side_panel.get_visible_child_name())
		else:
			self.gedit_side_panel.activate_item(self.sidepanel_ui)

	############################################################################
	# Load/store configuration
	############################################################################
	def load_cfg(self):
		cfg_file_name = os.path.expanduser("~/.local/share/gedit/plugins/vhdlassistant_cfg.ini")
	
		self.use_spaces = True
		self.tab_size = 2
		self.use_uppercase_keywords = False
		self.auto_show_sidepanel = True
	
		#check if there already exists a configuration file
		if ( os.path.isfile(cfg_file_name) ) :
			try:
				config = configparser.ConfigParser()
				config.read(cfg_file_name)
				self.use_spaces = config['code_generator'].getboolean('use_spaces')
				self.use_uppercase_keywords = config['code_generator'].getboolean('use_uppercase_keywords')
				self.tab_size = int(config['code_generator']['tab_size'])
				self.auto_show_sidepanel = config['plugin_behavior'].getboolean('auto_show_sidepanel')
				#print("use_spaces: "+str(self.use_spaces)+" use_uppercase_keywords"+str(self.use_uppercase_keywords) +"  tab_size: "+str(self.tab_size))
			except:
				print("error reading config file")


	def store_cfg(self):
		cfg_file_name = os.path.expanduser("~/.local/share/gedit/plugins/vhdlassistant_cfg.ini")
		config = configparser.ConfigParser()
		config['code_generator'] = {}
		config['code_generator']['use_spaces'] = str(self.use_spaces)
		config['code_generator']['tab_size'] = str(self.tab_size)
		config['code_generator']['use_uppercase_keywords'] = str(self.use_uppercase_keywords)
		config['plugin_behavior'] = {}
		config['plugin_behavior']['auto_show_sidepanel'] = str(self.auto_show_sidepanel)
		try:
			with open(cfg_file_name, "w") as configfile:
				config.write(configfile)
		except:
			print("error storing config file")
			
	############################################################################
	# Sidepanel treeview context menu callbacks
	############################################################################
	
	def on_entity_testbench_activated(self, widget):
		path = self.window.get_active_document().get_location().get_path()
		entity = self.vhdl_parser.get_entity_from_file(path, self.temp_entity_name)
		
		clk_signals = search_for_potential_clock_names(entity)
	
		#configure cg
		cg = CodeGenerator(use_uppercase_keywords=self.use_uppercase_keywords, use_spaces=self.use_spaces, tab_size=self.tab_size)
		 
		tab = self.window.create_tab(True) 
		tab.get_document().insert_at_cursor(cg.gen_testbench(entity, clk_signals)) #generate code
		lm = GtkSource.LanguageManager()
		tab.get_document().set_language(lm.get_language("vhdl"))

	def on_entity_package_activated(self, widget):
		path = self.window.get_active_document().get_location().get_path()
		entity = self.vhdl_parser.get_entity_from_file(path, self.temp_entity_name)
		
		#configure cg
		cg = CodeGenerator(use_uppercase_keywords=self.use_uppercase_keywords, use_spaces=self.use_spaces, tab_size=self.tab_size)
		 
		tab = self.window.create_tab(True) 
		tab.get_document().insert_at_cursor(cg.gen_package_with_component_declaration(entity)) #generate code
		lm = GtkSource.LanguageManager()
		tab.get_document().set_language(lm.get_language("vhdl"))
	
	def on_entity_instance_activated(self, widget):
		path = self.window.get_active_document().get_location().get_path()
		entity = self.vhdl_parser.get_entity_from_file(path, self.temp_entity_name)
		
		#configure cg
		cg = CodeGenerator(use_uppercase_keywords=self.use_uppercase_keywords, use_spaces=self.use_spaces, tab_size=self.tab_size)
		inst_str = cg.gen_instance_simple(self.temp_entity_name+"_inst", entity)

		self.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
		self.clipboard.set_text(inst_str, -1)

	def on_entity_component_activated(self, widget):
		path = self.window.get_active_document().get_location().get_path()
		entity = self.vhdl_parser.get_entity_from_file(path, self.temp_entity_name)
		
		cg = CodeGenerator(use_uppercase_keywords=self.use_uppercase_keywords, use_spaces=self.use_spaces, tab_size=self.tab_size)
		
		component_str = cg.gen_component(entity, "")
		self.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
		self.clipboard.set_text(component_str, -1)
		
	def on_component_instance_activated(self, widget):
		path = self.window.get_active_document().get_location().get_path()
		component = self.vhdl_parser.get_component_from_file(path, self.temp_component_name)
		
		cg = CodeGenerator(use_uppercase_keywords=self.use_uppercase_keywords, use_spaces=self.use_spaces, tab_size=self.tab_size)
		inst_str = cg.gen_instance_simple(self.temp_component_name+"_inst", component)

		self.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
		self.clipboard.set_text(inst_str, -1)

