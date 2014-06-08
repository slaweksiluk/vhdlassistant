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



def search_for_potential_clock_names(entity):
	clk_signals = []
	# check for possible clock signal candidates 
	for port in entity.port:
		if ("clk" in port.name.lower() or "clock" in port.name.lower()):
			if (port.datatype.lower() == "std_logic" and port.mode == 0):
				clk_signals.append(port.name)
	return clk_signals


def rec_print_code_hierarchy_to_string(code_hierarchy, level):
	str_buffer = ""
	
	if (code_hierarchy == None):
		return str_buffer
	
	counter = 0
	for code_hierarchy_entry in code_hierarchy:
		counter += 1
		identation_symbol = "├─"
		if counter == len(code_hierarchy) :
			identation_symbol = "└─"
		str_buffer += "│ "*level + identation_symbol + code_hierarchy_entry.name + "\n"
		str_buffer += rec_print_code_hierarchy_to_string(code_hierarchy_entry.childeren, level+1)
		
	return str_buffer

def print_code_hierarchy_to_string(code_hierarchy):
	
	str_buffer = ""
	 
	for code_hierarchy_entry in code_hierarchy:
		str_buffer += code_hierarchy_entry.name + "\n"
		str_buffer += rec_print_code_hierarchy_to_string(code_hierarchy_entry.childeren, 0)
		
	return str_buffer
	



