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

#ifndef _PARSER_ERROR_H_
#define _PARSER_ERROR_H_

#include <stdint.h>

enum error_id 
{
	ERROR_MESSAGE = 0,
	ERROR_LABEL_MISSMATCH = 1,
	ERROR_ILLEGAL_SYMBOL = 2,
	ERROR_UNDERSCORE = 3,
	ERROR_PORT_GENERIC_ORDER = 4,
	ERROR_PORT_OBJECT_CLASS = 5,
	ERROR_GENERIC_OBJECT_CLASS = 6,
	ERROR_GENERIC_MODE = 7,
	ERROR_ENTITY_NOT_FOUND = 8,
	ERROR_COMPONENT_NOT_FOUND = 9,
	ERROR_EMPTY_PORT_OR_GENEERIC_CLAUSE = 10
};


struct parser_error
{
	enum error_id id;
	uint32_t line;
};


struct parser_error_1s
{
	enum error_id id;
	uint32_t line;
	char *s0;
};

struct parser_error_2s
{
	enum error_id id;
	uint32_t line;
	char *s0;
	char *s1;
};

struct parser_error_1c
{
	enum error_id id;
	uint32_t line;
	char c0;
};

struct parser_error* create_error_id(uint32_t line, enum error_id id);
struct parser_error_1s* create_error_message(uint32_t line, char *msg);
struct parser_error_2s* create_error_label_missmatch(uint32_t line, char *l1, char *l2);
struct parser_error_1c* create_error_illegal_symbol(uint32_t line, char sym);

#endif


