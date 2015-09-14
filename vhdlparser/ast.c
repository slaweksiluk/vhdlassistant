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

#include "ast.h"
#include "malloc.h"

struct node_library *create_library(char *str, int line)
{
	struct node_library *lib = malloc(sizeof(struct node_library));
	lib->type = TYPE_LIBRARY;
	lib->name = str;
	lib->line = line;
	return lib;
}

struct node_entity *create_entity(char *str, int line)
{
	struct node_entity *entity = malloc(sizeof(struct node_entity));
	entity->type = TYPE_ENTITY;
	entity->name = str;
	entity->port_section = NULL;
	entity->generic_section = NULL;
	entity->line = line;
	return entity;
}

struct node_component *create_component(char *str, int line)
{
	struct node_component *component = malloc(sizeof(struct node_component));
	component->type = TYPE_COMPONENT;
	component->name = str;
	component->port_section = NULL;
	component->generic_section = NULL;
	component->line = line;
	return component;
}

struct node_architecture *create_archtitecture(char *arch_name, char *entity_name, int line)
{
	struct node_architecture *architecture = malloc(sizeof(struct node_architecture));
	architecture->type = TYPE_ARCHITECTURE;
	architecture->name = arch_name;
	architecture->entity_name = entity_name;
	architecture->line = line;
	architecture->declaration_section = NULL;
	architecture->concurrent_statements = NULL;
	return architecture;
}

struct node_if_generate *create_if_generate(char *name,  int line)
{
	struct node_if_generate *if_gen = malloc(sizeof(struct node_if_generate));
	if_gen->type = TYPE_IF_GENERATE;
	if_gen->name = name;
	if_gen->line = line;
	if_gen->declaration_section = NULL;
	if_gen->concurrent_statements = NULL;
	return if_gen;
}

struct node_for_generate *create_for_generate(char *name,  int line)
{
	struct node_for_generate *for_gen = malloc(sizeof(struct node_for_generate));
	for_gen->type = TYPE_FOR_GENERATE;
	for_gen->name = name;
	for_gen->line = line;
	for_gen->declaration_section = NULL;
	for_gen->concurrent_statements = NULL;
	return for_gen;
}

struct node_block *create_block(uint32_t line)
{
	struct node_block *block = malloc(sizeof(struct node_block));
	block->type = TYPE_BLOCK;
	block->name = NULL;
	block->line = line;
	block->declaration_section = NULL;
	block->concurrent_statements = NULL;
	return block;
}

struct node_function_body *create_function_body(char *name, int line)
{
	struct node_function_body *func = malloc(sizeof(struct node_function_body));
	func->type = TYPE_FUNCTION_BODY;
	func->name = name;
	func->declaration_section = NULL;
	func->line = line;
	return func;
}

struct node_procedure_body *create_procedure_body(char *name, int line)
{
	struct node_procedure_body *proc = malloc(sizeof(struct node_procedure_body));
	proc->type = TYPE_PROCEDURE_BODY;
	proc->name = name;
	proc->declaration_section = NULL;
	proc->line = line;
	return proc;
}

struct node_function_decl *create_function_decl(char *name, int line)
{
	struct node_function_decl *func_decl = malloc(sizeof(struct node_function_decl));
	func_decl->type = TYPE_FUNCTION_DECLARATION;
	func_decl->name = name;
	func_decl->line = line;
	return func_decl;
}

struct node_procedure_decl *create_procedure_decl(char *name, int line)
{
	struct node_procedure_decl *proc_decl = malloc(sizeof(struct node_procedure_decl));
	proc_decl->type = TYPE_PROCEDURE_DECLARATION;
	proc_decl->name = name;
	proc_decl->line = line;
	return proc_decl;
}

struct node_process *create_process(char *name, int line)
{
	struct node_process *process = malloc(sizeof(struct node_process));
	process->type = TYPE_PROCESS;
	process->name = name;
	process->line = line;
	return process;
}

struct node_instance *create_instance(char *name, int line)
{
	struct node_instance *inst = malloc(sizeof(struct node_instance));
	inst->type = TYPE_INSTANCE;
	inst->name = name;
	inst->line = line;
	return inst;
}

struct node_interface_element *create_interface_element(int line)
{
	struct node_interface_element *node = malloc(sizeof(struct node_interface_element));
	node->line = line;
	return node;
}

struct node_package_decl * create_package_decl(char *name, int line)
{
	struct node_package_decl *pkg_decl = malloc(sizeof(struct node_package_decl));
	pkg_decl->type = TYPE_PACKAGE_DECLARATION;
	pkg_decl->name = name;
	pkg_decl->line = line;
	pkg_decl->declaration_section = NULL;
	return pkg_decl;
}

struct node_package_body * create_package_body(char *name, int line)
{
	struct node_package_body *pkg_decl = malloc(sizeof(struct node_package_body));
	pkg_decl->type = TYPE_PACKAGE_BODY;
	pkg_decl->name = name;
	pkg_decl->line = line;
	pkg_decl->declaration_section = NULL;
	return pkg_decl;
}

struct node_port *create_port(char *name, int line)
{
	struct node_port *port = malloc(sizeof(struct node_port));
	port->type = TYPE_PORT;
	port->name = name;
	port->line = line;
	port->mode = MODE_IN;
	return port;
}

struct node_generic *create_generic(char *name, int line)
{
	struct node_generic *generic = malloc(sizeof(struct node_generic));
	generic->type = TYPE_GENERIC;
	generic->name = name;
	generic->line = line;
	return generic;
}






