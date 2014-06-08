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


from .VhdlEntity import VhdlEntity

#def enum(**enums):
#	return type('Enum', (), enums)

#mode = enum(IN = 0, OUT = 1, INOUT = 2, BUFFER = 3, LINKAGE = 4)


class CodeGenerator :

	ENTITY = 0
	IS = 1
	END = 2
	GENERIC = 3
	PORT = 4
	COMPONENT = 5
	PROCESS = 6
	ARCHITECTURE = 7
	OF = 8
	BEGIN = 9
	WHILE = 10
	NOT = 11
	FOR = 12
	LOOP = 13
	AFTER = 14
	WAIT = 15
	SIGNAL = 16
	CONSTANT = 17
	MAP = 18
	PACKAGE = 19
	keywords_lowercase = ["entity", "is", "end", "generic", "port", "component", "process", "architecture", "of", "begin", "while", "not", "for", "loop", "after", "wait", "signal", "constant", "map", "package"]
	mode_keywords_lowercase =  ["in", "out", "inout", "buffer", "linkage"]
	
	
	def __init__(self, use_uppercase_keywords=False, use_spaces=False, tab_size=2):
		
		if (use_uppercase_keywords==False):
			self.keywords = self.keywords_lowercase;
			self.mode_keywords = self.mode_keywords_lowercase;
			self.uppercase_keywords = False
		elif(use_uppercase_keywords==True):
			self.keywords = [x.upper() for x in self.keywords_lowercase]
			self.mode_keywords = [x.upper() for x in self.mode_keywords_lowercase]
			self.uppercase_keywords = True
		
		if (use_spaces == True):
			self.indentation = " "*tab_size
		else : 
			self.indentation = "\t"
		
		self.compact_code = False # for future use

	def gen_package_with_component_declaration(self, entity):
		str_buffer = ""
		str_buffer += "library ieee;\n"
		str_buffer += "use ieee.std_logic_1164.all;\n"
		str_buffer += "use ieee.numeric_std.all;\n"

		if (self.uppercase_keywords == True):
			str_buffer = str_buffer.upper();
			
		str_buffer += "\n"
		str_buffer += self.keywords[self.PACKAGE] + " " + entity.name + "_pkg " + self.keywords[self.IS] + "\n"
		str_buffer += "\n"
		str_buffer += self.gen_component(entity, self.indentation)
		str_buffer += "\n"
		str_buffer += self.keywords[self.END] + " " + self.keywords[self.PACKAGE] + ";\n"

		return str_buffer

	def gen_testbench(self, entity, clk_signals=None):
		str_buffer = ""
		str_buffer += "library ieee;\n"
		str_buffer += "use ieee.std_logic_1164.all;\n"
		str_buffer += "use ieee.numeric_std.all;\n"
		
		if (self.uppercase_keywords == True):
			str_buffer = str_buffer.upper();
		
		str_buffer += "\n"
		str_buffer += self.gen_entity(VhdlEntity(entity.name+"_tb")) + "\n"
		
		str_buffer += "\n"
		
		# architecture
		str_buffer += self.keywords[self.ARCHITECTURE] + " bench " + self.keywords[self.OF] + " " + entity.name + "_tb " + self.keywords[self.IS] + "\n"
		
		# component declaration 
		str_buffer += "\n" + self.gen_component(entity, self.indentation) + "\n\n"
		
		# signal and constant declarations
		for generic in entity.generic :
			str_buffer += self.indentation + self.keywords[self.CONSTANT] + " " + generic.name + " : " + generic.datatype + " := " + str(generic.defaultvalue) + ";\n"
		
		for port in entity.port :
			str_buffer += self.indentation + self.keywords[self.SIGNAL] + " " + port.name + " : " + port.datatype + ";\n"
		
		#clock stuff
		if ( clk_signals != None ) :
			str_buffer += "\n"
			for clk_name in clk_signals :
				str_buffer += self.indentation + self.keywords[self.CONSTANT] + " " + (clk_name.upper() + "_PERIOD") + " : time := 10 ns;\n" 
			str_buffer += self.indentation + self.keywords[self.CONSTANT] + " stop_clock : boolean := false;\n"

		
		# begin
		str_buffer += self.keywords[self.BEGIN] + "\n\n"
		
		# create instance
		str_buffer += self.gen_instance_simple("uut", entity, True, self.indentation) + "\n"
		
		#generate stimulus process
		str_buffer += self.indentation + "stimulus : " + self.keywords[self.PROCESS] + "\n"
		str_buffer += self.indentation + self.keywords[self.BEGIN] + "\n"
		str_buffer += self.indentation + self.indentation + self.keywords[self.WAIT] + ";\n"
		str_buffer += self.indentation + self.keywords[self.END] + " " + self.keywords[self.PROCESS] + ";\n\n"
		
		# generate clocking process
		if ( clk_signals != None ) :
			for clk_name in clk_signals:
				str_buffer += self.gen_clock_process(clk_name, (clk_name.upper() + "_PERIOD"), self.indentation)
				str_buffer += '\n'
		
		str_buffer += self.keywords[self.END] + " " + self.keywords[self.ARCHITECTURE] + ";\n"

		return str_buffer

	def gen_clock_process(self, clk_name, period, line_prefix="" ):
		str_buffer = ""
		str_buffer += line_prefix + "generate_" +clk_name + " : " + self.keywords[self.PROCESS] + "\n"
		str_buffer += line_prefix + self.keywords[self.BEGIN] + "\n"
		str_buffer += line_prefix + self.indentation + self.keywords[self.WHILE] + " " + self.keywords[self.NOT] + " stop_clock " + self.keywords[self.LOOP] + "\n"
		str_buffer += line_prefix + self.indentation*2 + clk_name + " <= '0', '1' " + self.keywords[self.AFTER] + " " + period + " / 2;\n"
		str_buffer += line_prefix + self.indentation*2 + self.keywords[self.WAIT] + " " + self.keywords[self.FOR] + " " + period + ";\n"
		str_buffer += line_prefix + self.indentation + self.keywords[self.END] + " " +self.keywords[self.LOOP] + ";\n"
		str_buffer += line_prefix + self.indentation + self.keywords[self.WAIT] + ";\n"
		str_buffer += line_prefix + self.keywords[self.END] + " " + self.keywords[self.PROCESS] + ";\n"
		return str_buffer

	def gen_instance_simple(self, name, entity, gen_signal_assignment=False, line_prefix="") :
		str_buffer = ""
		
		str_buffer += line_prefix + name + " : " + entity.name + "\n"
		
		
		if (len(entity.generic)>0):
			str_buffer += line_prefix + self.indentation + self.keywords[self.GENERIC] + " " + self.keywords[self.MAP] + "\n"
			str_buffer += line_prefix + self.indentation  + "(\n"
			max_ident_length = entity.get_max_length_generic_name();
			
			
			head_tail_iter_generic = iter( entity.generic )
			first_generic = next(head_tail_iter_generic)  #iterator.next() is NOT valid in python 3, next() method was renamed __next__()
			
			str_buffer += line_prefix + self.indentation*2 + self.gen_ident_aligned(first_generic.name,max_ident_length) + " => "
			if(gen_signal_assignment == True):
				str_buffer += first_generic.name
			else :
				str_buffer += "xxx"
			
			for generic in head_tail_iter_generic :
				str_buffer += ",\n"
				str_buffer += line_prefix + self.indentation*2 + self.gen_ident_aligned(generic.name,max_ident_length) + " => "
				if(gen_signal_assignment == True):
					str_buffer += generic.name
				else :
					str_buffer += "xxx"
			
			str_buffer += "\n" + line_prefix + self.indentation + ")\n"
		
		if (len(entity.port) > 0) :
			str_buffer += line_prefix + self.indentation + self.keywords[self.PORT] + " " + self.keywords[self.MAP] + "\n"
			str_buffer += line_prefix + self.indentation  + "(\n"
			max_ident_length = entity.get_max_length_port_name();
			
			head_tail_iter_port = iter( entity.port)
			head = next(head_tail_iter_port)
			
			str_buffer += line_prefix + self.indentation*2 + self.gen_ident_aligned(head.name,max_ident_length) + " => "
			if(gen_signal_assignment == True):
				str_buffer += head.name
			else :
				str_buffer += "xxx"
			
			for port in head_tail_iter_port :
				str_buffer += ",\n"
				str_buffer += line_prefix + self.indentation*2 + self.gen_ident_aligned(port.name,max_ident_length) + " => "
				if(gen_signal_assignment == True):
					str_buffer += port.name
				else :
					str_buffer += "xxx"
			
			str_buffer += "\n" + line_prefix + self.indentation + ");\n"
		
		return str_buffer
		
	def gen_ident_aligned(self, name, length):
		str_buffer = ""
		str_buffer += name + ' '*(length-len(name))
		return str_buffer

	def gen_entity(self, entity, line_prefix=""):
		str_buffer = ""
		str_buffer += line_prefix + "" + self.keywords[self.ENTITY] + " " + entity.name + " " + self.keywords[self.IS] + "\n"
		if (len(entity.generic) > 0) :
			str_buffer += line_prefix + "" + self.gen_generic(entity.generic, self.indentation) + "\n"
		if (len(entity.port) > 0) :
			str_buffer += line_prefix + "" + self.gen_port(entity.port, self.indentation)  + "\n"
		str_buffer += line_prefix + "" + self.keywords[self.END] + " " + self.keywords[self.ENTITY] + ";"
		return str_buffer
	
	def gen_component(self, entity, line_prefix=""):
		str_buffer = ""
		str_buffer += line_prefix + "" + self.keywords[self.COMPONENT] + " " + entity.name + " " + self.keywords[self.IS] + "\n"
		if (len(entity.generic) > 0) :
			str_buffer += self.gen_generic(entity.generic, line_prefix + self.indentation) + "\n"
		if (len(entity.port) > 0) :
			str_buffer += self.gen_port(entity.port, line_prefix + self.indentation) + "\n"
		str_buffer += line_prefix + "" + self.keywords[self.END] + " " + self.keywords[self.COMPONENT] + ";"
		return str_buffer
	
	def gen_port(self, port, line_prefix):
		str_buffer = ""
		str_buffer += line_prefix + self.keywords[self.PORT]+ "\n";
		str_buffer += line_prefix + "(\n"
		
		for i in range(0,len(port)):
			port_item = port[i];
			str_buffer += line_prefix + self.indentation + port_item.name + " : " + self.mode_keywords[port_item.mode] + " " + port_item.datatype 
			if (port_item.defaultvalue != None):
				str_buffer += " := " + port_item.defaultvalue
			if ( i != len(port)-1):
				str_buffer += ";\n"
			else:
				str_buffer += "\n"
		str_buffer += line_prefix + ");"
		return str_buffer
	
	def gen_generic(self, generic, line_prefix):
		str_buffer = ""
		str_buffer += line_prefix + self.keywords[self.GENERIC]+ "\n";
		str_buffer += line_prefix + "(\n"
		
		for i in range(0,len(generic)):
			generic_item = generic[i];
			str_buffer += line_prefix + self.indentation + generic_item.name + " : " + generic_item.datatype
			if (generic_item.defaultvalue != None):
				str_buffer += " := " + generic_item.defaultvalue
			if ( i != len(generic)-1):
				str_buffer += ";\n"
			else:
				str_buffer += "\n"
		str_buffer += line_prefix + ");"
		return str_buffer

#if __name__ == "__main__":

#	entity = VhdlEntity();

#	entity.name = "and_gate"
#	entity.add_generic("OUTPUT_DELAY_B", "time")
#	entity.add_generic("OUTPUT_DELAY", "time", "1 ns")
#	entity.add_port("a1", mode.IN,  "std_logic")
#	entity.add_port("b1", mode.IN,  "std_logic")
#	entity.add_port("c1", mode.OUT, "std_logic")
#	entity.add_port("a2", mode.IN,  "std_logic")
#	entity.add_port("b2", mode.IN,  "std_logic")
#	entity.add_port("c2", mode.OUT, "std_logic")
#	entity.add_port("a3", mode.IN,  "std_logic")
#	entity.add_port("b3", mode.IN,  "std_logic")
#	entity.add_port("c3", mode.OUT, "std_logic")

#	entity2 = VhdlEntity(name="dflipflop");
#	entity2.add_generic("OUTPUT_DELAY", "time", "1 ns")
#	#entity2.add_generic("DATA_WIDTH", "integer", "8")
#	entity2.add_port("clk", mode.IN,  "std_logic")
#	entity2.add_port("rst", mode.IN,  "std_logic")
#	#entity2.add_port("d", mode.IN, "std_logic_vector(DATA_WIDTH-1 downto 0)")
#	#entity2.add_port("en", mode.IN, "std_logic")
#	#entity2.add_port("q", mode.OUT, "std_logic_vector(DATA_WIDTH-1 downto 0)")

#	cg = CodeGenerator(use_uppercase_keywords=False)
#	print(cg.gen_entity(entity));
#	print(cg.gen_entity(entity2));
#	print(cg.gen_component(entity));
#	print(cg.gen_testbench(entity2, ["clk"]))

