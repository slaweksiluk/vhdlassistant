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

#include "parser_error.h"
#include <malloc.h>

struct parser_error_1s* create_error_message(uint32_t line, char *msg)
{
	struct parser_error_1s *err = malloc(sizeof(struct parser_error_1s));
	err->id = ERROR_MESSAGE;
	err->line = line;
	err->s0 = msg;
	return err;
}

struct parser_error_2s* create_error_label_missmatch(uint32_t line, char *l1, char *l2)
{
	struct parser_error_2s *err = malloc(sizeof(struct parser_error_2s));
	err->line = line;
	err->id = ERROR_LABEL_MISSMATCH;
	err->s0 = l1;
	err->s1 = l2;
	return err;
}

struct parser_error_1c* create_error_illegal_symbol(uint32_t line, char sym)
{
	struct parser_error_1c *err = malloc(sizeof(struct parser_error_1c));
	err->line = line;
	err->id = ERROR_ILLEGAL_SYMBOL;
	err->c0 = sym;
	return err;
}

struct parser_error* create_error_id(uint32_t line, enum error_id id)
{
	struct parser_error *err = malloc(sizeof(struct parser_error));
	err->id = id;
	err->line = line;
	return err;
}
