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

#include "vector.h"
#include <malloc.h>
#include <stdio.h>
#include <string.h>

vector* vector_new(int capacity)
{
	vector * vec = malloc(sizeof(vector));
	
	if (vec == NULL) {
		return NULL;
	}
	vec->capacity = capacity;
	vec->count = 0;
	vec->data = malloc(capacity * sizeof(void*));
	
	if (vec->data == NULL) {
		free(vec);
		return NULL;
	}
	
	return vec;
}

void vector_free(vector * vec)
{
	free(vec->data);
	free(vec);
}


int vector_add(vector *vec, void *item)
{
	if (vec->capacity == vec->count) {
		vec->capacity += VECTOR_SIZE_GROWTH;
		vec->data = realloc(vec->data, sizeof(void*)*vec->capacity);
		if (vec->data == NULL) {
			return 1;
		}
	}
	
	vec->data[vec->count] = item;
	vec->count++;
	
	return 0; 
}

void *vector_get(vector *vec, int idx)
{
	if (vec->count > idx){
		return vec->data[idx];
	}
	return NULL;
}

int vector_set(vector *vec, int idx, void *data)
{
	if (vec->count > idx) {
		vec->data[idx] = data;
		return 0;
	}
	return -1;
}

int vector_add_range(vector* vec, vector* range)
{
	if (vec->capacity < (vec->count + range->count) ) {
		vec->capacity += range->count - (vec->capacity - vec->count); // required space - available space
		vec->data = realloc(vec->data, sizeof(void*)*vec->capacity);
		if(vec->data == NULL) {
			return 1;
		}
	}
	memcpy(&vec->data[vec->count], range->data, sizeof(void*)*range->count);
	vec->count += range->count;
	return 0;
}

void vector_reverse_order(vector* vec)
{
	for (int i=0; i<(int)(vec->count/2); i++) {
		void *temp = vec->data[i];
		vec->data[i] = vec->data[vec->count-i-1];
		vec->data[vec->count-i-1] = temp;
	}
}


vector * vector_merge(vector* vec1, vector* vec2)
{
	size_t new_count = vec1->count + vec2->count; 

	//check if vec1 has enough storage capacity to the merge result
	if( vec1->capacity >= new_count ) {
		memcpy(&vec1->data[vec1->count], vec2->data, vec2->count*sizeof(void*));
		vector_free(vec2);
		vec1->count = new_count;
		return vec1;
	}
	
	//vec1 is too small, so we copy everything to vec2
	//However, before we can do that we have to enure that there is 
	//enough storage space in vec2
	if ( vec2->capacity < new_count ) {
		//resize vec2
		void * new_data = realloc(vec2->data, (new_count+VECTOR_SIZE_GROWTH)*sizeof(void*));
		if(new_data == NULL) {
			return NULL;
		}
		vec2->capacity = new_count + VECTOR_SIZE_GROWTH;
		vec2->data = new_data;
	}

	memcpy(&vec2->data[vec2->count], vec1->data, vec1->count*sizeof(void*));
	vector_free(vec1);
	vec2->count = new_count;
	return vec2;
}


