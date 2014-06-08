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


class VhdlEntity:
	
	def __init__ (self, name=""):
		self.name = name
		self.port = []
		self.generic = []
	
	def add_port(self, name, mode, datatype, defaultvalue = None) :
		self.port.append(Port(name, mode, datatype, defaultvalue));
	
	def add_generic(self, name, datatype, defaultvalue = None):
		self.generic.append(Generic(name, datatype, defaultvalue));

	def get_max_length_generic_name(self):
		length = 0
		for generic in self.generic:
			if (len(generic.name) > length):
				length = len(generic.name)
		return length

	def get_max_length_port_name(self):
		length = 0
		for port in self.port:
			if (len(port.name) > length):
				length = len(port.name)
		return length
		
		
class Port:
	def __init__(self, name, mode, datatype, defaultvalue = None):
		self.name = name
		self.mode = mode
		self.datatype = datatype
		self.defaultvalue = defaultvalue
		
class Generic:
	def __init__(self, name, datatype, defaultvalue = None):
		self.name = name
		self.datatype = datatype
		self.defaultvalue = defaultvalue


