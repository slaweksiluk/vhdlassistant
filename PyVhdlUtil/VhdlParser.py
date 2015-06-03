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

import subprocess
import re
import sys, traceback
import os  


from .VhdlEntity import VhdlEntity

class VhdlParser:
	
	def __init__(self):
		self.path_to_parser = os.path.dirname(os.path.realpath(__file__))+"/vhdlparser"
		self.error_list = []
		
	def get_component_from_file(self, path, component_name):
		out = subprocess.Popen([self.path_to_parser, "--component", component_name, str(path)], stdout=subprocess.PIPE).communicate()[0].decode("utf-8")
		lines = out.splitlines()
		component = self.create_vhdl_entity(component_name, lines)
		
		return component
		
	def get_entity_from_file (self, path, entity_name):
		out = subprocess.Popen([self.path_to_parser, "--entity", entity_name, str(path)], stdout=subprocess.PIPE).communicate()[0].decode("utf-8")
		lines = out.splitlines()
		entity = self.create_vhdl_entity(entity_name, lines)
		
		return entity

	def get_code_hierarchy_from_file (self, filename):
		out = subprocess.Popen([self.path_to_parser, str(filename)], stdout=subprocess.PIPE).communicate()[0].decode("utf-8")
		lines = out.splitlines()
		start_error_section = 0
		
		for line in lines:
			start_error_section += 1
			if (line == "[errors]"):
				break;
		
		code_hierarchy = self.create_code_hierarachy(lines[1:start_error_section-1])
		self.error_list = self.create_error_list(lines[start_error_section:len(lines)])
	
		return code_hierarchy
	
	def get_error_list(self) :
		return self.error_list
	
	def create_error_list(self, lines):
		error_list = []
		
		if(lines == None):
			return error_list
		
		for line in lines:
			m = re.search('([0-9]+)[ \t]+(.+)', line)
			#print(m.group(1));
			#print(m.group(2));
			line_no = int(m.group(1));
			msg = m.group(2);
			
			error_list.append(ParserError(msg, line_no))
	
		return error_list
	
	
	def create_code_hierarachy(self, lines):
		if (lines == None):
			return [];
	
		top_level_elements = []
		stack = [top_level_elements]
		
		for line in lines:
			m = re.search('([0-9]+)[ \t]+([0-9]+)[ \t]+(.+)[ \t]+(.+)', line)
		
			if (m != None):
				level = int(m.group(1));
				line_no = int(m.group(2));
				entry_type = m.group(3);
				name = m.group(4);
				
				entry = CodeHieararchyEntry(name, entry_type, line_no)
				
				while (len(stack) > level+1):
					stack.pop()
				
				stack[-1].append(entry)
				stack.append(entry.childeren)
		
		return top_level_elements

	def create_vhdl_entity(self, entity_name, lines):
		entity = VhdlEntity(entity_name)
		is_port_section = False
		
		for line in lines:
			if (line == "[generic]"):
				is_port_section = False
			elif (line == "[port]"):
				is_port_section = True
			else:
				if (is_port_section == False):
					m = re.search('([^\t]+)[ \t]([^\t]+)($|[ \t]([^\t]+)$)', line)
					if (m != None):
						name = m.group(1)
						data_type = m.group(2)
						default_value = m.group(4)
						#print (name + "  " +data_type +"  ["+str(default_value)+"]")
						if(default_value==""):
							entity.add_generic(name, data_type);
						else:
							entity.add_generic(name, data_type, default_value);
					else:
						print("error")
				elif (is_port_section == True):
					m = re.search('([^\t]+)[ \t]([0-9]+)[ \t]([^\t]+)($|[ \t]([^\t]+)$)', line)
					if (m != None):
						name = m.group(1)
						mode = int(m.group(2))
						data_type = m.group(3)
						default_value = m.group(4)
						#print (name + "  " +data_type +"  ["+default_value+"]")
						if(default_value==""):
							entity.add_port(name, mode, data_type);
						else:
							entity.add_port(name, mode, data_type, default_value);
					else:
						print("error")
						
		return entity;
		
class CodeHieararchyEntry:
	def __init__(self, name="", entry_type="", line=0):
		self.name = name
		self.line = line
		self.entry_type = entry_type
		self.childeren = []
	
class ParserError:
	def __init__(self, text="", line=0):
		self.text = text
		self.line = line 
		
