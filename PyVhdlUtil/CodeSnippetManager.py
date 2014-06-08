#    (C) 2014 Florian Huemer
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
#
#
#    IMPORTANT:
#    The hard coded code snippets embedded in this file are NOT covered by
#    the GNU GPL. You are free to use them in any way you like.
#    The Altera (R) snipptes are based on the ones shown in the Quartus II
#    handbook (Chapter: Recommended HDL Coding Styles).
#


import subprocess
import re
import sys, traceback
import os  


class CodeSnippetManager:
	def __init__(self, use_uppercase_keywords=False, use_spaces=False, tab_size=2):
		self.path_to_snippetformatter = os.path.dirname(os.path.realpath(__file__))+"/snippetformatter"
	
		self.snippets = CodeSnippetCategory("")
		
		c = CodeSnippetCategory("Altera\u00AE")
		c_ram_std_logic = CodeSnippetCategory("RAM (integer address)")
		c_ram_std_logic.add_snippet(CodeSnippet("Simple DP, Single-Clock RAM (old data rdw behavior)", ram_1c1r1w_old_data_rdw))
		c_ram_std_logic.add_snippet(CodeSnippet("Simple DP, Single-Clock RAM (new data rdw behavior)", ram_1c1r1w_new_data_rdw))
		c_ram_std_logic.add_snippet(CodeSnippet("Simple DP, Dual-Clock RAM", dp_ram_2c1r1w))
		c_ram_std_logic.add_snippet(CodeSnippet("True DP, Single-Clock RAM", ram_1c2r2w))
		c.add_subcategory(c_ram_std_logic)
		
		
		c_ram_integer = CodeSnippetCategory("RAM (std_logic_vector address)")
		c_ram_integer.add_snippet(CodeSnippet("Simple DP, Single-Clock RAM (old data rdw behavior)", ram_1c1r1w_old_data_rdw_std_logic))
		c_ram_integer.add_snippet(CodeSnippet("Simple DP, Single-Clock RAM (new data rdw behavior)", ram_1c1r1w_new_data_rdw_std_logic))
		c_ram_integer.add_snippet(CodeSnippet("Simple DP, Dual-Clock RAM", dp_ram_2c1r1w_std_logic))
		c_ram_integer.add_snippet(CodeSnippet("True DP, Single-Clock RAM", ram_1c2r2w_std_logic))
		c.add_subcategory(c_ram_integer)

		self.snippets.add_subcategory(c)
		
		self.use_uppercase_keywords = use_uppercase_keywords 
		self.use_spaces = use_spaces 
		self.tab_size = tab_size
		
	def add(self, snippet, category):
		
		current_category = self.snippets
		
		for i in range(0,len(category)):
			
			c = category[i]
			category_exists = False
			
			for subcategory in current_category.subcategories:
				if ( subcategory.name == c):
					current_category = subcategory
					category_exists = True
					break;
			
			if (not category_exists):
				for j in range(i,len(category)) :
					c = category[j]
					new_category = CodeSnippetCategory(c)
					current_category.subcategories.append(new_category) 
					current_category = new_category
				break;
			
		current_category.snippets.append(snippet)

	def format_sippet_content(self, snippet_content):
		command = [self.path_to_snippetformatter]
		if (self.use_uppercase_keywords == True):
			command.append("-u")
		else:
			command.append("-l")
		
		if (self.use_spaces == True):
			command.append("-s "+str(self.tab_size))
			
		p = subprocess.Popen(command, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
		out = p.communicate(input=bytes(snippet_content,'UTF-8'))[0].decode("utf-8")
		return out

class CodeSnippetCategory:
	def __init__(self, name):
		self.name = name
		self.subcategories = []
		self.snippets = []
		
	def add_snippet(self, c):
		self.snippets.append(c)
	
	def add_subcategory(self, s):
		self.subcategories.append(s)

class CodeSnippet:
	def __init__(self, name, content):
		self.name = name
		self.content = content
		
		
ram_1c1r1w_old_data_rdw = """
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ram_1c1r1w IS
	generic(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);
	PORT (
		clk  : IN std_logic;
		data : IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0);
		wr_addr : IN integer RANGE 0 to 2**ADDR_WIDTH-1;
		rd_addr : IN integer RANGE 0 to 2**ADDR_WIDTH-1;
		we : IN std_logic;
		q  : OUT std_logic_vector (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;

--old data read during write behavior
ARCHITECTURE rtl OF ram_1c1r1w IS
	TYPE MEM IS ARRAY(0 TO 2**ADDR_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ram_block: MEM;
BEGIN
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (we = '1') THEN
				ram_block(wr_addr) <= data;
			END IF;
			q <= ram_block(rd_addr);
			-- VHDL semantics imply that q doesn't get data
			-- in this clock cycle
		END IF;
	END PROCESS;
END architecture;
"""

ram_1c1r1w_old_data_rdw_std_logic = """
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_1c1r1w IS
	generic(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);
	PORT (
		clk  : IN std_logic;
		data : IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0);
		wr_addr : IN std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
		rd_addr : IN std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
		we : IN std_logic;
		q  : OUT std_logic_vector (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;

--old data read during write behavior
ARCHITECTURE rtl OF ram_1c1r1w IS
	TYPE MEM IS ARRAY(0 TO 2**ADDR_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ram_block: MEM;
BEGIN
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (we = '1') THEN
				ram_block(to_integer(unsigned(wr_addr))) <= data;
			END IF;
			q <= ram_block(to_integer(unsigned(rd_addr)));
			-- VHDL semantics imply that q doesn't get data
			-- in this clock cycle
		END IF;
	END PROCESS;
END architecture;
"""

ram_1c1r1w_new_data_rdw = """
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ram_1c1r1w IS
	generic(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);
	PORT (
		clk  : IN std_logic;
		data : IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0);
		wr_addr : IN integer RANGE 0 to 2**ADDR_WIDTH-1;
		rd_addr : IN integer RANGE 0 to 2**ADDR_WIDTH-1;
		we : IN std_logic;
		q  : OUT std_logic_vector (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;

--new data read during write behavior
ARCHITECTURE rtl OF ram_1c1r1w IS
	TYPE MEM IS ARRAY(0 TO 2**ADDR_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL rd_addr_reg: integer RANGE 0 to 2**ADDR_WIDTH-1;
BEGIN
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (we = '1') THEN
			ram_block(wr_addr) <= data;
			END IF;
			rd_addr_reg <= rd_addr;
		END IF;
	END PROCESS;
	q <= ram_block(rd_addr_reg);
END architecture;
"""

ram_1c1r1w_new_data_rdw_std_logic = """
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_1c1r1w IS
	generic(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);
	PORT (
		clk  : IN std_logic;
		data : IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0);
		wr_addr : IN std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
		rd_addr : IN std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
		we : IN std_logic;
		q  : OUT std_logic_vector (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;

--new data read during write behavior
ARCHITECTURE rtl OF ram_1c1r1w IS
	TYPE MEM IS ARRAY(0 TO 2**ADDR_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL rd_addr_reg: integer RANGE 0 to 2**ADDR_WIDTH-1;
BEGIN
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (we = '1') THEN
				ram_block(to_integer(unsigned(wr_addr))) <= data;
			END IF;
			rd_addr_reg <= to_integer(unsigned(rd_addr));
		END IF;
	END PROCESS;
	q <= ram_block(rd_addr_reg);
END architecture;
"""

dp_ram_2c1r1w = """
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ram_2c1r1w IS
	generic(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);
	PORT (
		clk1 : IN std_logic;
		clk2 : IN std_logic; 
		data : IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0);
		wr_addr : IN integer RANGE 0 to 2**ADDR_WIDTH-1;
		rd_addr : IN integer RANGE 0 to 2**ADDR_WIDTH-1;
		we : IN std_logic;
		q  : OUT std_logic_vector (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;

ARCHITECTURE rtl OF ram_2c1r1w IS
	TYPE MEM IS ARRAY(0 TO 2**ADDR_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL rd_addr_reg : integer RANGE 0 to 2**ADDR_WIDTH-1;
BEGIN
	write_port : PROCESS (clk1)
	BEGIN
		IF (rising_edge(clk1)) THEN
			IF (we = '1') THEN
				ram_block(wr_addr) <= data;
			END IF;
		END IF;
	END PROCESS;
	
	read_port : PROCESS (clk2)
	BEGIN
		IF (rising_edge(clk2)) THEN
			q <= ram_block(rd_addr_reg);
			rd_addr_reg <= rd_addr;
		END IF;
	END PROCESS;
END architecture;
"""

dp_ram_2c1r1w_std_logic = """
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ram_2c1r1w IS
	generic(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);
	PORT (
		clk1 : IN std_logic;
		clk2 : IN std_logic; 
		data : IN std_logic_vector (DATA_WIDTH-1 DOWNTO 0);
		wr_addr : IN std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
		rd_addr : IN std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
		we : IN std_logic;
		q  : OUT std_logic_vector (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;

ARCHITECTURE rtl OF ram_2c1r1w IS
	TYPE MEM IS ARRAY(0 TO 2**ADDR_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL rd_addr_reg : integer RANGE 0 to 2**ADDR_WIDTH-1;
BEGIN
	write_port : PROCESS (clk1)
	BEGIN
		IF (rising_edge(clk1)) THEN
			IF (we = '1') THEN
				ram_block(to_integer(unsigned(wr_addr))) <= data;
			END IF;
		END IF;
	END PROCESS;
	
	read_port : PROCESS (clk2)
	BEGIN
		IF (rising_edge(clk2)) THEN
			q <= ram_block(rd_addr_reg);
			rd_addr_reg <= to_integer(unsigned(rd_addr));
		END IF;
	END PROCESS;
END architecture;
"""

ram_1c2r2w = """
library ieee;
use ieee.std_logic_1164.all;

-- a true dual port, single clock ram 
entity ram_1c2r2w is
	generic (
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);
	port (
		clk    : in std_logic;
		addr_a : in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b : in natural range 0 to 2**ADDR_WIDTH - 1;
		data_a : in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b : in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_a   : in std_logic := '1';
		we_b   : in std_logic := '1';
		q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0)
	);
end entity;

architecture rtl of ram_1c2r2w is
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array((2**ADDR_WIDTH - 1) downto 0) of word_t;
	-- Declare the RAM signal.
	shared variable ram : memory_t;
begin
	
	port_a : process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we_a = '1') then
				ram(addr_a) := data_a;
				-- Read-during-write on the same port returns NEW data
				q_a <= data_a;
			else
				-- Read-during-write on the mixed port returns OLD data
				q_a <= ram(addr_a);
			end if;
		end if;
	end process;

	port_b : process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we_b = '1') then
				ram(addr_b) := data_b;
				-- Read-during-write on the same port returns NEW data
				q_b <= data_b;
			else
				-- Read-during-write on the mixed port returns OLD data
				q_b <= ram(addr_b);
			end if;
		end if;
	end process;
	
end architecture;
"""


ram_1c2r2w_std_logic = """
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- a true dual port, single clock ram 
entity ram_1c2r2w is
	generic (
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);
	port (
		clk    : in std_logic;
		addr_a : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		addr_b : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		data_a : in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b : in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_a   : in std_logic := '1';
		we_b   : in std_logic := '1';
		q_a    : out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b    : out std_logic_vector((DATA_WIDTH -1) downto 0)
	);
end entity;

architecture rtl of ram_1c2r2w is
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array((2**ADDR_WIDTH - 1) downto 0) of word_t;
	-- Declare the RAM signal.
	shared variable ram : memory_t;
begin
	
	port_a : process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we_a = '1') then
				ram(to_integer(unsigned(addr_a))) := data_a;
				-- Read-during-write on the same port returns NEW data
				q_a <= data_a;
			else
				-- Read-during-write on the mixed port returns OLD data
				q_a <= ram(to_integer(unsigned(addr_a)));
			end if;
		end if;
	end process;

	port_b : process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we_b = '1') then
				ram(to_integer(unsigned(addr_b))) := data_b;
				-- Read-during-write on the same port returns NEW data
				q_b <= data_b;
			else
				-- Read-during-write on the mixed port returns OLD data
				q_b <= ram(to_integer(unsigned(addr_b)));
			end if;
		end if;
	end process;
	
end architecture;
"""
