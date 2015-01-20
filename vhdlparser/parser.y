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

   This parser (actually only the yacc grammer) is based on the 
   parser of the VAUL/freehdl project. (V0.0.7 http://www.freehdl.seul.org/)
   
   Original copyright holders:

   Copyright (C) University of Twente
   Department of Computer Science (INF/SPA)

   Copyright (C) Thomas Dettmer

   Copyright (C) 1994-1998, 2003 University of Dortmund
   Department of Electrical Engineering, AG SIV
*/


%code requires{

#define YYLTYPE_IS_DECLARED 

typedef struct YYLTYPE
{
	int first_line;
	int first_column;
	int last_line;
	int last_column;
	int start_position;
	int end_position;
} YYLTYPE;
}



%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>
#include <malloc.h>
#include "../ast.h"
#include "../linked_list.h"
#include "../parser_error.h"

/* Pass the argument to yyparse through to yylex. */
#define YYPARSE_PARAM scanner

#define YYINITDEPTH 10000
#define YYMAXDEPTH 100000


/* This is a hack to prevent the bison sceleton to declare a prototype
   for yyparse. Since yyparse is a qualified name, it can't be used
   in a prototype. */

//#define YYPARSE_PARAM dummy


#define YYDEBUG 1
#define YYERROR_VERBOSE

struct ll_node *parse_result = NULL;
struct ll_node *error_list = NULL;

char *find_entity_name = NULL; 
struct node_entity *found_entity = NULL;

char* find_component_name;
struct node_component *found_component;

extern int yylineno;

void yyerror(const char* str)
{
	//printf("Error near line %i!\n %s\n", yylineno, str);
	struct parser_error *err = (struct parser_error*)create_error_message(yylineno-1, strdup(str)); 
	error_list = ll_append_back(error_list, err);
}


# define YYLLOC_DEFAULT(Cur, Rhs, N)                      \
     do                                                        \
       if (N)                                                  \
         {                                                     \
           (Cur).first_line   = YYRHSLOC(Rhs, 1).first_line;   \
           (Cur).first_column = YYRHSLOC(Rhs, 1).first_column; \
           (Cur).last_line    = YYRHSLOC(Rhs, N).last_line;    \
           (Cur).last_column  = YYRHSLOC(Rhs, N).last_column;  \
           (Cur).start_position = YYRHSLOC(Rhs, 1).start_position;  \
           (Cur).end_position   = YYRHSLOC(Rhs, N).end_position;  \
         }                                                     \
       else                                                    \
         {                                                     \
           (Cur).first_line   = (Cur).last_line   =            \
             YYRHSLOC(Rhs, 0).last_line;                       \
           (Cur).first_column = (Cur).last_column =            \
             YYRHSLOC(Rhs, 0).last_column;                     \
           (Cur).start_position = YYRHSLOC(Rhs, 0).start_position;  \
           (Cur).end_position = YYRHSLOC(Rhs, 0).end_position; \
         }                                                     \
     while (0)

%}

//%glr-parser



%error-verbose
%locations
%pure_parser
%union {
	int num;
	char* str;
	void *nPtr;
	struct ast_node *node;
	struct ll_node *ll_node;
	struct text_section *txt_sec;
}


%token t_ACCESS            "[access]"
%token t_AFTER             "[after]"
%token t_ALIAS             "[alias]"
%token t_ALL               "[all]"
%token t_AND               "[and]"
%token t_ARCHITECTURE      "[architecture]"
%token skip_t_ARCHITECTURE
%token t_ARRAY             "[array]"
%token t_ASSERT            "[assert]"
%token t_ATTRIBUTE         "[attribute]"
%token t_BEGIN             "[begin]"
%token t_BLOCK             "[block]"
%token t_BODY              "[body]"
%token skip_t_BODY
%token t_BUFFER            "[buffer]"
%token t_BUS               "[bus]"
%token t_CASE              "[case]"
%token t_COMPONENT         "[component]"
%token t_CONFIGURATION     "[configuration]"
%token skip_t_CONFIGURATION
%token t_CONSTANT          "[constant]"
%token t_DISCONNECT        "[disconnect]"
%token t_DOWNTO            "[downto]"
%token t_ELSE              "[else]"
%token t_ELSIF             "[elsif]"
%token t_END               "[end]"
%token t_ENTITY            "[entity]"
%token t_EXIT              "[exit]"
%token t_FILE              "[file]"
%token t_FOR               "[for]"
%token t_FUNCTION          "[function]"
%token t_GENERATE          "[generate]"
%token t_GENERIC           "[generic]"
%token t_GUARDED           "[guarded]"
%token t_IF                "[if]"
%token t_IMPURE            "[impure]"
%token t_IN                "[in]"
%token t_INERTIAL          "[internal]"
%token t_INOUT             "[inout]"
%token t_IS                "[is]"
%token t_LABEL             "[label]"
%token t_LIBRARY           "[library]"
%token t_LINKAGE           "[linkage]"
%token t_LOOP              "[loop]"
%token t_MAP               "[map]"
%token t_NAND              "[nand]"
%token t_NEW               "[new]"
%token t_NEXT              "[next]"
%token t_NOR               "[nor]"
%token t_NULL              "[null]"
%token t_OF                "[of]"
%token t_ON                "[on]"
%token t_OPEN              "[open]"
%token t_OR                "[or]"
%token t_OTHERS            "[others]"
%token t_OUT               "[out]"
%token t_PACKAGE           "[package]"
%token t_PORT              "[port]"
%token t_POSTPONED         "[postponed]"
%token t_PROCEDURE         "[procedure]"
%token t_PROCESS           "[process]"
%token t_PURE              "[pure]"
%token t_RANGE             "[range]"
%token t_REVERSE_RANGE     "[reverse_range]"
%token t_RECORD            "[record]"
%token t_REGISTER          "[register]"
%token t_REJECT            "[reject]"
%token t_REPORT            "[report]"
%token t_RETURN            "[return]"
%token t_ROL               "[rol]"
%token t_ROR               "[ror]"
%token t_SELECT            "[select]"
%token t_SEVERITY          "[severity]"
%token t_SHARED            "[shared]" /* In VHDL-93, shared variables may be declared within an architecture, block, generate statement, or package */
%token t_SIGNAL            "[signal]"
%token t_SLA               "[sla]"
%token t_SLL               "[sll]"
%token t_SRA               "[sra]"
%token t_SRL               "[srl]"
%token t_SUBTYPE           "[subtype]"
%token t_THEN              "[then]"
%token t_TO                "[to]"
%token t_TRANSPORT         "[transport]"
%token t_TYPE              "[type]"
%token t_UNITS             "[units]"
%token t_UNTIL             "[until]"
%token t_USE               "[use]"
%token t_VARIABLE          "[variable]"
%token t_WAIT              "[wait]"
%token t_WHEN              "[when]"
%token t_WHILE             "[while]"
%token t_WITH              "[with]"
%token t_XNOR              "[xnor]"
%token t_XOR               "[xor]"

%token t_EQSym      "[=]"
%token t_NESym      "[/=]"
%token t_LTSym      "[<]"
%token t_LESym      "[<=]"
%token t_GTSym      "[>=]"
%token t_GESym      "[>]"
%token t_Plus       "[+]"
%token t_Minus      "[-]"
%token t_Ampersand  "[&]" 
%token t_Star       "[*]"
%token t_Slash      "[/]"
%token t_DoubleStar "[**]"


%nonassoc t_EQSym
%nonassoc t_NESym
%nonassoc t_LTSym
%nonassoc t_LESym
%nonassoc t_GTSym
%nonassoc t_GESym
%nonassoc t_SLL
%nonassoc t_SRL
%nonassoc t_SLA
%nonassoc t_SRA
%nonassoc t_ROL
%nonassoc t_ROR 
%left t_Plus t_Minus t_Ampersand MED_PRECEDENCE
%left t_Star t_Slash t_MOD t_REM
%nonassoc t_DoubleStar t_ABS t_NOT MAX_PRECEDENCE

%nonassoc t_Colon


%token t_Apostrophe  "[']"
%token t_LeftParen   "[(]"
%token t_RightParen  "[)]"
%token t_Comma       "[,]"
%token t_VarAsgn     "[:=]"
%token t_Colon       "[:]"
%token t_Semicolon   "[;]"

%token t_Arrow       "[=>]"
%token t_Box         "[<>]"
%token t_Bar         "[!]"
%token t_Dot         "[.]"

%token t_AbstractLit
%token t_CharacterLit
%token <str> t_Identifier "identifier"
%token <str> t_StringLit

%type <str> opt_package_end
%type <str> opt_package_body_end
%type <str> opt_t_Identifier
%type <str> designator
%type <str> opt_designator
%type <str> opt_architecture_end
%type <str> opt_entity_end
%type <node> package_declaration
%type <node> interface_element
%type <node> entity_declaration
%type <node> architecture_body
%type <node> comp_decl
%type <node> block_decltve_item
%type <node> generate_declarative_item
%type <node> proc_or_func_spec
%type <node> subprog_spec
%type <node> subprog_body
%type <node> package_body_decltve_item
%type <node> subprog_decltve_item
%type <node> concurrent_stat
%type <node> concurrent_stat_1
%type <node> concurrent_stat_with_label_1
%type <node> concurrent_stat_without_label_1
%type <node> concurrent_stat_with_label
%type <node> concurrent_stat_without_label
%type <node> proc_stat
%type <node> proc_decltve_item
%type <node> block_stat
%type <node> package_decltve_item
%type <ll_node> package_body_decl_part 
%type <ll_node> package_decl_part
%type <ll_node> block_decl_part
%type <ll_node> architecture_decl_part
%type <ll_node> subprog_body_decl_part
%type <ll_node> opt_concurrent_stats
%type <ll_node> concurrent_stats
%type <ll_node> proc_decl_part
%type <node> generate_stat
%type <node> generation_scheme
%type <node> if_scheme
%type <node> for_scheme
%type <node> comp_inst_stat
%type <node> package_body
%type <ll_node> generate_declarative_items_block
%type <ll_node> generate_declarative_items

%type <nPtr> opt_generic_and_port_clauses

%type <ll_node> generic_clause
%type <ll_node> port_clause
%type <ll_node> port_interface_list
%type <ll_node> generic_interface_list
%type <ll_node> idf_list

%type <ll_node> opt_more_interface_elements
%type <ll_node> interf_list_1
%type <ll_node> interf_list

%type <num> object_class
%type <num> opt_object_class
%type <num> mode
%type <num> opt_mode

%type <txt_sec> opt_var_init

%%

//start:
//	opt_design_unit {}	
//    ;

//opt_design_unit:    
//	/* nothing */  {}
//    |	design_unit    {}
//    ;

start:
	design_unit_list;

design_unit_list:
	/*nothing*/
	|
	design_unit design_unit_list
	;

designator:
	t_Identifier  {$$ = $1;}
	|
	t_StringLit   {$$ = $1;}
	;

literal:
	t_AbstractLit		    
        {}
    |	t_CharacterLit		    {}
    |	physical_literal_no_default {}
    |	t_NULL			    {}
    ;

enumeration_literal:
	t_CharacterLit	{}
    |	t_Identifier	{}
    ;

physical_literal:
	opt_t_AbstractLit t_Identifier
        {}
    ;

opt_t_AbstractLit:  
	/* nothing */	{}
    |	t_AbstractLit
    ;

physical_literal_no_default:
	t_AbstractLit t_Identifier
	 {}
	;

idf_list:
	  t_Identifier                  { $$ = ll_append_back(NULL, $1); }
	| idf_list t_Comma t_Identifier { $$ = ll_append_back($1, $3);   }
	;

/*------------------------------------------
--  Desing Unit
--------------------------------------------*/

design_unit:
	context_list lib_unit
    ;

context_list:
	/* nothing */  
    |	context_list context_item
    ;

lib_unit:
	  entity_declaration        { parse_result = ll_append_back(parse_result, $1); }
	| configuration_declaration
	| package_declaration       { parse_result = ll_append_back(parse_result, $1); }
	| architecture_body         { parse_result = ll_append_back(parse_result, $1); }
	| package_body              { parse_result = ll_append_back(parse_result, $1); }
	| skip_configuration_declaration
	| skip_architecture_body
	| skip_package_body
	;

context_item:
	  lib_clause	{}
	| use_clause	{}
	;

lib_clause:
	t_LIBRARY idf_list t_Semicolon	{}
    ;

use_clause:
	t_USE sel_list t_Semicolon	{}
    ;

sel_list:
	sel_name			{}
    |	sel_list t_Comma sel_name	{}
    ;

/*------------------------------------------
--  Library Units
--------------------------------------------*/

entity_declaration:
	t_ENTITY t_Identifier t_IS
		opt_generic_and_port_clauses
		entity_decl_part
		opt_entity_stats
	t_END opt_entity_end t_Semicolon
		{
			struct node_entity* entity = create_entity($2, @1.first_line);
			entity->generic_section = ((struct ll_node**)$4)[0];
			entity->port_section = ((struct ll_node**)$4)[1];
			$$ = (struct ast_node*)entity;
			if ($8 != NULL)
			{
				if (strcmp($8, $2))
				{
					struct parser_error_2s *err = create_error_label_missmatch(@2.first_line, $2, $8);
					error_list = ll_append_back(error_list, err);
				}
			}
			if (find_entity_name != NULL && !strcmp(entity->name, find_entity_name))
			{
				found_entity = entity;
			}
		}
	;

opt_generic_and_port_clauses:
	  /* nothing */
		{
			struct ll_node **generic_port_buffer = (struct ll_node**)malloc(2*sizeof(struct ll_node*));
			generic_port_buffer[0] = NULL;
			generic_port_buffer[1] = NULL;
			$$ = generic_port_buffer;
		}
	| generic_clause
		{
			struct ll_node **generic_port_buffer = (struct ll_node**)malloc(2*sizeof(struct ll_node*));
			generic_port_buffer[0] = $1;
			generic_port_buffer[1] = NULL;
			$$ = generic_port_buffer;
		}
	| port_clause
		{
			struct ll_node **generic_port_buffer = (struct ll_node**)malloc(2*sizeof(struct ll_node*));
			generic_port_buffer[0] = NULL;
			generic_port_buffer[1] = $1;
			$$ = generic_port_buffer;
		}
	| generic_clause port_clause
		{
			struct ll_node **generic_port_buffer = (struct ll_node**)malloc(2*sizeof(struct ll_node*));
			generic_port_buffer[0] = $1;
			generic_port_buffer[1] = $2;
			$$ = generic_port_buffer;
		}
	| port_clause generic_clause
		{
			struct ll_node **generic_port_buffer = (struct ll_node**)malloc(2*sizeof(struct ll_node*));
			generic_port_buffer[0] = $2;
			generic_port_buffer[1] = $1;
			$$ = generic_port_buffer;
			/*generate error message, because port and generic clause are in wrong order*/
			struct parser_error *err = create_error_id(@1.first_line, ERROR_PORT_GENERIC_ORDER);
			error_list = ll_append_back(error_list, err);
		}
	;

/*
opt_generic_clause:
	/ nothing /
    |	generic_clause
    ;
*/

generic_clause:
	t_GENERIC generic_interface_list t_Semicolon { $$ = $2; }
	;


/*
opt_port_clause:
	/ nothing /
    |	port_clause
    ;
*/

port_clause:
	t_PORT port_interface_list t_Semicolon { $$ = $2; }
	;

entity_decl_part:
	/* nothing */
    |	entity_decl_part entity_decltve_item
    ;

opt_entity_stats:
	/* nothing */ 
    |	t_BEGIN concurrent_stats
    ;

opt_entity_end:
	  t_ENTITY opt_t_Identifier   { $$ = $2; }
	| opt_t_Identifier            { $$ = $1; }
	;

opt_t_Identifier:
	  /* nothing */        { $$ = NULL; }
	| t_Identifier         { $$ = $1; }
	;

architecture_body:
	t_ARCHITECTURE t_Identifier t_OF t_Identifier t_IS
		architecture_decl_part
	t_BEGIN
		opt_concurrent_stats
	t_END opt_architecture_end t_Semicolon
		{
			int32_t line_no   = @1.first_line;
			char* entity_name = $4;
			char* arch_name   = $2;
			struct node_architecture *arch = create_archtitecture(arch_name, entity_name, line_no);
			arch->declaration_section = $6;
			arch->concurrent_statements = $8;
			$$ = (struct ast_node*)arch;
			
			if ($10 != NULL)
			{
				if (strcmp($10, $2))
				{
					struct parser_error_2s *err = create_error_label_missmatch(line_no, $2, $10);
					error_list = ll_append_back(error_list, err);
				}
			}
		}
	;

architecture_decl_part:
	/* nothing */ { $$ = NULL; }
	|	
	architecture_decl_part block_decltve_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

opt_architecture_end:
	  t_ARCHITECTURE opt_t_Identifier { $$ = $2; }
	| opt_t_Identifier                { $$ = $1; }
	;


configuration_declaration:
    t_CONFIGURATION t_Identifier t_OF t_Identifier t_IS
    {}
	configuration_decl_part
	block_config
    t_END opt_configuration_end t_Semicolon
    {};

configuration_decl_part:
    | configuration_decl_part config_decltve_item
    ;

opt_configuration_end:
	  t_CONFIGURATION opt_t_Identifier    {}
	| opt_t_Identifier                    {}
	;


package_declaration:
	t_PACKAGE t_Identifier t_IS
		package_decl_part
	t_END opt_package_end t_Semicolon
		{
			struct node_package_decl* pkg = create_package_decl($2, @1.first_line);
			pkg->declarations = $4;
			$$ = (struct ast_node*) pkg;
			
			if ($6 != NULL)
			{
				if (strcmp($6, $2))
				{
					struct parser_error_2s *err = create_error_label_missmatch(@2.first_line, $2, $6);
					error_list = ll_append_back(error_list, err);
				}
			}
		}
	;

package_decl_part:
	/*Nothing*/ { $$ = NULL; }
	|
	package_decl_part package_decltve_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

opt_package_end:
	  t_PACKAGE opt_t_Identifier  { $$ = $2; }
	| opt_t_Identifier            { $$ = $1; }
	;

package_body:
	t_PACKAGE t_BODY t_Identifier t_IS
		package_body_decl_part
	t_END opt_package_body_end t_Semicolon
		{
			struct node_package_body* pkg = create_package_body($3, @1.first_line);
			pkg->declarations = $5;
			$$ = (struct ast_node*) pkg;
			
			if ($7 != NULL)
			{
				if (strcmp($7, $3))
				{
					struct parser_error_2s *err = create_error_label_missmatch(@3.first_line, $3, $7);
					error_list = ll_append_back(error_list, err);
				}
			}
		}
	;

package_body_decl_part:
	/* nothing */  { $$ = NULL; }
	|
	package_body_decl_part package_body_decltve_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

opt_package_body_end:
	  t_PACKAGE t_BODY opt_t_Identifier  { $$ = $3; }
	| opt_t_Identifier                   { $$ = $1; }
	;

/*------------------------------------------
--  Declarative Item
--------------------------------------------*/

common_decltve_item:
	 type_decl
	| subtype_decl  
	| constant_decl
	| file_decl
	| alias_decl
	| subprog_decl
	| use_clause
	;

entity_decltve_item:
	common_decltve_item
    |	subprog_body
    |	attribute_decl
    |	attribute_spec
    |	disconnection_spec
    |	signal_decl
    ;

block_decltve_item:
	  common_decltve_item  { $$ = NULL; /*TODO*/ }
	| subprog_body         { $$ = $1; }
	| comp_decl            { $$ = $1; }
	| attribute_decl       { $$ = NULL; }
	| attribute_spec       { $$ = NULL; }
	| config_spec          { $$ = NULL; }
	| disconnection_spec   { $$ = NULL; }
	| signal_decl          { $$ = NULL; }
	| shared_variable_decl { $$ = NULL; }
	;

package_decltve_item:
	  common_decltve_item  { $$ = NULL; }
	| comp_decl            { $$ = $1; }
	| attribute_decl       { $$ = NULL; }
	| attribute_spec       { $$ = NULL; }
	| disconnection_spec   { $$ = NULL; }
	| signal_decl          { $$ = NULL; }
	| shared_variable_decl { $$ = NULL; } /*TODO: check where to put shared_variable_decl, maybe but it everywhere and complain that it is not possible*/
	;

package_body_decltve_item:
	  common_decltve_item  { $$ = NULL; }
	| subprog_body         { $$ = $1; }
	;

subprog_decltve_item:
	  common_decltve_item {$$ = NULL;}
	| subprog_body        {$$ = $1;}
	| attribute_decl      {$$ = NULL;}
	| attribute_spec      {$$ = NULL;}
	| variable_decl       {$$ = NULL;}
	;

proc_decltve_item:
	  common_decltve_item {$$ = NULL;}
	| subprog_body        {$$ = $1;}
	| attribute_decl      {$$ = NULL;}
	| attribute_spec      {$$ = NULL;}
	| variable_decl       {$$ = NULL;}
	;

config_decltve_item:
	attribute_spec
    |	use_clause	{}
    ;

/*------------------------------------------
--  Subprograms
--------------------------------------------*/

subprog_decl:
	subprog_spec t_Semicolon {}
	;

subprog_spec:
	proc_or_func_spec { $$ = $1; }
	;

proc_or_func_spec:
	t_PROCEDURE t_Identifier opt_interf_list
		{
			$$ = (struct ast_node*)create_procedure_decl($2, @1.first_line);
		}
	|
	pure_or_impure t_FUNCTION designator opt_interf_list t_RETURN subtype_indic
		{
			$$ = (struct ast_node*)create_function_decl($3, @2.first_line);
		}
	;

pure_or_impure:
	  /* nothing */   {}
	| t_PURE          {}
	| t_IMPURE        {}
	;

opt_interf_list:
	  /* nothing */	{}
	| interf_list
	;

subprog_body:
	subprog_spec t_IS
		subprog_body_decl_part
	t_BEGIN
		seq_stats
	t_END opt_function_or_procedure_t opt_designator t_Semicolon
		{
			if ($8 != NULL)
			{
				struct ast_labeled_node* node = (struct ast_labeled_node*)$1;
				if (strcmp(node->name, $8))
				{
					struct parser_error_2s* error = create_error_label_missmatch(node->line, node->name, $8);
					error_list = ll_append_back(error_list, error);
				}
			}
		
			if ($1->type == TYPE_FUNCTION_DECLARATION)
			{
				struct node_function_decl* decl = (struct node_function_decl*)$1;
				struct node_function_body* func = create_function_body(decl->name, decl->line);
				func->declaration_section = $3; 
				free($1);
				$$ = (struct ast_node*)func;
			}
			else if ($1->type == TYPE_PROCEDURE_DECLARATION)
			{
				struct node_procedure_decl* decl = (struct node_procedure_decl*)$1;
				struct node_procedure_body* proc = create_procedure_body(decl->name, decl->line);
				proc->declaration_section = $3;
				free($1);
				$$ = (struct ast_node*)proc;
			} 
		}
	;


opt_function_or_procedure_t:
	  /* nothing */  {}
	| t_PROCEDURE    {}
	| t_FUNCTION     {}
	;

opt_designator:
	  /* nothing */   { $$ = NULL; }
	| designator      { $$ = $1;   }
	;

subprog_body_decl_part:
	/* nothing */ { $$ = NULL; }
	|
	subprog_body_decl_part subprog_decltve_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;


/*--------------------------------------------------
--  Interface Lists and Associaton Lists
----------------------------------------------------*/

port_interface_list:
	interf_list_1
		{
			$$ = $1;
			struct ll_node *temp = $1;
			while(temp != NULL) 
			{
				struct node_interface_element* in_el = (struct node_interface_element*)temp->data;
				
				//in port interfaces OBJECT CLASS must be signal
				if (in_el->object_class == OC_NOT_SPECIFIED || in_el->object_class == OC_SIGNAL) {
					in_el->object_class = OC_SIGNAL;
				} else {
					error_list = ll_append_back(error_list, (struct parser_error*)create_error_id(in_el->line, ERROR_PORT_OBJECT_CLASS));
				}
				
				/*defualt mode is IN*/
				if (in_el->mode == MODE_NOT_SPECIFIED)
				{
					in_el->mode = MODE_IN;
				}
				
				//printf("%x\n", ((struct node_interface_element*)temp->data)->mode);
				temp = temp->next;
			}
		}
	;

generic_interface_list:
	interf_list_1
		{
			$$ = $1;
			struct ll_node *temp = $1;
			while(temp != NULL) 
			{
				struct node_interface_element* in_el = (struct node_interface_element*)temp->data;
				
				//in port interfaces OBJECT CLASS must be signal
				if (in_el->object_class == OC_NOT_SPECIFIED || in_el->object_class == OC_CONSTANT) {
					in_el->object_class = OC_CONSTANT;
				} else {
					error_list = ll_append_back(error_list, (struct parser_error*)create_error_id(in_el->line, ERROR_GENERIC_OBJECT_CLASS));
				}
				
				/*defualt mode is IN*/
				if (in_el->mode == MODE_NOT_SPECIFIED || in_el->mode == MODE_IN) {
					in_el->mode = MODE_IN;
				} else {
					error_list = ll_append_back(error_list, (struct parser_error*)create_error_id(in_el->line, ERROR_GENERIC_MODE));  
				}
				
				temp = temp->next;
			}
		}
	;

interf_list:
	interf_list_1   { $$ = NULL; /*TODO free memory*/}
	;

interf_list_1:
	t_LeftParen interface_element opt_more_interface_elements t_RightParen
		{
			$$ = ll_append_front($3, $2);
		}
	;

opt_more_interface_elements:
	/* nothing */     { $$ = NULL ; }
	|
	opt_more_interface_elements t_Semicolon interface_element
		{
			$$ = ll_append_back($1, $3);
		}
	;

/*
Used in
 > entity declaration (port/generic)
 > component declaration (port/generic)
 > function/procedure parameters
*/
interface_element:
	opt_object_class idf_list t_Colon opt_mode subtype_indic opt_t_BUS opt_var_init
		{
			struct node_interface_element *interface_node = create_interface_element(@2.first_line);
			interface_node->object_class = $1;
			interface_node->identifier_list = $2;
			interface_node->mode = $4;
			interface_node->data_type = malloc(sizeof(struct text_section));
			interface_node->data_type->start_position = @5.start_position;
			interface_node->data_type->end_position = @5.end_position;
			interface_node->init_value = $7;
			$$ = (struct ast_node*)interface_node;
			/*struct ll_node *temp = $2;
			while (temp != NULL)
			{
				printf("%s\n", (char*)temp->data);
				temp = temp->next;
			}*/
		}
	;

opt_t_BUS:
	  /* nothing */	{}
	| t_BUS	        {}
	;

opt_mode:
	  /* nothing */ { $$ = MODE_NOT_SPECIFIED; }
	| mode          { $$ = $1; }
	;
  
opt_object_class:
	  /* nothing */ { $$ = OC_NOT_SPECIFIED; }
	| object_class  { $$ = $1;               }
	;
  
mode:
	  t_IN       { $$ = MODE_IN; }
	| t_OUT      { $$ = MODE_OUT; }
	| t_INOUT    { $$ = MODE_INOUT; }
	| t_BUFFER   { $$ = MODE_BUFFER; }
	| t_LINKAGE  { $$ = MODE_LINKAGE; }
	;

association_list:
	t_LeftParen association_elements association_list_1 t_RightParen {}
	;

named_association_list:
	association_list {}
	;

association_list_1:
	  /* nothing */	{}
	| association_list_1 t_Comma association_elements
	;


gen_association_list:
	t_LeftParen gen_association_elements gen_association_list_1 t_RightParen
	{}
    ;

gen_association_list_1:
	/* nothing */	{}
    |	gen_association_list_1 t_Comma gen_association_elements
	{}
    ;

association_elements:
	formal_part t_Arrow actual_part
	{}
    |	actual_part
	{}
    ;

gen_association_elements:
    	association_elements
    |  	discrete_range1
    ;

formal_part:
	name                   {}
    |	formal_part t_Bar name {} 
    ;

actual_part:
	expr_or_attr
    |	t_OPEN	{}
    ;

/*--------------------------------------------------
--  Names and Expressions
----------------------------------------------------*/

mark: 
	  t_Identifier	{}
	| sel_name	{}
	;

expr:
	expr_or_attr
	{}
    ;

expr_or_attr:
	  and_expression	    {}
	| or_expression	    {}
	| xor_expression	    {} 
	| xnor_expression     {}
	| relation_or_attr    {}
	| relation t_NAND relation
	| relation t_NOR relation
	;

relation:
	relation_or_attr
	;

and_expression:
	relation t_AND relation
	 {}
    |	and_expression t_AND relation
	 {}
    ;

or_expression:
	relation t_OR relation
	 {}
    |	or_expression t_OR relation
	 {}
    ;

xor_expression:
	relation t_XOR relation
	 {}
    |	xor_expression t_XOR relation
	 {}
    ;

xnor_expression:
	relation t_XNOR relation
	 {}
    |	xnor_expression t_XNOR relation
	 {}
    ;

relation_or_attr:
        shift_expression_or_attr
    |   shift_expression t_EQSym shift_expression
        {}
    |   shift_expression t_NESym shift_expression
        {}
    |   shift_expression t_LTSym shift_expression
        {}
    |   shift_expression t_LESym shift_expression
        {}
    |   shift_expression t_GTSym shift_expression
        {}
    |   shift_expression t_GESym shift_expression
        {}
    ;

shift_expression:
        shift_expression_or_attr
        {}
    ;

shift_expression_or_attr:
	simple_expression_or_attr
    |   simple_expression t_SLL simple_expression
        {}
    |   simple_expression t_SRL simple_expression
        {}
    |   simple_expression t_SLA simple_expression
        {}
    |   simple_expression t_SRA simple_expression
        {}
    |   simple_expression t_ROL simple_expression
        {}
    |   simple_expression t_ROR simple_expression
        {}
    ;

simple_expression:
        simple_expression_or_attr
        {}
    ;

simple_expression_or_attr:
        signed_term_or_attr
    |   simple_expression t_Plus term
        {}
    |   simple_expression t_Minus term
        {}
    |   simple_expression t_Ampersand term
        {}
    ;

signed_term_or_attr:
        term_or_attr
    |	t_Plus term
        {}
    |	t_Minus term
        {}
    ; 

term:
        term_or_attr
        {}
    ;

term_or_attr:
	factor_or_attr
    |   term t_Star factor
        {}
    |   term t_Slash factor
        {}
    |   term t_MOD factor
        {}
    |   term t_REM factor
        {}
    ;

factor:
        factor_or_attr
        {}
    ;

factor_or_attr:
	primary_or_attr
    |   primary t_DoubleStar primary
        {}
    |   t_ABS primary
        {}
    |   t_NOT primary
        {}
    ;
 
primary:
	primary_or_attr
	{}
    ;

primary_or_attr:
	name		{}
    |	literal		{}
    |	aggregate	{}
    |	qualified_expr	{}
    |	allocator	{}
    |	t_LeftParen expr t_RightParen {}
    ;


name:
	mark
    |	name2
    ;

name2:
	t_StringLit	    {}
    |	attribute_name	    {}
    |	ifts_name
    ;  

sel_name:
	name t_Dot suffix   {}
    ;

simple_sel_name:
	simple_sel_name t_Dot t_Identifier  {}
    |	t_Identifier			    {}
    ;

suffix:
	designator	    {}
    |	t_CharacterLit	    {}
    |	t_ALL		    {}
    ;

ifts_name:
	mark gen_association_list   
	{}
    |	name2 gen_association_list
	{}
    ;


attribute_prefix:
    mark t_Apostrophe {}
    | name2 t_Apostrophe {}
    ;


range_attribute_name:
    attribute_prefix t_RANGE
         {}
    | attribute_prefix t_REVERSE_RANGE
         {}
    ;


attribute_name:
    attribute_prefix t_Identifier
	 {}
    | range_attribute_name {}
    ;

/*
attribute_name:
	mark t_Apostrophe t_Identifier
	 {}
    |	name2 t_Apostrophe t_Identifier
	 {}
    |	mark t_Apostrophe t_RANGE
	 {}
    |	name2 t_Apostrophe t_RANGE
	 {}
    ;
*/

range_attribute_name_with_param:
	range_attribute_name opt_attribute_param
	{}
    ;


/*
attribute_name_with_param:
	attribute_name opt_attribute_param
	{}
    ;
*/

opt_attribute_param:
	/* empty */ {}
    |	t_LeftParen expr t_RightParen
	{}
    ;

aggregate:
	rev_element_association_list2 t_RightParen
	{}
    |	t_LeftParen choices t_Arrow expr t_RightParen
	{}
    ;

rev_element_association_list2:
	t_LeftParen element_association t_Comma element_association
	{}
    |	rev_element_association_list2 t_Comma element_association
	{}
    ;

qualified_expr:
	mark t_Apostrophe t_LeftParen expr t_RightParen
	 {}
    |	mark t_Apostrophe aggregate
	 {}
    ;


allocator:
	t_NEW mark mark opt_index_association_list
	{}
    |	t_NEW mark opt_index_association_list
	{}
    |	t_NEW qualified_expr
	{}
    ;

opt_index_association_list:
	/* nothing */		{}
    |	gen_association_list	{}
    ;

/*--------------------------------------------------
--  Element Association and Choices
----------------------------------------------------*/

element_association:
	choices t_Arrow expr
	    {}
    |	expr
	    {}
    ;

choices:
	choice opt_more_choices
	{}
    ;

opt_more_choices:
	/* nothing */	{}
    |	opt_more_choices t_Bar choice
	{}	    
    ;

choice:
	expr_or_attr
	{}
    |	discrete_range1
	{}
    |	t_OTHERS
	{}
    ;

/*--------------------------------------------------
--  Type Declarations
----------------------------------------------------*/

decl_Identifier:
	t_Identifier {}
    ;

type_decl:
	t_TYPE decl_Identifier opt_type_def t_Semicolon
	{}
    ;

opt_type_def:
	/* nothing */		{}
    |	t_IS type_definition	{}
    ;

type_definition:
	  enumeration_type_definition     {}
	| range_constraint		{}
	| physical_type_definition        {}
	| unconstrained_array_definition  {}
	| constrained_array_definition    {}
	| record_type_definition          {}
	| access_type_definition          {}	
	| file_type_definition            {}
	;

enumeration_type_definition:
	t_LeftParen enumeration_literal_decls t_RightParen
	{}
    ;

enumeration_literal_decls:
	enumeration_literal opt_more_enumeration_literals
	{}
    ;

opt_more_enumeration_literals:
	/* nothing */			    {}
    |	t_Comma enumeration_literal_decls   {}
    ;

physical_type_definition:
	range_constraint t_UNITS
	    primary_unit_decl
	    secondary_unit_decls
	t_END t_UNITS
	{}
    ;

secondary_unit_decls:
	/* nothing */	{}
    |	secondary_unit_decls secondary_unit_decl
	{}
    ;

primary_unit_decl:
	t_Identifier t_Semicolon
	{}
    ;

secondary_unit_decl:
	t_Identifier t_EQSym physical_literal t_Semicolon
	{}
    ;

unconstrained_array_definition:
	t_ARRAY t_LeftParen index_subtype_defs t_RightParen t_OF subtype_indic
	{}
    ;

index_subtype_defs:
	index_subtype_definition opt_more_index_subtype_defs
	{}
    ;

opt_more_index_subtype_defs:
	/* nothing */
	{}
    |	t_Comma index_subtype_definition opt_more_index_subtype_defs
	{}
    ;

index_subtype_definition:
	mark t_RANGE t_Box
	{}
    ;

constrained_array_definition:
	t_ARRAY index_constraint t_OF subtype_indic
	{}
    ;

opt_record_end:
	  /* nothing */ 
	| t_Identifier
	| t_RECORD opt_t_Identifier
	;

record_type_definition:
	t_RECORD element_decl opt_more_element_decls t_END opt_record_end
	{}
	;

opt_more_element_decls:
	/* nothing */
	{}
    |	opt_more_element_decls element_decl
	{}
    ;

element_decl:
	idf_list t_Colon subtype_indic t_Semicolon
	{}
    ;

access_type_definition:
	t_ACCESS subtype_indic_opt_incomplete
	{}
    ;

file_type_definition:
	t_FILE t_OF mark
	{}
    ;

/*--------------------------------------------------
--  Subtypes and Constraints
----------------------------------------------------*/

subtype_decl:
	t_SUBTYPE decl_Identifier t_IS subtype_indic t_Semicolon
	{}
    ;

subtype_indic:
	subtype_indic_opt_incomplete
        {}
    ;
  
	
subtype_indic_opt_incomplete:
	mark opt_index_constraint   
        {}
    |	subtype_indic1
    ;

subtype_indic1:
	mark mark range_constraint
        {}
    |	mark range_constraint
        {}
    |	mark mark opt_index_constraint
        {}
    ;

opt_index_constraint:
	/* nothing */		{}
    |	gen_association_list	{}
    ;

range_constraint:
	t_RANGE range_spec2  {}
    ;

index_constraint:
	t_LeftParen discrete_range opt_more_discrete_ranges t_RightParen
	{}
    ;
  
opt_more_discrete_ranges:
	/* nothing */ 
	{}
    |	opt_more_discrete_ranges t_Comma discrete_range
	{}
    ;

discrete_range:
	subtype_indic
	{}
    |	range_spec
	{}
    ;

discrete_range1:
	subtype_indic1
	{}
    |	expr_or_attr direction expr
	{}
    ;


opt_direction_expr:
        /* nothing */
	{}
    |	direction expr
	{}
    ;


/* XXX - range_spec contains a shift/reduce conflict, because an
   attribute_name_with_param can be an expr.  range_spec2 solves this
   but can not be used as a discrete range because it conflicts with
   ordinary expressions.  I think.

   A possible solution would maybe be to elevate ranges to be
   expressions and disambiguate this purely on a semantic basis.  */

range_spec:
	range_attribute_name_with_param 
	{}
    |	expr direction expr 
	{}
    ;

range_spec2:
    	expr_or_attr opt_direction_expr
	{}
    ;

direction:
	  t_TO        {}
	| t_DOWNTO    {}
	;

/*--------------------------------------------------
--  Objects, Aliases, Files, Disconnections
----------------------------------------------------*/

constant_decl:
	t_CONSTANT idf_list t_Colon subtype_indic opt_var_init t_Semicolon
	{}
    ;
  

signal_decl:
	t_SIGNAL idf_list t_Colon subtype_indic
	    opt_signal_kind opt_var_init t_Semicolon
	{}
    ;

opt_signal_kind:
	/* nothing */	{}
    |	signal_kind
    ;

variable_decl:
	t_VARIABLE idf_list t_Colon subtype_indic opt_var_init t_Semicolon
	{}
    ;

shared_variable_decl:
	t_SHARED t_VARIABLE idf_list t_Colon subtype_indic opt_var_init t_Semicolon
	{}
    ;

opt_var_init:  
	  /* nothing */       { $$ = NULL;}
	| t_VarAsgn expr      
		{
			struct text_section *txt_sec = malloc(sizeof(struct text_section));
			txt_sec->start_position = @2.start_position;
			txt_sec->end_position = @2.end_position; 
			$$ = txt_sec;
		}
	;

object_class:
	  t_CONSTANT  { $$ = OC_CONSTANT; }
	| t_SIGNAL    { $$ = OC_SIGNAL;   }
	| t_VARIABLE  { $$ = OC_VARIABLE; }
	| t_FILE      { $$ = OC_FILE;     }
	;

signal_kind:
	  t_BUS	    {}
	| t_REGISTER  {}
	;

alias_decl:
	t_ALIAS t_Identifier t_Colon subtype_indic t_IS name t_Semicolon
	{}
    ;  

file_decl:
	t_FILE t_Identifier t_Colon subtype_indic opt_open_mode opt_file_name
	  t_Semicolon
	{}
    ;

opt_open_mode:
	/* nothing */
	{}
    |	t_OPEN expr
	{}
    ;

opt_file_name:
	/* nothing */
	{}
    |	t_IS opt_file_mode expr
	{}
    ;

opt_file_mode:
	  /* nothing */ {}
	| t_IN {}
	| t_OUT {}
	;

disconnection_spec:
	t_DISCONNECT signal_list t_Colon mark t_AFTER expr t_Semicolon
	{}
    ;

signal_list:
	signal_name opt_more_signal_list 
	{}
    |	t_OTHERS                  
	{}
    |	t_ALL
	{}
    ;

opt_more_signal_list:
	/* nothing */             {}
    |	opt_more_signal_list t_Comma signal_name
	{}
    ;

/*--------------------------------------------------
--  Attribute Declarations and Specifications
----------------------------------------------------*/

attribute_decl:
	t_ATTRIBUTE t_Identifier t_Colon mark t_Semicolon
	{}
    ;

attribute_spec:
	t_ATTRIBUTE t_Identifier t_OF entity_spec t_IS expr t_Semicolon
	{}
    ;

entity_spec:
	entity_name_list t_Colon entity_class
	{}
    ;

entity_name_list:
	designator opt_more_entity_name_list
	{}
    |	t_OTHERS
	{}
    |	t_ALL
	{}
    ;

opt_more_entity_name_list:
	/* nothing */	{}
    |	opt_more_entity_name_list t_Comma designator
	{}
    ;

entity_class:
	  t_ENTITY	{}
	| t_ARCHITECTURE  {}
	| t_PACKAGE       {}
	| t_CONFIGURATION {}
	| t_COMPONENT     {}
	| t_LABEL         {}
	| t_TYPE          {}
	| t_SUBTYPE       {}
	| t_PROCEDURE     {}
	| t_FUNCTION      {}
	| t_SIGNAL        {}
	| t_VARIABLE      {}
	| t_CONSTANT      {}
	;

/*--------------------------------------------------
--  Schemes
----------------------------------------------------*/

generation_scheme:
	if_scheme    { $$ = $1; }
	|
	for_scheme   { $$ = $1; }
	;

iteration_scheme:
	for_scheme   {}
    |	while_scheme {}
    ;

if_scheme:
	t_IF condition
		{
			struct ast_node *if_gen = (struct ast_node*)create_if_generate(NULL, @1.first_line);
			$$ = if_gen;
		}
	;

for_scheme:
	t_FOR t_Identifier t_IN discrete_range
		{
			struct ast_node *for_gen = (struct ast_node*)create_for_generate(NULL, @1.first_line);
			$$ = for_gen;
		}
	;

while_scheme:
	t_WHILE condition {}
    ;

/*--------------------------------------------------
--  Concurrent Statements
----------------------------------------------------*/

concurrent_stats:
	opt_concurrent_stats concurrent_stat
		{
			if ($2 != NULL) {
				$$ = ll_append_back($1, $2); 
			}else{
				$$ = NULL;
			}
		}
	;

opt_concurrent_stats:
	/* nothing */ { $$ = NULL; }
	|
	opt_concurrent_stats concurrent_stat
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

concurrent_stat:
	concurrent_stat_1 {$$ = $1;}
	;

concurrent_stat_1:
	concurrent_stat_without_label { $$ = $1; }
	|
	concurrent_stat_with_label    { $$ = $1; }
	;

concurrent_stat_without_label:
	concurrent_stat_without_label_1
		{
			if ($1 != NULL)
			{
				if ($1->type == TYPE_PROCESS || $1->type == TYPE_BLOCK )
				{
					struct ast_labeled_node* labeled_node = (struct ast_labeled_node*)$1;
					if (labeled_node->name != NULL)
					{
						struct parser_error_2s* err = create_error_label_missmatch(labeled_node->line, NULL, labeled_node->name);
						error_list = ll_append_back(error_list, err);
					}
				}
			}
			$$ = $1;
		}
	;

concurrent_stat_with_label:
	t_Identifier t_Colon 
	concurrent_stat_with_label_1
		{
			if ($3 != NULL)
			{
				if ($3->type == TYPE_PROCESS || $3->type == TYPE_BLOCK || $3->type == TYPE_IF_GENERATE || $3->type == TYPE_FOR_GENERATE)
				{
					struct ast_labeled_node* labeled_node = (struct ast_labeled_node*)$3;
					
					/*check name*/
					if (labeled_node->name == NULL)
					{
						labeled_node->name = $1;
					} else
					{
						if (strcmp($1,labeled_node->name))
						{
							struct parser_error_2s* err = create_error_label_missmatch(labeled_node->line, strdup($1), labeled_node->name);
							error_list = ll_append_back(error_list, err);
						}
					}
				}
				else if ($3->type == TYPE_INSTANCE)
				{
					struct node_instance* inst = (struct node_instance*)$3;
					inst->line = @2.first_line;
					inst->name = $1;
				}
			}
			$$ = $3; 
		}
	;

concurrent_stat_without_label_1:
	concurrent_assertion_stat     { $$ = NULL; }
	|
	concurrent_procedure_call     { $$ = NULL; }
	|
	concurrent_signal_assign_stat { $$ = NULL; }
	|
	proc_stat                     { $$ = $1; /*TODO*/ }
	;

concurrent_stat_with_label_1:
	block_stat                    { $$ = $1; /*TODO*/ }
	|
	comp_inst_stat                { $$ = (struct ast_node*)create_instance(NULL, 0); /*TODO: a little hack*/ }
	|
	concurrent_assertion_stat     { $$ = NULL; }
	|
	concurrent_procedure_call     { $$ = NULL; }
	|
	concurrent_signal_assign_stat { $$ = NULL; }
	|
	generate_stat                 { $$ = $1; }
	|
	proc_stat                     { $$ = $1; /*TODO*/ }
	;

block_stat:
	t_BLOCK block_guard opt_t_IS
		{
			$<node>$ = (struct ast_node*)create_block(@1.first_line);
		}
		block_generic_stuff
		{}
		block_port_stuff
		{}
		block_decl_part
			{
				((struct node_block*)$<node>4)->declaration_section = $block_decl_part;
			}
	t_BEGIN
	 	opt_concurrent_stats
	t_END t_BLOCK opt_t_Identifier t_Semicolon
		{
			((struct node_block*)$<node>4)->concurrent_statements = $opt_concurrent_stats;
			((struct node_block*)$<node>4)->name = $opt_t_Identifier;
			$$ = $<node>4;
		}
	;

block_decl_part:
	/* nothing */    { $$=NULL; }
	|
	block_decl_part block_decltve_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

block_port_stuff:
	/* nothing */			{}
    |	port_clause opt_port_map_semi   {}
    ;

block_generic_stuff:
	/* nothing */			    {}
    |	generic_clause opt_generic_map_semi {}
    ;

block_guard:
	/* nothing */			    {}
    |	t_LeftParen condition t_RightParen  {}
    ;

opt_port_map_semi:
	/* nothing */            {}
    |	port_map t_Semicolon     {}
    ;

opt_generic_map_semi:
	/* nothing */            {}
    |	generic_map t_Semicolon  {}
    ;

/*
comp_inst_stat:
	t_Identifier t_Colon comp_inst_unit
	    opt_generic_map
	    opt_port_map
	t_Semicolon
	{}
    ;
*/

comp_inst_stat:
	comp_mark
		t_GENERIC t_MAP named_association_list
		opt_port_map
	t_Semicolon
		{
		}
	|
	comp_mark
		t_PORT t_MAP named_association_list
		opt_generic_map
	t_Semicolon
		{
		}
	|
	comp_mark_with_keyword
		opt_generic_map
		opt_port_map
	t_Semicolon
		{
		}
	;

comp_mark_with_keyword:
	t_COMPONENT comp_mark                 
        {}
    |   t_ENTITY simple_sel_name opt_arch_id  
        {}
    |   t_CONFIGURATION mark
        {}
    ;

/* NOTE: component instantiation statements without a keyword look
**	 like concurrent procedure calls
*/

opt_generic_map:
	  /* nothing */  {}
	| generic_map
	;

generic_map:
	t_GENERIC t_MAP named_association_list    {}
    ;

opt_port_map:
	/* nothing */			{}
    |	port_map
    ;

port_map:
    	t_PORT t_MAP named_association_list	{}
    ;

concurrent_assertion_stat:
	  assertion_stat {}
	| t_POSTPONED assertion_stat {}
	;

concurrent_procedure_call:
	  mark t_Semicolon {}
	| procedure_call_stat_with_args {}
	| t_POSTPONED procedure_call_stat {}
	;

opt_postponed:
	  /* nothing */ {}
	| t_POSTPONED   {}
	;

concurrent_signal_assign_stat:
    	condal_signal_assign
    	{}

    |	t_POSTPONED condal_signal_assign
    	{}

|	sel_signal_assign
    	{}

|	t_POSTPONED sel_signal_assign
        {}
    ;

condal_signal_assign:
    	target t_LESym opt_guarded delay_mechanism condal_wavefrms t_Semicolon
    	{}
    ;

condal_wavefrms:
    	condal_wavefrms_1 wavefrm
    	{}
    ;

condal_wavefrms_1:
    	/* nothing */ {}
    |	condal_wavefrms_1 wavefrm t_WHEN condition t_ELSE
    	{}
    ;

wavefrm:
	wavefrm_element reverse_more_wavefrm
	{}
    ;

reverse_more_wavefrm:
	/* nothing */	{}
    |	reverse_more_wavefrm t_Comma wavefrm_element
	{}
    ;

wavefrm_element:
	expr opt_wavefrm_after
	{}
    ;

opt_wavefrm_after:
	/* nothing */	{}
    |	t_AFTER expr	{}
    ;

target:
	name	    {}
    |	aggregate   {}
    ;

opt_guarded:
	/* nothing */   {}
    |	t_GUARDED	{}
    ;

sel_signal_assign:
	t_WITH expr t_SELECT target t_LESym opt_guarded delay_mechanism
                                            sel_wavefrms t_Semicolon
        {}
    ;

sel_wavefrms:
	sel_wavefrms_1 wavefrm t_WHEN choices
        {}
    ;

sel_wavefrms_1:
	/* nothing */
        {}
    |	sel_wavefrms_1 wavefrm t_WHEN choices t_Comma
        {}
    ;

generate_stat:
	generation_scheme t_GENERATE
		generate_declarative_items_block
		concurrent_stats
	t_END t_GENERATE opt_t_Identifier t_Semicolon
		{
			struct node_generate *gen = (struct node_generate*)$1;
			gen->declaration_section = $3;
			gen->concurrent_statements = $4;
			gen->name = $7;
			$$ = (struct ast_node*)gen;
		}
	;

generate_declarative_items_block:
	/* nothing */                       { $$ = NULL; }
	|
	generate_declarative_items t_BEGIN  { $$ = $1; }
	;

generate_declarative_items:
	/* nothing */                       { $$ = NULL; }
	|
	generate_declarative_items generate_declarative_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

generate_declarative_item:
	  common_decltve_item     { $$ = NULL; }
	| subprog_body            { $$ = $1; }
	| comp_decl               { $$ = $1; }
	| attribute_decl          { $$ = NULL; }
	| attribute_spec          { $$ = NULL; }
	| config_spec             { $$ = NULL; }
	| disconnection_spec      { $$ = NULL; }
	| signal_decl             { $$ = NULL; }
	;

proc_stat:
	t_PROCESS opt_proc_sensitivity_list opt_t_IS
		proc_decl_part
	t_BEGIN
		seq_stats
	t_END opt_postponed t_PROCESS opt_t_Identifier t_Semicolon
		{
			struct node_process* proc = create_process(NULL, @1.first_line); 
			proc->declaration_section = $4;
			proc->name = $10;
			$$ = (struct ast_node*)proc;
		}
	|
	t_POSTPONED t_PROCESS opt_proc_sensitivity_list opt_t_IS
		proc_decl_part
	t_BEGIN
		seq_stats
	t_END opt_postponed t_PROCESS opt_t_Identifier t_Semicolon
		{
			struct node_process* proc = create_process(NULL, @2.first_line); 
			proc->declaration_section = $5;
			proc->name = $11;
			$$ = (struct ast_node*)proc;
		}
	;

opt_t_IS:
	/* nothing */
	|
	t_IS
	;

proc_decl_part:
	/* nothing */ { $$ = NULL; }
	|
	proc_decl_part proc_decltve_item
		{
			if($2 != NULL){
				$$ = ll_append_back($1, $2);
			}else{
				$$ = $1;
			}
		}
	;

opt_proc_sensitivity_list:
	/* nothing */				    {}
	|
	t_LeftParen sensitivity_list t_RightParen   {}
	; 

sensitivity_list:
	t_ALL   /*VHDL 2008*/
	|
	signal_name reverse_opt_more_sensitivities
	{}
    ;

reverse_opt_more_sensitivities:	 
	/* nothing */	{}
    |	reverse_opt_more_sensitivities t_Comma signal_name
	{}	
    ;

signal_name:
	name
	{}
    ;

/*--------------------------------------------------
--  Sequential Statements
----------------------------------------------------*/

seq_stats:
	rev_seq_stats	{}
    ;

rev_seq_stats:
	/* nothing */		{}
    |	rev_seq_stats seq_stat	
	{}
    ;

/*seq_stat: opt_label seq_stat_1;*/

seq_stat:
	seq_stat_1 
	| t_Identifier t_Colon seq_stat_1
	| t_Identifier t_VarAsgn unlabeled_variable_assign_stat
	| t_Identifier t_LESym unlabeled_assign_stat
;

unlabeled_variable_assign_stat:
	expr t_Semicolon
	{}
    ;

unlabeled_assign_stat:
	delay_mechanism wavefrm t_Semicolon 
	{}
    ;

seq_stat_1:
	 assertion_stat        {}
    |	report_stat           {}
    |	case_stat             {}
    |	exit_stat             {}
    |	if_stat               {}
    |	loop_stat             {}
    |	next_stat             {}
    |	null_stat             {}
    |	procedure_call_stat   {}
    |	return_stat           {}
    |	signal_assign_stat    {}
    |	variable_assign_stat  {}
    |	wait_stat             {}
    ;

assertion_stat:
	t_ASSERT condition opt_assertion_report opt_assertion_severity
	 t_Semicolon
	{}
    ;

report_stat:
	t_REPORT expr opt_assertion_severity t_Semicolon
	{}
    ;

opt_assertion_severity:
	/* nothing */
	{}
    |	t_SEVERITY expr
	{}
    ;

opt_assertion_report:
	/* nothing */
	{}
    |	t_REPORT expr
	{}
    ;

case_stat:
	t_CASE expr t_IS 
	    case_stat_alternative
	    more_case_stat_alternatives 
	t_END t_CASE opt_t_Identifier t_Semicolon /*modified to add optional labels*/
	{}
    ;

case_stat_alternative:
	t_WHEN choices t_Arrow seq_stats
	{}
    ;

more_case_stat_alternatives:
	/* nothing */
	{}
    |	more_case_stat_alternatives case_stat_alternative
	{}
    ;

if_stat:
	t_IF condition t_THEN seq_stats if_stat_1 if_stat_2 t_END t_IF opt_t_Identifier
	t_Semicolon /*modified added optional labels*/
	{}
    ;

if_stat_2:
	/* nothing */	    {}
    |	t_ELSE seq_stats    {}
    ;

if_stat_1:
	/* nothing */	    {}
    |	if_stat_1  t_ELSIF condition t_THEN seq_stats
	{}
    ;

condition:
	expr 
        {}
    ;

loop_stat:
	opt_iteration_scheme t_LOOP
	{}
	    seq_stats
	t_END t_LOOP opt_t_Identifier t_Semicolon
	{}
    ;

opt_iteration_scheme:
	/* nothing */	    {}
    |	iteration_scheme    {}
    ;

opt_label:
	/* nothing */	     {}
    |	t_Identifier t_Colon 
        {}
    ;

next_stat:
	t_NEXT opt_t_Identifier opt_when t_Semicolon
	{}
    ;

exit_stat:
	t_EXIT opt_t_Identifier opt_when t_Semicolon
	{}
    ;

opt_when:
	/* nothing */	    {}
    |	t_WHEN condition    {}
    ;

null_stat:
	t_NULL t_Semicolon  {}
    ;

procedure_call_stat:
        procedure_call_stat_without_args   {}
    |   procedure_call_stat_with_args      {}
    ;

procedure_call_stat_without_args:
	mark t_Semicolon
	{}
    ;

procedure_call_stat_with_args:
	name2 t_Semicolon
	{}
    ;

return_stat:
	t_RETURN opt_expr t_Semicolon 
	{}
    ;

opt_expr:
	/* nothing */	{}
    |	expr
    ;

signal_assign_stat:
	target t_LESym delay_mechanism wavefrm t_Semicolon 
	{}
    ;

delay_mechanism:
	/* nothing */  {}
    |   t_TRANSPORT    {}
    |   t_INERTIAL     {}
    |	t_REJECT expr t_INERTIAL 
        {}
    ;

variable_assign_stat:
	target t_VarAsgn expr t_Semicolon
	{}
    ;

wait_stat:
	t_WAIT opt_wait_on opt_wait_until opt_wait_for t_Semicolon
	{}
    ;

opt_wait_for:
	/* nothing */	{}
    |	t_FOR expr	{}
    ;

opt_wait_until:
	/* nothing */	    {}
    |	t_UNTIL condition   {}
    ;

opt_wait_on:
	/* nothing */		{}
    |	t_ON sensitivity_list	{}
    ;

/*--------------------------------------------------
--  Components and Configurations
----------------------------------------------------*/

comp_decl:
	t_COMPONENT t_Identifier opt_t_IS
		opt_generic_and_port_clauses
	t_END t_COMPONENT opt_t_Identifier t_Semicolon
		{
			struct node_component *component = create_component($2, @1.first_line);
			component->generic_section = ((struct ll_node**)$4)[0];
			component->port_section = ((struct ll_node**)$4)[1];
			$$ = (struct ast_node*)component;
			if ($7 != NULL)
			{
				if (strcmp($2,$7) )
				{
					struct parser_error *err = (struct parser_error*)create_error_label_missmatch(@1.first_line, $2, $7);
					error_list = ll_append_back(error_list, err);
				}
			}
			if (find_component_name != NULL && !strcmp(component->name, find_component_name))
			{
				found_component = component;
			}
		}
	;

block_config:
	t_FOR name {}
    	    use_clauses
    	    config_items
    	t_END t_FOR t_Semicolon
    	{}
    ;

config_items:
 	/* nothing */		    {}
    |	config_items config_item    {}
    ;

use_clauses:
	/* nothing */
    |	use_clauses use_clause {}
    ;

config_item:
	block_config  {}
    |	comp_config   {}
    ;

comp_config:
	t_FOR comp_spec opt_comp_binding_indic
    	{}
    	    opt_block_config
	t_END t_FOR t_Semicolon
    	{}
    ;

opt_block_config:
	/* nothing */	{}
    |	block_config	{}
    ;

opt_comp_binding_indic:
    	/* nothing */	{}
    |  	incremental_binding_indic t_Semicolon {}
    |	pre_binding_indic t_Semicolon {}
    ;

config_spec:
	t_FOR comp_spec binding_indic t_Semicolon
	{}
    ;

comp_spec:
	inst_list t_Colon comp_mark
	{}
    ;

comp_mark:
	mark
	{}
    ;

inst_list:
	idf_list    {}
    |	t_ALL	    {}
    |	t_OTHERS    {}
    ;

/* binding_indic et al is to be invoked with the component decl
** as the selected scope
*/

binding_indic:
    	pre_binding_indic {}
    ;

pre_binding_indic:
	{}
	t_USE entity_aspect
	{}
	opt_generic_map opt_port_map
	{}
    ;

incremental_binding_indic:
	generic_map opt_port_map
	{}
    |	port_map
    	{}
    ;

entity_aspect:
	t_ENTITY simple_sel_name opt_arch_id
	{}
    |	t_CONFIGURATION mark
	{}
    |	t_OPEN
	{}
    ;

opt_arch_id:
	/* nothing */				{}
    |	t_LeftParen t_Identifier t_RightParen	{}
    ;

/* This is a second copy of the grammar that does nothing.  It is used
   to skip over unwanted parts. */

skip_designator:
t_Identifier {}
|	t_StringLit {}
    ;

skip_literal:
	t_AbstractLit		    
{}
|	t_CharacterLit {}
|	skip_physical_literal_no_default {}
|	t_NULL {}
    ;

skip_enumeration_literal:
t_CharacterLit {}
|	t_Identifier {}
    ;

skip_physical_literal:
	skip_opt_t_AbstractLit t_Identifier
{}
    ;

skip_opt_t_AbstractLit:  
	/* skip_nothing */ {}
|	t_AbstractLit {}
    ;

skip_physical_literal_no_default:
	t_AbstractLit t_Identifier
{}
    ;

skip_idf_list:
	t_Identifier {}
|	skip_idf_list t_Comma t_Identifier {}
    ;

/*------------------------------------------
--  skip_Desing skip_Unit
--------------------------------------------*/

/*
skip_lib_clause:
skip_t_LIBRARY skip_idf_list t_Semicolon {}
    ;
*/


skip_use_clause:
t_USE skip_sel_list t_Semicolon {}
    ;


skip_sel_list:
skip_sel_name {}
|	skip_sel_list t_Comma skip_sel_name {}
    ;

/*------------------------------------------
--  skip_Library skip_Units
--------------------------------------------*/

/*
skip_entity_declaration:
    t_ENTITY t_Identifier t_IS
{}
	skip_opt_generic_and_port_clauses
	skip_entity_decl_part
{}
	skip_opt_entity_stats
    t_END skip_opt_entity_end t_Semicolon
    {};
*/


skip_opt_generic_and_port_clauses:

    |	skip_generic_clause
    |   skip_port_clause
    |   skip_generic_clause skip_port_clause
    |	skip_port_clause skip_generic_clause
    ;



/*
skip_opt_generic_clause:
    / skip_nothing /
    |	skip_generic_clause
    ;
*/


skip_generic_clause:
	t_GENERIC skip_generic_interface_list t_Semicolon
{}
    ;


/*
skip_opt_port_clause:
	/ skip_nothing /
    |	skip_port_clause
    ;
*/


skip_port_clause:	    
	t_PORT skip_port_interface_list t_Semicolon
{}
    ;


/*
skip_entity_decl_part:
	/ skip_nothing /
    |	skip_entity_decl_part skip_entity_decltve_item
    ;
*/

/*
skip_opt_entity_stats:
	/ skip_nothing / 
    |	t_BEGIN skip_concurrent_stats
    ;
*/

/*
skip_opt_entity_end:			
    t_ENTITY skip_opt_t_Identifier {}
|	skip_opt_t_Identifier {}
    ;
*/

skip_opt_t_Identifier:
/* skip_nothing */ {}
|	t_Identifier {}
    ;

skip_architecture_body:
    skip_t_ARCHITECTURE t_Identifier t_OF t_Identifier t_IS
    {}
	skip_architecture_decl_part
    t_BEGIN
{}
	skip_opt_concurrent_stats
    t_END skip_opt_architecture_end t_Semicolon
    {};

skip_architecture_decl_part:
    |	skip_architecture_decl_part skip_block_decltve_item
    ;

skip_opt_architecture_end:		    
    skip_t_ARCHITECTURE skip_opt_t_Identifier {}
|	skip_opt_t_Identifier {}
    ;


skip_configuration_declaration:
    skip_t_CONFIGURATION t_Identifier t_OF t_Identifier t_IS
    {}
	skip_configuration_decl_part
	skip_block_config
    t_END skip_opt_configuration_end t_Semicolon
    {};

skip_configuration_decl_part:
    | skip_configuration_decl_part skip_config_decltve_item
    ;

skip_opt_configuration_end:
    skip_t_CONFIGURATION skip_opt_t_Identifier {}
|	skip_opt_t_Identifier {}
    ;
    

/*
skip_package_declaration:
    t_PACKAGE t_Identifier t_IS
{}
	skip_package_decl_part
    t_END skip_opt_package_end t_Semicolon
    {};
*/

/*
skip_package_decl_part:
    |	skip_package_decl_part skip_package_decltve_item
    ;

skip_opt_package_end:
    t_PACKAGE skip_opt_t_Identifier {}
|	skip_opt_t_Identifier {}
    ;
*/

skip_package_body:
    t_PACKAGE skip_t_BODY t_Identifier t_IS
    {}
	skip_package_body_decl_part
    t_END skip_opt_package_body_end t_Semicolon
    {};

skip_package_body_decl_part:
    |	skip_package_body_decl_part skip_package_body_decltve_item
    ;

skip_opt_package_body_end:
    t_PACKAGE skip_t_BODY skip_opt_t_Identifier 
|	skip_opt_t_Identifier {}
    ;

/*------------------------------------------
--  skip_Declarative skip_Item
--------------------------------------------*/

skip_common_decltve_item:
	skip_type_decl
    |	skip_subtype_decl  
    |	skip_constant_decl
    |	skip_file_decl
    |	skip_alias_decl
    |	skip_subprog_decl
	|	skip_use_clause {}
    ;

/*
skip_entity_decltve_item:
	skip_common_decltve_item
    |	skip_subprog_body
    |	skip_attribute_decl
    |	skip_attribute_spec
    |	skip_disconnection_spec
    |	skip_signal_decl
    ;
*/

skip_block_decltve_item:
	skip_common_decltve_item
    |	skip_subprog_body
    |	skip_comp_decl
    |	skip_attribute_decl
    |	skip_attribute_spec
    |	skip_config_spec
    |	skip_disconnection_spec
    |	skip_signal_decl
    ;

/*
skip_package_decltve_item:
	skip_common_decltve_item
    |	skip_comp_decl
    |	skip_attribute_decl
    |	skip_attribute_spec
    |	skip_disconnection_spec
    |	skip_signal_decl
    ;
*/

skip_package_body_decltve_item:
	skip_common_decltve_item
    |	skip_subprog_body
    ;

skip_subprog_decltve_item:
	skip_common_decltve_item
    |	skip_subprog_body
    |	skip_attribute_decl
    |	skip_attribute_spec
    |	skip_variable_decl
    ;

skip_proc_decltve_item:
	skip_common_decltve_item
    |	skip_subprog_body
    |	skip_attribute_decl
    |	skip_attribute_spec
    |	skip_variable_decl
    ;

skip_config_decltve_item:
	skip_attribute_spec
	|	skip_use_clause {}
    ;

/*------------------------------------------
--  skip_Subprograms
--------------------------------------------*/

skip_subprog_decl:
	skip_subprog_spec t_Semicolon
{}
    ;

skip_subprog_spec:
	skip_proc_or_func_spec
{}
    ;

skip_proc_or_func_spec:
	t_PROCEDURE t_Identifier skip_opt_interf_list
{}
    |	skip_pure_or_impure t_FUNCTION skip_designator skip_opt_interf_list
          t_RETURN skip_subtype_indic
{}
    ;

skip_pure_or_impure:
    /* skip_nothing */ {}
|   t_PURE {}
|   t_IMPURE {}
    ;

skip_opt_interf_list:
/* skip_nothing */ {}
    |	skip_interf_list
    ;

skip_subprog_body:
	skip_subprog_spec t_IS
{}
	    skip_subprog_body_decl_part
	t_BEGIN
	    skip_seq_stats
	t_END skip_opt_designator t_Semicolon
{}
    ;

skip_opt_designator:
	    /* skip_nothing */ {}
|	skip_designator {}
    ;

skip_subprog_body_decl_part:
	/* skip_nothing */
    |	skip_subprog_body_decl_part skip_subprog_decltve_item
    ;


/*--------------------------------------------------
--  skip_Interface skip_Lists skip_and skip_Associaton skip_Lists
----------------------------------------------------*/

skip_port_interface_list:
{}
	skip_interf_list_1
{}
    ;

skip_generic_interface_list:
{}
	skip_interf_list_1
{}
    ;

skip_interf_list:
{}
        skip_interf_list_1
{}
    ;

skip_interf_list_1:
	t_LeftParen skip_interface_element skip_opt_more_interface_elements t_RightParen
{}
    ;

skip_opt_more_interface_elements:
	/* skip_nothing */ {}
    |	skip_opt_more_interface_elements t_Semicolon skip_interface_element
{}
    ;

skip_interface_element:
	skip_opt_object_class skip_idf_list t_Colon skip_opt_mode skip_subtype_indic
	    skip_opt_t_BUS skip_opt_var_init
{}
    ;

skip_opt_t_BUS:
	/* skip_nothing */ {}
|	t_BUS {}
    ;

skip_opt_mode:
/* skip_nothing */ {}
    |	skip_mode
    ;
  
skip_opt_object_class:
    /* skip_nothing */ {}
    |	skip_object_class
    ;
  
skip_mode:
    t_IN {}
|	t_OUT {}
|	t_INOUT {}
|	t_BUFFER {}
|	t_LINKAGE {}
    ;

skip_association_list:
	t_LeftParen skip_association_elements skip_association_list_1 t_RightParen
{}
    ;

skip_named_association_list:
	skip_association_list
{}
    ;

skip_association_list_1:
	/* skip_nothing */ {}
    |	skip_association_list_1 t_Comma skip_association_elements
{}
    ;


skip_gen_association_list:
	t_LeftParen skip_gen_association_elements skip_gen_association_list_1 t_RightParen
{}
    ;

skip_gen_association_list_1:
	/* skip_nothing */ {}
    |	skip_gen_association_list_1 t_Comma skip_gen_association_elements
{}
    ;

skip_association_elements:
	skip_formal_part t_Arrow skip_actual_part
{}
    |	skip_actual_part
{}
    ;

skip_gen_association_elements:
    	skip_association_elements
    |  	skip_discrete_range1
    ;

skip_formal_part:
	skip_name {}
|	skip_formal_part t_Bar skip_name {} 
    ;

skip_actual_part:
	skip_expr_or_attr
	|	t_OPEN {}
    ;

/*--------------------------------------------------
--  skip_Names skip_and skip_Expressions
----------------------------------------------------*/

skip_mark: 
	t_Identifier {}
|	skip_sel_name {}
    ;

skip_expr:
	skip_expr_or_attr
{}
    ;

skip_expr_or_attr:
	skip_and_expression {}
|	skip_or_expression {}
|	skip_xor_expression {} 
|   skip_xnor_expression {}
|	skip_relation_or_attr {}
    |	skip_relation t_NAND skip_relation
{}
    |	skip_relation t_NOR skip_relation
{}
    ;

skip_relation:
	skip_relation_or_attr
	{}
    ;

skip_and_expression:
	skip_relation t_AND skip_relation
	 {}
    |	skip_and_expression t_AND skip_relation
	 {}
    ;

skip_or_expression:
	skip_relation t_OR skip_relation
	 {}
    |	skip_or_expression t_OR skip_relation
	 {}
    ;

skip_xor_expression:
	skip_relation t_XOR skip_relation
	 {}
    |	skip_xor_expression t_XOR skip_relation
	 {}
    ;

skip_xnor_expression:
	skip_relation t_XNOR skip_relation
	 {}
    |	skip_xnor_expression t_XNOR skip_relation
	 {}
    ;

skip_relation_or_attr:
        skip_shift_expression_or_attr
    |   skip_shift_expression t_EQSym skip_shift_expression
        {}
    |   skip_shift_expression t_NESym skip_shift_expression
        {}
    |   skip_shift_expression t_LTSym skip_shift_expression
        {}
    |   skip_shift_expression t_LESym skip_shift_expression
        {}
    |   skip_shift_expression t_GTSym skip_shift_expression
        {}
    |   skip_shift_expression t_GESym skip_shift_expression
        {}
    ;

skip_shift_expression:
        skip_shift_expression_or_attr
        {}
    ;

skip_shift_expression_or_attr:
	skip_simple_expression_or_attr
    |   skip_simple_expression t_SLL skip_simple_expression
        {}
    |   skip_simple_expression t_SRL skip_simple_expression
        {}
    |   skip_simple_expression t_SLA skip_simple_expression
        {}
    |   skip_simple_expression t_SRA skip_simple_expression
        {}
    |   skip_simple_expression t_ROL skip_simple_expression
        {}
    |   skip_simple_expression t_ROR skip_simple_expression
        {}
    ;

skip_simple_expression:
        skip_simple_expression_or_attr
        {}
    ;

skip_simple_expression_or_attr:
        skip_signed_term_or_attr
    |   skip_simple_expression t_Plus skip_term
        {}
    |   skip_simple_expression t_Minus skip_term
        {}
    |   skip_simple_expression t_Ampersand skip_term
        {}
    ;

skip_signed_term_or_attr:
        skip_term_or_attr
    |	t_Plus skip_term
        {}
    |	t_Minus skip_term
        {}
    ; 

skip_term:
        skip_term_or_attr
        {}
    ;

skip_term_or_attr:
	skip_factor_or_attr
    |   skip_term t_Star skip_factor
        {}
    |   skip_term t_Slash skip_factor
        {}
    |   skip_term t_MOD skip_factor
        {}
    |   skip_term t_REM skip_factor
        {}
    ;

skip_factor:
        skip_factor_or_attr
        {}
    ;

skip_factor_or_attr:
	skip_primary_or_attr
    |   skip_primary t_DoubleStar skip_primary
        {}
    |   t_ABS skip_primary
        {}
    |   t_NOT skip_primary
        {}
    ;

skip_primary:
	skip_primary_or_attr
	{}
    ;

skip_primary_or_attr:
    skip_name {}
|	skip_literal {}
|	skip_aggregate {}
|	skip_qualified_expr {}
|	skip_allocator {}
|	t_LeftParen skip_expr t_RightParen {}
    ;

skip_name:
	skip_mark
    |	skip_name2
    ;

skip_name2:
	t_StringLit {}
|	skip_attribute_name {}
    |	skip_ifts_name
    ;  

skip_sel_name:
    skip_name t_Dot skip_suffix {}
    ;

skip_simple_sel_name:
    skip_simple_sel_name t_Dot t_Identifier {}
|	t_Identifier {}
    ;

skip_suffix:
skip_designator {}
|	t_CharacterLit {}
|	t_ALL {}
    ;

skip_ifts_name:
	skip_mark skip_gen_association_list   
{}
    |	skip_name2 skip_gen_association_list
{}
    ;


skip_attribute_prefix:
    skip_mark t_Apostrophe {}
    | skip_name2 t_Apostrophe {}
    ;


skip_range_attribute_name:
    skip_attribute_prefix t_RANGE {}
    | skip_attribute_prefix t_REVERSE_RANGE {}
    ;


skip_attribute_name:
    skip_attribute_prefix t_Identifier
    | skip_range_attribute_name {}
    ;



/*
skip_attribute_name:
	skip_mark t_Apostrophe t_Identifier
{}
    |	skip_name2 t_Apostrophe t_Identifier
{}
    |	skip_mark t_Apostrophe t_RANGE
{}
    |	skip_name2 t_Apostrophe t_RANGE
{}
    ;
*/

skip_range_attribute_name_with_param:
	skip_range_attribute_name skip_opt_attribute_param
{}
    ;

skip_opt_attribute_param:
	/* skip_empty */ {}
    |	t_LeftParen skip_expr t_RightParen
{}
    ;

skip_aggregate:
	skip_rev_element_association_list2 t_RightParen
{}
    |	t_LeftParen skip_choices t_Arrow skip_expr t_RightParen
{}
    ;

skip_rev_element_association_list2:
	t_LeftParen skip_element_association t_Comma skip_element_association
{}
    |	skip_rev_element_association_list2 t_Comma skip_element_association
{}
    ;

skip_qualified_expr:
	skip_mark t_Apostrophe t_LeftParen skip_expr t_RightParen
{}
    |	skip_mark t_Apostrophe skip_aggregate
{}
    ;


skip_allocator:
	t_NEW skip_mark skip_mark skip_opt_index_association_list
{}
    |	t_NEW skip_mark skip_opt_index_association_list
{}
    |	t_NEW skip_qualified_expr
{}
    ;

skip_opt_index_association_list:
    /* skip_nothing */ {}
|	skip_gen_association_list {}
    ;

/*--------------------------------------------------
--  skip_Element skip_Association skip_and skip_Choices
----------------------------------------------------*/

skip_element_association:
	skip_choices t_Arrow skip_expr
{}
    |	skip_expr
{}
    ;

skip_choices:
	skip_choice skip_opt_more_choices
{}
    ;

skip_opt_more_choices:
	/* skip_nothing */ {}
    |	skip_opt_more_choices t_Bar skip_choice
{}	    
    ;

skip_choice:
	skip_expr_or_attr
{}
    |	skip_discrete_range1
{}
    |	t_OTHERS
{}
    ;

/*--------------------------------------------------
--  skip_Type skip_Declarations
----------------------------------------------------*/

skip_decl_Identifier:
    t_Identifier {}
    ;

skip_type_decl:
	t_TYPE skip_decl_Identifier skip_opt_type_def t_Semicolon
{}
    ;

skip_opt_type_def:
	/* skip_nothing */ {}
|	t_IS skip_type_definition {}
    ;

skip_type_definition:
skip_enumeration_type_definition {}
|	skip_range_constraint {}
|	skip_physical_type_definition {}
|	skip_unconstrained_array_definition {}
|	skip_constrained_array_definition {}
|	skip_record_type_definition {}
|	skip_access_type_definition {}	
|	skip_file_type_definition {}
    ;

skip_enumeration_type_definition:
	t_LeftParen skip_enumeration_literal_decls t_RightParen
{}
    ;

skip_enumeration_literal_decls:
	skip_enumeration_literal skip_opt_more_enumeration_literals
{}
    ;

skip_opt_more_enumeration_literals:
	/* skip_nothing */ {}
|	t_Comma skip_enumeration_literal_decls {}
    ;

skip_physical_type_definition:
	skip_range_constraint t_UNITS
	    skip_primary_unit_decl
	    skip_secondary_unit_decls
	t_END t_UNITS
{}
    ;

skip_secondary_unit_decls:
	/* skip_nothing */ {}
    |	skip_secondary_unit_decls skip_secondary_unit_decl
{}
    ;

skip_primary_unit_decl:
	t_Identifier t_Semicolon
{}
    ;

skip_secondary_unit_decl:
	t_Identifier t_EQSym skip_physical_literal t_Semicolon
{}
    ;

skip_unconstrained_array_definition:
	t_ARRAY t_LeftParen skip_index_subtype_defs t_RightParen t_OF skip_subtype_indic
{}
    ;

skip_index_subtype_defs:
	skip_index_subtype_definition skip_opt_more_index_subtype_defs
{}
    ;

skip_opt_more_index_subtype_defs:
	/* skip_nothing */
{}
    |	t_Comma skip_index_subtype_definition skip_opt_more_index_subtype_defs
{}
    ;

skip_index_subtype_definition:
	skip_mark t_RANGE t_Box
{}
    ;

skip_constrained_array_definition:
	t_ARRAY skip_index_constraint t_OF skip_subtype_indic
{}
    ;

skip_record_type_definition:
	t_RECORD skip_element_decl skip_opt_more_element_decls t_END t_RECORD
{}
    ;

skip_opt_more_element_decls:
	/* skip_nothing */
{}
    |	skip_opt_more_element_decls skip_element_decl
{}
    ;

skip_element_decl:
	skip_idf_list t_Colon skip_subtype_indic t_Semicolon
{}
    ;

skip_access_type_definition:
	t_ACCESS skip_subtype_indic
{}
    ;

skip_file_type_definition:
	t_FILE t_OF skip_mark
{}
    ;

/*--------------------------------------------------
--  skip_Subtypes skip_and skip_Constraints
----------------------------------------------------*/

skip_subtype_decl:
	t_SUBTYPE skip_decl_Identifier t_IS skip_subtype_indic t_Semicolon
{}
    ;

skip_subtype_indic:
	skip_mark skip_opt_index_constraint {}
    |	skip_subtype_indic1
    ;

skip_subtype_indic1:
	skip_mark skip_mark skip_range_constraint
{}
    |	skip_mark skip_range_constraint
{}
    |	skip_mark skip_mark skip_opt_index_constraint
{}
    ;

skip_opt_index_constraint:
    /* skip_nothing */ {}
|	skip_gen_association_list {}
    ;

skip_range_constraint:
t_RANGE skip_range_spec2 {}
    ;

skip_index_constraint:
	t_LeftParen skip_discrete_range skip_opt_more_discrete_ranges t_RightParen
{}
    ;
  
skip_opt_more_discrete_ranges:
	/* skip_nothing */ 
{}
    |	skip_opt_more_discrete_ranges t_Comma skip_discrete_range
{}
    ;

skip_discrete_range:
	skip_subtype_indic
{}
    |	skip_range_spec
{}
    ;

skip_discrete_range1:
	skip_subtype_indic1
{}
    |	skip_expr_or_attr skip_direction skip_expr
{}
    ;


skip_opt_direction_expr:
        /* skip_nothing */
{}
    |	skip_direction skip_expr
{}
    ;


/* skip_XXX - skip_range_spec skip_contains skip_a skip_shift/skip_reduce skip_conflict, skip_because skip_an
   skip_attribute_name_with_param skip_can skip_be skip_an skip_expr.  skip_range_spec2 skip_solves skip_this
   skip_but skip_can skip_not skip_be skip_used skip_as skip_a skip_discrete skip_range skip_because skip_it skip_conflicts skip_with
   skip_ordinary skip_expressions.  skip_I skip_think.

   skip_A skip_possible skip_solution skip_would skip_maybe skip_be skip_to skip_elevate skip_ranges skip_to skip_be
   skip_expressions skip_and skip_disambiguate skip_this skip_purely skip_on skip_a skip_semantic skip_basis.  */

skip_range_spec:
	skip_range_attribute_name_with_param 
{}
    |	skip_expr skip_direction skip_expr 
{}
    ;

skip_range_spec2:
    	skip_expr_or_attr skip_opt_direction_expr
{}
    ;

skip_direction:
	t_TO {}
|	t_DOWNTO {}
    ;

/*--------------------------------------------------
--  skip_Objects, skip_Aliases, skip_Files, skip_Disconnections
----------------------------------------------------*/

skip_constant_decl:
	t_CONSTANT skip_idf_list t_Colon skip_subtype_indic skip_opt_var_init t_Semicolon
{}
    ;
  

skip_signal_decl:
	t_SIGNAL skip_idf_list t_Colon skip_subtype_indic
	    skip_opt_signal_kind skip_opt_var_init t_Semicolon
{}
    ;

skip_opt_signal_kind:
	/* skip_nothing */ {}
    |	skip_signal_kind
    ;

skip_variable_decl:
	t_VARIABLE skip_idf_list t_Colon skip_subtype_indic skip_opt_var_init t_Semicolon
{}
    ;

skip_opt_var_init:  
	/* skip_nothing */ {}
|	t_VarAsgn skip_expr {}
    ;

skip_object_class:
t_CONSTANT {}
|	t_SIGNAL {}
|	t_VARIABLE {}
|	t_FILE {}
    ;

skip_signal_kind:
t_BUS {}
|	t_REGISTER {}
    ;

skip_alias_decl:
	t_ALIAS t_Identifier t_Colon skip_subtype_indic t_IS skip_name t_Semicolon
{}
    ;  

skip_file_decl:
	t_FILE t_Identifier t_Colon skip_subtype_indic skip_opt_open_mode skip_opt_file_name
	  t_Semicolon
{}
    ;

skip_opt_open_mode:
	/* skip_nothing */
{}
    |	t_OPEN skip_expr
{}
    ;

skip_opt_file_name:
	/* skip_nothing */
{}
    |	t_IS skip_opt_file_mode skip_expr
{}
    ;

skip_opt_file_mode:
        /* nothing */
        {}
    |   t_IN
        {}
    |   t_OUT
        {}
    ;

skip_disconnection_spec:
	t_DISCONNECT skip_signal_list t_Colon skip_mark t_AFTER skip_expr t_Semicolon
{}
    ;

skip_signal_list:
	skip_signal_name skip_opt_more_signal_list 
{}
    |	t_OTHERS                  
{}
    |	t_ALL
{}
    ;

skip_opt_more_signal_list:
    /* skip_nothing */ {}
    |	skip_opt_more_signal_list t_Comma skip_signal_name
{}
    ;

/*--------------------------------------------------
--  skip_Attribute skip_Declarations skip_and skip_Specifications
----------------------------------------------------*/

skip_attribute_decl:
	t_ATTRIBUTE t_Identifier t_Colon skip_mark t_Semicolon
{}
    ;

skip_attribute_spec:
	t_ATTRIBUTE t_Identifier t_OF skip_entity_spec t_IS skip_expr t_Semicolon
{}
    ;

skip_entity_spec:
	skip_entity_name_list t_Colon skip_entity_class
{}
    ;

skip_entity_name_list:
	skip_designator skip_opt_more_entity_name_list
{}
    |	t_OTHERS
{}
    |	t_ALL
{}
    ;

skip_opt_more_entity_name_list:
    /* skip_nothing */ {}
    |	skip_opt_more_entity_name_list t_Comma skip_designator
{}
    ;

skip_entity_class:
    t_ENTITY {}
|	t_ARCHITECTURE {}
|	t_PACKAGE {}
|	t_CONFIGURATION {}
|	t_COMPONENT {}
|	t_LABEL {}
|	t_TYPE {}
|	t_SUBTYPE {}
|	t_PROCEDURE {}
|	t_FUNCTION {}
|	t_SIGNAL {}
|	t_VARIABLE {}
|	t_CONSTANT {}
    ;

/*--------------------------------------------------
--  skip_Schemes
----------------------------------------------------*/

skip_generation_scheme:
skip_if_scheme {}
|	skip_for_scheme {}
    ;

skip_iteration_scheme:
skip_for_scheme {}
|	skip_while_scheme {}
    ;

skip_if_scheme:
t_IF skip_condition {}
    ;

skip_for_scheme:
	t_FOR t_Identifier t_IN skip_discrete_range
{}
    ;

skip_while_scheme:
	t_WHILE skip_condition {}
    ;

/*--------------------------------------------------
--  skip_Concurrent skip_Statements
----------------------------------------------------*/

skip_concurrent_stats:
	skip_opt_concurrent_stats skip_concurrent_stat
    ;

skip_opt_concurrent_stats:
	/* nothing */
    |	skip_opt_concurrent_stats skip_concurrent_stat
    ;

skip_concurrent_stat:
        {}
        skip_concurrent_stat_1
    ;

skip_concurrent_stat_1:
        skip_concurrent_stat_without_label
    |   skip_concurrent_stat_with_label
    ;

skip_concurrent_stat_without_label:
	skip_concurrent_stat_without_label_1
	{}
    ;

skip_concurrent_stat_with_label:
        t_Identifier t_Colon 
        {}
	skip_concurrent_stat_with_label_1
	{}
    ;

skip_concurrent_stat_without_label_1:
    	skip_concurrent_assertion_stat
    |	skip_concurrent_procedure_call
    |	skip_concurrent_signal_assign_stat
    |	skip_proc_stat
    ;

skip_concurrent_stat_with_label_1:
	skip_block_stat
    |	skip_comp_inst_stat
    |	skip_concurrent_assertion_stat
    |	skip_concurrent_procedure_call
    |	skip_concurrent_signal_assign_stat
    |	skip_generate_stat
    |	skip_proc_stat
    ;

skip_block_stat:
	t_BLOCK skip_block_guard skip_opt_t_IS
{}
	    skip_block_generic_stuff
{}
	    skip_block_port_stuff
{}
	    skip_block_decl_part
	t_BEGIN
{}
	    skip_opt_concurrent_stats
	t_END t_BLOCK skip_opt_t_Identifier t_Semicolon
{}
    ;

skip_block_decl_part:
	/* skip_nothing */
    |	skip_block_decl_part skip_block_decltve_item
    ;

skip_block_port_stuff:
    /* skip_nothing */ {}
|	skip_port_clause skip_opt_port_map_semi {}
    ;

skip_block_generic_stuff:
/* skip_nothing */ {}
|	skip_generic_clause skip_opt_generic_map_semi {}
    ;

skip_block_guard:
/* skip_nothing */ {}
|	t_LeftParen skip_condition t_RightParen {}
    ;

skip_opt_port_map_semi:
/* skip_nothing */ {}
|	skip_port_map t_Semicolon {}
    ;

skip_opt_generic_map_semi:
/* skip_nothing */ {}
|	skip_generic_map t_Semicolon {}
    ;

/*
skip_comp_inst_stat:
	t_Identifier t_Colon skip_comp_inst_unit
	    skip_opt_generic_map
	    skip_opt_port_map
	t_Semicolon
	{}
    ;
*/

skip_comp_inst_stat:
	skip_comp_mark
	    t_GENERIC t_MAP skip_named_association_list
	    skip_opt_port_map
	t_Semicolon
{}

    |	skip_comp_mark
	    t_PORT t_MAP skip_named_association_list
	    skip_opt_generic_map
	t_Semicolon
{}
    |   skip_comp_mark_with_keyword
            skip_opt_generic_map
            skip_opt_port_map
        t_Semicolon
{}
    ;

skip_comp_mark_with_keyword:
	t_COMPONENT skip_comp_mark                 
{}
    |   t_ENTITY skip_simple_sel_name skip_opt_arch_id  
{}
    |   t_CONFIGURATION skip_mark
{}
    ;

/* skip_NOTE: skip_component skip_instantiation skip_statements skip_without skip_a skip_keyword skip_look
**	 skip_like skip_concurrent skip_procedure skip_calls
*/

skip_opt_generic_map:
    /* skip_nothing */ {}
    |	skip_generic_map
    ;

skip_generic_map:
    t_GENERIC t_MAP skip_named_association_list {}
    ;

skip_opt_port_map:
    /* skip_nothing */ {}
    |	skip_port_map
    ;

skip_port_map:
    t_PORT t_MAP skip_named_association_list {}
    ;

skip_concurrent_assertion_stat:
    	skip_assertion_stat
{}

    |	t_POSTPONED skip_assertion_stat
{}
    ;

skip_concurrent_procedure_call:
        skip_mark t_Semicolon
{}

    |   skip_procedure_call_stat_with_args
{}

    |	t_POSTPONED skip_procedure_call_stat
{}
    ;

skip_opt_postponed:
    /* skip_nothing */ {}
|	t_POSTPONED {}
    ;

skip_concurrent_signal_assign_stat:
    	skip_condal_signal_assign
{}

    |	t_POSTPONED skip_condal_signal_assign
{}

|	skip_sel_signal_assign
{}

|	t_POSTPONED skip_sel_signal_assign
{}
    ;

skip_condal_signal_assign:
    	skip_target t_LESym skip_opt_guarded skip_delay_mechanism skip_condal_wavefrms t_Semicolon
{}
    ;

skip_condal_wavefrms:
    	skip_condal_wavefrms_1 skip_wavefrm
{}
    ;

skip_condal_wavefrms_1:
    	/* skip_nothing */ {}
    |	skip_condal_wavefrms_1 skip_wavefrm t_WHEN skip_condition t_ELSE
{}
    ;

skip_wavefrm:
	skip_wavefrm_element skip_reverse_more_wavefrm
{}
    ;

skip_reverse_more_wavefrm:
	/* skip_nothing */ {}
    |	skip_reverse_more_wavefrm t_Comma skip_wavefrm_element
{}
    ;

skip_wavefrm_element:
	skip_expr skip_opt_wavefrm_after
{}
    ;

skip_opt_wavefrm_after:
	/* skip_nothing */ {}
|	t_AFTER skip_expr {}
    ;

skip_target:
skip_name {}
|	skip_aggregate {}
    ;

skip_opt_guarded:
/* skip_nothing */ {}
|	t_GUARDED {}
    ;

skip_sel_signal_assign:
	t_WITH skip_expr t_SELECT skip_target t_LESym skip_opt_guarded skip_delay_mechanism
                                            skip_sel_wavefrms t_Semicolon
{}
    ;

skip_sel_wavefrms:
	skip_sel_wavefrms_1 skip_wavefrm t_WHEN skip_choices
{}
    ;

skip_sel_wavefrms_1:
	/* skip_nothing */
{}
    |	skip_sel_wavefrms_1 skip_wavefrm t_WHEN skip_choices t_Comma
{}
    ;

skip_generate_stat:
	skip_generation_scheme t_GENERATE
	{}
          skip_generate_declarative_items_block
	  skip_concurrent_stats
	t_END t_GENERATE skip_opt_t_Identifier t_Semicolon
	{}
    ;

skip_generate_declarative_items_block:
	  /* nothing */
    |     skip_generate_declarative_items t_BEGIN
    ;

skip_generate_declarative_items:
          /* nothing */
    |     skip_generate_declarative_items skip_generate_declarative_item
    ;

skip_generate_declarative_item:
	  skip_common_decltve_item
    |     skip_subprog_body
    |	  skip_comp_decl
    |	  skip_attribute_decl
    |	  skip_attribute_spec
    |	  skip_config_spec
    |	  skip_disconnection_spec
    |	  skip_signal_decl
    ;

skip_proc_stat:
	t_PROCESS skip_opt_proc_sensitivity_list skip_opt_t_IS
{}
	    skip_proc_decl_part
	t_BEGIN
	    skip_seq_stats
	t_END skip_opt_postponed t_PROCESS skip_opt_t_Identifier t_Semicolon
{}

    |	t_POSTPONED t_PROCESS skip_opt_proc_sensitivity_list skip_opt_t_IS
{}
	    skip_proc_decl_part
	t_BEGIN
	    skip_seq_stats
	t_END skip_opt_postponed t_PROCESS skip_opt_t_Identifier t_Semicolon
{}
    ;

skip_opt_t_IS:
	/* skip_nothing */
    |	t_IS
    ;

skip_proc_decl_part:
	/* skip_nothing */
    |	skip_proc_decl_part skip_proc_decltve_item
    ;

skip_opt_proc_sensitivity_list:
    /* skip_nothing */ {}
|	t_LeftParen skip_sensitivity_list t_RightParen {}
    ; 

skip_sensitivity_list:
	skip_signal_name skip_reverse_opt_more_sensitivities
{}
    ;

skip_reverse_opt_more_sensitivities:	 
	/* skip_nothing */ {}
    |	skip_reverse_opt_more_sensitivities t_Comma skip_signal_name
{}	
    ;

skip_signal_name:
	skip_name
{}
    ;

/*--------------------------------------------------
--  skip_Sequential skip_Statements
----------------------------------------------------*/

skip_seq_stats:
	skip_rev_seq_stats {}
    ;

skip_rev_seq_stats:
	/* skip_nothing */ {}
    |	skip_rev_seq_stats skip_seq_stat	
{}
    ;

skip_seq_stat:
    skip_assertion_stat {}
|   skip_report_stat {}
|	skip_case_stat {}
|	skip_exit_stat {}
|	skip_if_stat {}
|	skip_loop_stat {}
|	skip_next_stat {}
|	skip_null_stat {}
|	skip_procedure_call_stat {}
|	skip_return_stat {}
|	skip_signal_assign_stat {}
|	skip_variable_assign_stat {}
|	skip_wait_stat {}
    ;

skip_assertion_stat:
	t_ASSERT skip_condition skip_opt_assertion_report skip_opt_assertion_severity
	 t_Semicolon
{}
    ;

skip_report_stat:
	t_REPORT skip_expr skip_opt_assertion_severity t_Semicolon
{}
    ;

skip_opt_assertion_severity:
	/* skip_nothing */
{}
    |	t_SEVERITY skip_expr
{}
    ;

skip_opt_assertion_report:
	/* skip_nothing */
{}
    |	t_REPORT skip_expr
{}
    ;

skip_case_stat:
	t_CASE skip_expr t_IS 
	    skip_case_stat_alternative
	    skip_more_case_stat_alternatives 
	t_END t_CASE t_Semicolon
{}
    ;

skip_case_stat_alternative:
	t_WHEN skip_choices t_Arrow skip_seq_stats
{}
    ;

skip_more_case_stat_alternatives:
	/* skip_nothing */
{}
    |	skip_more_case_stat_alternatives skip_case_stat_alternative
{}
    ;

skip_if_stat:
	t_IF skip_condition t_THEN skip_seq_stats skip_if_stat_1 skip_if_stat_2 t_END t_IF
	t_Semicolon
{}
    ;

skip_if_stat_2:
	/* skip_nothing */ {}
|	t_ELSE skip_seq_stats {}
    ;

skip_if_stat_1:
/* skip_nothing */ {}
    |	skip_if_stat_1  t_ELSIF skip_condition t_THEN skip_seq_stats
{}
    ;

skip_condition:
    skip_expr {}
    ;

skip_loop_stat:
	skip_opt_label skip_opt_iteration_scheme t_LOOP
{}
	    skip_seq_stats
	t_END t_LOOP skip_opt_t_Identifier t_Semicolon
{}
    ;

skip_opt_iteration_scheme:
	    /* skip_nothing */ {}
|	skip_iteration_scheme {}
    ;

skip_opt_label:
/* skip_nothing */ {}
    |	t_Identifier t_Colon 
{}
    ;

skip_next_stat:
	t_NEXT skip_opt_t_Identifier skip_opt_when t_Semicolon
{}
    ;

skip_exit_stat:
	t_EXIT skip_opt_t_Identifier skip_opt_when t_Semicolon
{}
    ;

skip_opt_when:
	/* skip_nothing */ {}
|	t_WHEN skip_condition {}
    ;

skip_null_stat:
t_NULL t_Semicolon {}
    ;

skip_procedure_call_stat:
skip_procedure_call_stat_without_args {}
|   skip_procedure_call_stat_with_args {}
    ;

skip_procedure_call_stat_without_args:
	skip_mark t_Semicolon
{}
    ;

skip_procedure_call_stat_with_args:
	skip_name2 t_Semicolon
{}
    ;

skip_return_stat:
	t_RETURN skip_opt_expr t_Semicolon
{}
    ;

skip_opt_expr:
	/* skip_nothing */ {}
    |	skip_expr
    ;

skip_signal_assign_stat:
	skip_target t_LESym skip_delay_mechanism skip_wavefrm t_Semicolon
{}
    ;

skip_delay_mechanism:
	/* skip_nothing */ {}
|   t_TRANSPORT {}
|   t_INERTIAL {}
    |	t_REJECT skip_expr t_INERTIAL 
{}
    ;

skip_variable_assign_stat:
	skip_target t_VarAsgn skip_expr t_Semicolon
{}
    ;

skip_wait_stat:
	t_WAIT skip_opt_wait_on skip_opt_wait_until skip_opt_wait_for t_Semicolon
{}
    ;

skip_opt_wait_for:
	/* skip_nothing */ {}
|	t_FOR skip_expr {}
    ;

skip_opt_wait_until:
/* skip_nothing */ {}
|	t_UNTIL skip_condition {}
    ;

skip_opt_wait_on:
/* skip_nothing */ {}
|	t_ON skip_sensitivity_list {}
    ;

/*--------------------------------------------------
--  skip_Components skip_and skip_Configurations
----------------------------------------------------*/

skip_comp_decl:
	t_COMPONENT t_Identifier skip_opt_t_IS
{}
	    skip_opt_generic_and_port_clauses
	t_END t_COMPONENT skip_opt_t_Identifier t_Semicolon
{}
    ;

skip_block_config:
	    t_FOR skip_name {}
    	    skip_use_clauses
    	    skip_config_items
    	t_END t_FOR t_Semicolon
{}
    ;

skip_config_items:
	    /* skip_nothing */ {}
|	skip_config_items skip_config_item {}
    ;

skip_use_clauses:
	/* skip_nothing */
|	skip_use_clauses skip_use_clause {}
    ;

skip_config_item:
skip_block_config {}
|	skip_comp_config {}
    ;

skip_comp_config:
	t_FOR skip_comp_spec skip_opt_comp_binding_indic
{}
    	    skip_opt_block_config
	t_END t_FOR t_Semicolon
{}
    ;

skip_opt_block_config:
	    /* skip_nothing */ {}
|	skip_block_config {}
    ;

skip_opt_comp_binding_indic:
/* skip_nothing */ {}
|  	skip_incremental_binding_indic t_Semicolon {}
|	skip_pre_binding_indic t_Semicolon {}
    ;

skip_config_spec:
	t_FOR skip_comp_spec skip_binding_indic t_Semicolon
{}
    ;

skip_comp_spec:
	skip_inst_list t_Colon skip_comp_mark
{}
    ;

skip_comp_mark:
	skip_mark
{}
    ;

skip_inst_list:
	skip_idf_list {}
|	t_ALL {}
|	t_OTHERS {}
    ;

/* skip_binding_indic skip_et skip_al skip_is skip_to skip_be skip_invoked skip_with skip_the skip_component skip_decl
** skip_as skip_the skip_selected skip_scope
*/

skip_binding_indic:
skip_pre_binding_indic {}
    ;

skip_pre_binding_indic:
{}
	t_USE skip_entity_aspect
{}
	skip_opt_generic_map skip_opt_port_map
{}
    ;

skip_incremental_binding_indic:
	skip_generic_map skip_opt_port_map
{}
    |	skip_port_map
{}
    ;

skip_entity_aspect:
	t_ENTITY skip_simple_sel_name skip_opt_arch_id
{}
    |	t_CONFIGURATION skip_mark
{}
    |	t_OPEN
{}
    ;

skip_opt_arch_id:
    /* skip_nothing */ {}
|	t_LeftParen t_Identifier t_RightParen {}
    ;


%%

