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


#ifndef _VECTOR_H_
#define _VECTOR_H_

#define VECTOR_SIZE_GROWTH 4

typedef struct vector_t 
{
	int count;
	int capacity;
	void** data; 
} vector;


vector* vector_new(int capacity);
int vector_add(vector *vec, void *item);
int vector_append_front(vector *vec, void *item);
int vector_add_range(vector* vec, vector* range);
void *vector_get(vector *vec, int idx);
int vector_set(vector *vec, int idx, void *data);
void vector_free(vector* vec);
void vector_reverse_order(vector* vec);
vector * vector_merge(vector* vec1, vector* vec2);

#endif /*_VECTOR_H_*/

