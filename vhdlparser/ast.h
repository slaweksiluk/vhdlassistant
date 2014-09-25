/*
   (C) 2014 Florian Huemer

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

#ifndef _AST_H_
#define _AST_H_

#include <stdint.h>

enum node_type 
{
	TYPE_ENTITY, 
	TYPE_ARCHITECTURE,
	TYPE_FUNCTION_BODY,
	TYPE_PROCEDURE_BODY, 
	TYPE_COMPONENT, 
	TYPE_FUNCTION_DECLARATION,
	TYPE_PROCEDURE_DECLARATION,
	TYPE_PROCESS,
	TYPE_BLOCK,
	TYPE_IF_GENERATE,
	TYPE_FOR_GENERATE,
	TYPE_INSTANCE,
	TYPE_INTERFACE_ELEMENT,
	TYPE_PACKAGE_DECLARATION,
	TYPE_PACKAGE_BODY
};

enum mode
{
	MODE_IN      = 0,
	MODE_OUT     = 1,
	MODE_INOUT   = 2,
	MODE_BUFFER  = 3,
	MODE_LINKAGE = 4,
	MODE_NOT_SPECIFIED = 5
};

enum object_class
{
	OC_CONSTANT = 0,
	OC_SIGNAL   = 1,
	OC_VARIABLE = 2,
	OC_FILE     = 3,
	OC_NOT_SPECIFIED = 4
};


struct node_architecture
{
	enum node_type type;
	int line;
	char * name;
	char * entity_name;
	void * declaration_section;
	void * concurrent_statements;
};

struct node_block
{
	enum node_type type;
	int line;
	char * name;
	char * entity_name;
	void * declaration_section;
	void * concurrent_statements;
};

struct node_generate
{	
	enum node_type type;
	int line;
	char * name;
	void * declaration_section;
	void * concurrent_statements;
};

struct node_if_generate
{	
	enum node_type type;
	int line;
	char * name;
	void * declaration_section;
	void * concurrent_statements;
};

struct node_for_generate
{	
	enum node_type type;
	int line;
	char * name;
	void * declaration_section;
	void * concurrent_statements;
};

struct node_entity
{
	enum node_type type;
	int line;
	char * name;
	void * generic_section;
	void * port_section;
};

struct node_component
{
	enum node_type type;
	int line;
	char * name;
	void * generic_section;
	void * port_section;
};

struct node_procedure_decl
{
	enum node_type type;
	int line;
	char * name;
};

struct node_procedure_body
{
	enum node_type type;
	int line;
	char * name;
	void * declaration_section;
};

struct node_function_decl
{
	enum node_type type;
	int line;
	char * name;
};

struct node_process
{
	enum node_type type;
	int line;
	char * name;
	void *declaration_section;
};

struct node_function_body
{
	enum node_type type;
	int line;
	char * name;
	void * declaration_section;
};

struct node_instance
{
	enum node_type type;
	int line;
	char * name;
};

struct node_package_decl
{
	enum node_type type;
	int line;
	char *name;
	struct ll_node *declarations;
};

struct node_package_body
{
	enum node_type type;
	int line;
	char *name;
	struct ll_node *declarations;
};

//generic ast node
struct ast_labeled_node
{
	enum node_type type;
	int line;
	char *name;
};

//generic node, base node of all others
struct ast_node
{
	enum node_type type;
};


struct node_interface_element
{
	enum node_type type;
	int line;
	struct ll_node *identifier_list;
	enum mode mode;
	enum object_class object_class;
	struct text_section *data_type;
	struct text_section *init_value;
};

struct node_component         *create_component(char *str, int line); 
struct node_entity            *create_entity(char *str, int line); 
struct node_architecture      *create_archtitecture(char *arch_name, char *entity_name, int line); 
struct node_function_body     *create_function_body(char *name, int line); 
struct node_procedure_body    *create_procedure_body(char *name, int line); 
struct node_function_decl     *create_function_decl(char *name, int line); 
struct node_procedure_decl    *create_procedure_decl(char *name, int line); 
struct node_process           *create_process(char *name, int line); 
struct node_if_generate       *create_if_generate(char *name, int line); 
struct node_for_generate      *create_for_generate(char *name, int line); 
struct node_instance          *create_instance(char *name, int line); 
struct node_interface_element *create_interface_element(int line); 
struct node_block             *create_block(uint32_t line);
struct node_package_decl      *create_package_decl(char *name, int line);
struct node_package_body      *create_package_body(char *name, int line);


struct text_section
{
	uint32_t start_position;
	uint32_t end_position;
};

#endif

