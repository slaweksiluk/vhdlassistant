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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>
#include <malloc.h>
#include "flexbison/parser.tab.h"
#include "flexbison/scanner.h"
#include "linked_list.h"
#include "parser_error.h"
#include "ast.h"
#include "vector.h"

extern uint32_t yytextposition;
extern FILE * yyin;
extern struct ll_node * parse_result; 
extern struct ll_node * error_list;
 
extern char* find_entity_name;
extern struct node_entity *found_entity;
extern char* find_component_name;
extern struct node_component *found_component;

void generate_output(struct ll_node *parse_result, int level);
void print_errors(struct ll_node *error_list);
void print_entity(struct node_entity *entity);
void print_component(struct node_component *component);
void print_generic_section(vector *generic_vector);
void print_port_section(vector *port_vector);

/*not used anymore*/
struct node_entity* find_entity(struct ll_node *parse_result, char *name);

void print_text_section(FILE *f, struct text_section *txt_sec);

/*
[code_hierarchy]
LEVEL LINE TYPE NAME
[errors]
LINE MESSAGE
*/


int main(int argc, char *argv[])
{

	if (argc == 2)
	{
		yyin = fopen(argv[1], "r");
		yyparse ();

		printf("[code_hierarchy]\n");
		generate_output(parse_result, 0);

		printf("[errors]\n");	
		print_errors(error_list);
	}
	else if (argc == 4)
	{
		if (!strcmp("--entity", argv[1]))
		{
			yyin = fopen(argv[3], "r");
			find_entity_name = argv[2];
			yyparse ();
			
			if (found_entity == NULL) // entity not found
			{
				struct parser_error_1s *err = malloc(sizeof(struct parser_error_1s));
				err->s0 = find_entity_name;
				err->id = ERROR_ENTITY_NOT_FOUND;
				err->line = 0;
				error_list = ll_append_back(error_list, err);
				print_errors(error_list);
			} else {
				print_entity(found_entity);
			}
		}
		else if(!strcmp("--component", argv[1]))
		{
			yyin = fopen(argv[3], "r");
			find_component_name = argv[2];
			yyparse ();
			if (found_component == NULL) // entity not found
			{
				struct parser_error_1s *err = malloc(sizeof(struct parser_error_1s));
				err->s0 = find_component_name;
				err->id = ERROR_COMPONENT_NOT_FOUND;
				err->line = 0;
				error_list = ll_append_back(error_list, err);
				print_errors(error_list);
			} else {
				print_component(found_component);
			}
		}
		/*else if(!strcmp("--vectest", argv[1]))
		{
			vector* vec = vector_new(4);
			vector_add(vec, "test0");
			vector_add(vec, "test1");
			vector_add(vec, "test2");
			vector_add(vec, "test3");
			vector_add(vec, "test4");
			
			printf("%i\n", vec->capacity);
			
			vector* vec2 = vector_new(4);
			vector_add(vec2, "vec2test0");
			vector_add(vec2, "vec2test1");
			vector_add(vec2, "vec2test2");
			vector_add(vec2, "vec2test3");
			vector_add(vec2, "vec2test4");
			
			vector_add_range(vec, vec2);
			
			for(int i=0; i<vec->count; i++)
			{
				printf("%s\n", (char*)vector_get(vec, i));
			}
		}*/
	}
	
	
	
	return 0;
}


void print_component(struct node_component *component)
{
	print_generic_section(component->generic_section);
	print_port_section(component->port_section);
}

void print_entity(struct node_entity *entity)
{
	print_generic_section(entity->generic_section);
	print_port_section(entity->port_section);
}


void print_generic_section(vector *generic_vector)
{
	printf("[generic]\n");
	
	if(generic_vector == NULL)
	{
		return;
	}
	
	for(int i=0; i<generic_vector->count; i++)
	{
		struct node_generic * generic = (struct node_generic*)vector_get(generic_vector, i); 
		printf("%s\t", generic->name);
			
		print_text_section(yyin, &generic->data_type);
			
		if(generic->init_value.end_position != 0)
		{
			printf("\t");
			print_text_section(yyin, &generic->init_value);
		}
			
		printf("\n");
	}
}


void print_port_section(vector *port_vector)
{
	printf("[port]\n");
	
	if(port_vector == NULL)
	{
		return;
	}
	
	for(int i=0; i<port_vector->count; i++)
	{
		struct node_port * port = (struct node_port*)vector_get(port_vector, i); 
		printf("%s\t%x\t", port->name, port->mode);
			
		print_text_section(yyin, &port->data_type);
			
		if(port->init_value.end_position != 0)
		{
			printf("\t");
			print_text_section(yyin, &port->init_value);
		}
			
		printf("\n");
	}
}

void print_text_section(FILE *f, struct text_section *txt_sec)
{
	fseek(f, txt_sec->start_position, SEEK_SET);
	int i;
	for( i=0; i <= txt_sec->end_position - txt_sec->start_position; i++)
	{
		char c = getc(f);
		if(c=='\n' || c =='\t') {
			putchar(' ');
		}else if (c=='-'){
			char next_char = getc(f);
			i++;
			if (next_char == '-') {
				next_char = getc(f);
				i++;
				while(next_char != '\n'){
					next_char = getc(f);
					i++;
				}
			}else{
				putchar(c);
				putchar(next_char);
			}
		}else{
			putchar(c);
		}
	}
}

void generate_output(struct ll_node *parse_result, int level)
{
	while(parse_result != NULL)
	{
		switch ( ((struct ast_node*)parse_result->data)->type )
		{
			case TYPE_ENTITY:
			{
				struct node_entity *entity = ((struct node_entity*)parse_result->data);
				
				printf("%i\t%i\tEntity\t%s\n", level, entity->line, entity->name);
			}
				break;
				
			case TYPE_ARCHITECTURE:
			{
				struct node_architecture *architecture = ((struct node_architecture*)parse_result->data);
				printf("%i\t%i\tArch.\t%s\n", level, architecture->line, architecture->name);
				generate_output(architecture->declaration_section, level+1);
				generate_output(architecture->concurrent_statements, level+1);
			}
				break;
				
			case TYPE_BLOCK:
			{
				struct node_block *block = ((struct node_block*)parse_result->data);
				printf("%i\t%i\tBlock\t%s\n", level, block->line, block->name);
				generate_output(block->declaration_section, level+1);
				generate_output(block->concurrent_statements, level+1);
			}
				break;
			
			case TYPE_FUNCTION_BODY:
			{
				struct node_function_body *function = ((struct node_function_body*)parse_result->data);
				printf("%i\t%i\tFunc.\t%s\n", level, function->line, function->name);
				generate_output(function->declaration_section, level+1);
			}
				break;
			
			case TYPE_PROCEDURE_BODY:
			{
				struct node_procedure_body *proc = ((struct node_procedure_body*)parse_result->data);
				printf("%i\t%i\tProc.\t%s\n", level, proc->line, proc->name);
				generate_output(proc->declaration_section, level+1);
			}
				break;
			
			case TYPE_COMPONENT:
			{
				struct node_component *comp = ((struct node_component*)parse_result->data);
				printf("%i\t%i\tComp.\t%s\n", level, comp->line, comp->name);
			}
				break;
			
			case TYPE_IF_GENERATE:
			{
				struct node_generate *gen = ((struct node_generate*)parse_result->data);
				printf("%i\t%i\tIf gen.\t%s\n", level, gen->line, gen->name);
				generate_output(gen->declaration_section, level+1);
				generate_output(gen->concurrent_statements, level+1);
			}
				break;
			
			case TYPE_FOR_GENERATE:
			{
				struct node_generate *gen = ((struct node_generate*)parse_result->data);
				printf("%i\t%i\tFor gen.\t%s\n", level, gen->line, gen->name);
				generate_output(gen->declaration_section, level+1);
				generate_output(gen->concurrent_statements, level+1);
			}
				break;
			
			case TYPE_PROCESS:
			{
				struct node_process *process = ((struct node_process*)parse_result->data);
				if (process->name == NULL)
				{
					printf("%i\t%i\tProcess\tUNNAMED\n", level, process->line);
				}
				else
				{
					printf("%i\t%i\tProcess\t%s\n", level, process->line, process->name);
				}
				generate_output(process->declaration_section, level+1);
			}
				break;
				
			case TYPE_INSTANCE:
			{
				struct node_instance *inst = ((struct node_instance*)parse_result->data);
				printf("%i\t%i\tInstance\t%s\n", level, inst->line, inst->name);
			}
				break;
				
			case TYPE_PACKAGE_DECLARATION:
			{
				struct node_package_decl *pkg_decl = ((struct node_package_decl*)parse_result->data);
				printf("%i\t%i\tPackage\t%s\n", level, pkg_decl->line, pkg_decl->name);
				generate_output(pkg_decl->declarations, level+1);
			}
				break;
			
			case TYPE_PACKAGE_BODY:
			{
				struct node_package_body *pkg_body = ((struct node_package_body*)parse_result->data);
				printf("%i\t%i\tPackage\t%s\n", level, pkg_body->line, pkg_body->name);
				generate_output(pkg_body->declarations, level+1);
			}
				break;
			
			default:
				printf("Error: Unkown Object at level %i \n", level);
				break;
		}
		parse_result = parse_result->next; 
	}
}


void print_errors(struct ll_node *error_list)
{
	struct ll_node *node = error_list;
	struct parser_error* err;
	while(node != NULL)
	{
		err = (struct parser_error*)(node->data);
		printf("%i\t", err->line);
		switch (err->id)
		{
			case ERROR_MESSAGE:
				printf("%s", ((struct parser_error_1s*)(err))->s0 );
				break;
			case ERROR_LABEL_MISSMATCH:
				printf("Label missmatch (%s vs. %s)", ((struct parser_error_2s*)(err))->s0, ((struct parser_error_2s*)(err))->s1);
				break;
			case ERROR_ILLEGAL_SYMBOL:
				printf("Error: illigal symbol (%c)", ((struct parser_error_1c*)err)->c0);
				break;
			case ERROR_UNDERSCORE:
				printf("Indenifiers may not start or end with '_'");
				break;
			case ERROR_PORT_GENERIC_ORDER:
				printf("Wrong order of PORT and GENERIC clause");
				break;
			case ERROR_PORT_OBJECT_CLASS:
				printf("ports must have type signal(or none)");
				break;
			case ERROR_GENERIC_OBJECT_CLASS:
				printf("generics must have type constant(or none)");
				break;
			case ERROR_GENERIC_MODE:
				printf("generics must have mode IN (or none)");
				break;
			case ERROR_ENTITY_NOT_FOUND:
				printf("enity %s could not be found", ((struct parser_error_1s*)(err))->s0);
				break;
			case ERROR_COMPONENT_NOT_FOUND:
				printf("component %s could not be found", ((struct parser_error_1s*)(err))->s0);
				break;
			default:
				printf("Unknown Error id (This indicates a bug, please report)");
				break;
		}
		printf("\n");
		node = node->next;
	}
}

/*
entity can only be on the top level
*/
struct node_entity* find_entity(struct ll_node *parse_result, char *name)
{
	while(parse_result != NULL)
	{
		switch ( ((struct ast_node*)parse_result->data)->type )
		{
			case TYPE_ENTITY:
				if ( !strcmp( ((struct node_entity*)parse_result->data)->name, name) )
				{
					return parse_result->data;
				}
				break;
				
				default:
					break;
		}
		parse_result = parse_result->next; 
	}
	return NULL;
}



