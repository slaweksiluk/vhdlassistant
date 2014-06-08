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


class PluginCFGWindow:
	
	def __init__(self, path_ui_file, cfg_changed_callback=None):
		self.builder = Gtk.Builder()
		self.builder.add_objects_from_file(path_ui_file, ["windowPluginCFG", "frameVHDLCodeSytle", "adjustmentSpinbuttonTabSize"])
		self.window = self.builder.get_object("windowPluginCFG")
		placeholder = self.builder.get_object("placeholderVHDLCodeStyle")
		placeholder.add(self.builder.get_object("frameVHDLCodeSytle"))
		
		ui_handlers = {"onButtonOKClicked":self.on_ok, 
		               "onButtonCancelClicked":self.on_cancel,
		               "onPluginCFGWindowDeleteEvent":self.on_window_closing}
		
		self.builder.connect_signals(ui_handlers)
		
		self.use_uppercase_keywords = False
		self.use_spaces = True
		self.tab_size = 2
		self.auto_show_sidepanel = True
		
		self.cfg_changed_callback = cfg_changed_callback
	
	
	def show(self):
		
		self.builder.get_object("checkButtonUseSpaces").set_active(self.use_spaces)
		self.builder.get_object("checkButtonUppercaseKeywords").set_active(self.use_uppercase_keywords)
		self.builder.get_object("checkButtonAutoShowSidepanel").set_active(self.auto_show_sidepanel)
		self.builder.get_object("spinbuttonTabSize").set_value(self.tab_size)
		self.window.show_all()
		
		
	def on_ok(self, widget):
		self.window.hide()
		self.use_spaces = self.builder.get_object("checkButtonUseSpaces").get_active()
		self.use_uppercase_keywords = self.builder.get_object("checkButtonUppercaseKeywords").get_active()
		self.auto_show_sidepanel = self.builder.get_object("checkButtonAutoShowSidepanel").get_active()
		self.tab_size = int(self.builder.get_object("spinbuttonTabSize").get_value())
		
		if(self.cfg_changed_callback != None):
			self.cfg_changed_callback(self)
		
	def on_cancel(self, widget):
		self.window.hide()
		
	def on_window_closing(self, widget, data):
		self.window.hide()
		return True # to prevent the window from beeing destroyed
	


