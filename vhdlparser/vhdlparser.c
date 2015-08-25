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

#include "vhdlparser.h"
#include "flexbison/parser.tab.h"
#include "flexbison/scanner.h"
#include "ast.h"
#include <malloc.h>

vhdl_parser_result* vhdl_parser_result_init()
{
	vhdl_parser_result *result = malloc(sizeof(vhdl_parser_result));
	result->enitiy_count = 0;
	result->architecture_count = 0;
	result->instance_count = 0;
	result->package_body_count = 0;
	result->package_count = 0;
	result->component_count = 0;
	
	result->errors = agc_new();
	result->ast = agc_new();
	
	return result;
}

int vhdl_parser(FILE *infile, vhdl_parser_result * result, int mode)
{
	yyscan_t myscanner;
	
	if (result == NULL || infile == NULL) {
		return -1;
	}
	
	scanner_yyextra extra;
	extra.yytextposition = 0;
	extra.parser_result = result;
	
	yylex_init_extra(&extra, &myscanner);
	yyset_in(infile, myscanner);
	yyparse(myscanner, result);
	yylex_destroy(myscanner);
	
	return 0;
}


/*
entities can only be on the "top-level" of an AST. So it is sufficient to
non-recursively iterate over the ast.
*/
struct node_entity* find_entity(void *ast, char *name)
{
	void* iter;
	agc_iterate_begin(ast, iter) {
		struct ast_node* node = (struct ast_node*)iter;
		if (node->type == TYPE_ENTITY) {
			if (!strcmp(((struct node_entity*)iter)->name, name)) {
				return iter;
			}
		}
	} agc_iterate_end(ast, iter);
	return NULL;
}


/*

*/
struct node_component* find_component(void *ast, char *name)
{
	if (ast == NULL) {
		return NULL;
	}
	void* iter;
	agc_iterate_begin(ast, iter) {
		struct ast_node* node = (struct ast_node*)iter;
		switch (node->type) {
			case TYPE_ARCHITECTURE:
			case TYPE_FUNCTION_BODY:
			case TYPE_PROCEDURE_BODY: 
			case TYPE_PROCESS:
			case TYPE_BLOCK:
			case TYPE_IF_GENERATE:
			case TYPE_FOR_GENERATE:
			case TYPE_PACKAGE_DECLARATION:
			case TYPE_PACKAGE_BODY:
			{
				struct node_component* c;
				c = find_component(((struct node_with_declaration_section*)iter)->declaration_section, name);
				if (c != NULL) {
					return c;
				}
			}
			break;
			case TYPE_COMPONENT:
				if (!strcmp(((struct node_component*)iter)->name, name)) {
					return iter;
				}
				break;
			
			default:
				break;
		}
	} agc_iterate_end(ast, iter);
	return NULL;
}






