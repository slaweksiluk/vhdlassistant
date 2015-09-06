/*
   (C) 2015 Florian Huemer

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

#ifndef __VHDL_PARSER_H__
#define __VHDL_PARSER_H__

#include <stdio.h>

typedef struct 
{
	//some counters
	unsigned int enitiy_count;
	unsigned int architecture_count;
	unsigned int instance_count;
	unsigned int component_count;
	unsigned int package_count;
	unsigned int package_body_count;
	
	// errors
	void * errors;
	// ast
	void * ast;
} vhdl_parser_result;

typedef struct
{
	long yytextposition;
	vhdl_parser_result* parser_result;
} scanner_yyextra;

#define PARSE_MODE_SIMPLE   0
#define PARSE_MODE_FULL     1

vhdl_parser_result* vhdl_parser_result_init();
int vhdl_parser(FILE* infile, vhdl_parser_result * result, int mode);
struct node_entity* find_entity(void* ast, char* name);
struct node_component* find_component(void *ast, char* name);

#endif /*__VHDL_PARSER_H__*/
 
