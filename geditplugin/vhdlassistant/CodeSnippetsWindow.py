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


 
from gi.repository import GObject, Gtk, Gdk, GtkSource, Pango

from .PyVhdlUtil import CodeSnippetManager, CodeSnippet, CodeSnippetCategory

class CodeSnippetsWindow:
	
	def __init__(self, path_ui_file, csm, insert_snippet_callback = None):
		
		self.csm = csm
		self.insert_snippet_callback = insert_snippet_callback
		
		self.builder = Gtk.Builder()
		self.builder.add_objects_from_file(path_ui_file, ["windowCodeSnippets"])
		self.window = self.builder.get_object("windowCodeSnippets")
		self.preview_sourceview = GtkSource.View()
		self.preview_sourceview.modify_font(Pango.FontDescription("monospace"))
		
		placeholder = self.builder.get_object("placeholderSnippetPreviewTextview")
		placeholder.add(self.preview_sourceview)

		self.preview_sourcebuffer = GtkSource.Buffer()
		lm = GtkSource.LanguageManager()
		self.preview_sourcebuffer.set_language(lm.get_language("vhdl"))
		self.preview_sourcebuffer.set_text("--nothing selected");		
		
		ui_handlers = {"on_buttonCSWClipboard_clicked"         : self.on_insert_clipboard, 
		               "on_buttonCSWCursor_clicked"            : self.on_insert_cursor,
		               "on_buttonCSWNewFile_clicked"           : self.on_insert_new_file,
		               "on_buttonCSWCancel_clicked"            : self.on_cancel,
		               "on_windowCodeSnippets_delete_event"    : self.on_window_closing,
		               "on_treeviewCodeSnippets_row_activated" : self.on_row_selected}
		
		self.builder.connect_signals(ui_handlers)
		self.preview_sourceview.set_buffer(self.preview_sourcebuffer) 
	
		self.snippet_treeview = self.builder.get_object("treeviewCodeSnippets")
		
		self.current_selection = -1
		self.current_index = 0
		self.snippet_list = []
		treestore = Gtk.TreeStore(str, int)
		self.create_treestore(treestore, None, csm.snippets)
		self.snippet_treeview.set_model(treestore)
		self.snippet_treeview.expand_all()
		
		
		
	def show(self):
		self.window.show_all()

	def create_treestore(self, treestore, piter, snippet_category):
		
		for subcategory in snippet_category.subcategories:
			piter_new = treestore.append(piter, [subcategory.name, -1])
			self.create_treestore(treestore, piter_new, subcategory)
	
		for snippet in snippet_category.snippets :
			treestore.append(piter, [snippet.name, self.current_index])
			self.snippet_list.append(snippet)
			self.current_index += 1 
			
	#callbacks
	
	def on_row_selected(self, treeview, path, column):
		model = treeview.get_model()
		iterator = model.get_iter(path)
		selected_index = model.get_value(iterator, 1)
		if (selected_index != -1):
			#print("Value: "+str(selected_index));
			self.preview_sourcebuffer.set_text( self.csm.format_sippet_content(self.snippet_list[selected_index].content ))
			self.current_selection = selected_index
	
	def on_insert_clipboard(self, widget):
		if (self.insert_snippet_callback != None and self.current_selection != -1):
			self.insert_snippet_callback(self.csm.format_sippet_content(self.snippet_list[self.current_selection].content ), 0)
			self.window.hide()
			
	def on_insert_cursor(self, widget):
		if (self.insert_snippet_callback != None and self.current_selection != -1):
			self.insert_snippet_callback(self.csm.format_sippet_content(self.snippet_list[self.current_selection].content ), 2)
			self.window.hide()
	
	def on_insert_new_file(self, widget):
		if (self.insert_snippet_callback != None and self.current_selection != -1):
			self.insert_snippet_callback(self.csm.format_sippet_content(self.snippet_list[self.current_selection].content ), 1)
			self.window.hide()
	
	def on_cancel(self, widget):
		self.window.hide()
	
	def on_window_closing(self, widget, data):
		self.window.hide()
		return True # to prevent the window from beeing destroyed


