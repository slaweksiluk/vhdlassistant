

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

int vector_add(vector *vec, void *item)
{
	if(vec->capacity == vec->count) {
		vec->capacity += VECTOR_SIZE_GROWTH;
		vec->data = realloc(vec->data, sizeof(void*)*vec->capacity);
		if(vec->data == NULL)
		{
			return 1;
		}
	}
	
	vec->data[vec->count] = item;
	vec->count++;
	
	return 0; 
}

void *vector_get(vector *vec, int idx)
{
	if(vec->count > idx){
		return vec->data[idx];
	}
	return NULL;
}

int vector_add_range(vector* vec, vector* range)
{
	if(vec->capacity < (vec->count + range->count) ) {
		vec->capacity += range->count - (vec->capacity - vec->count); // required space - available space
		vec->data = realloc(vec->data, sizeof(void*)*vec->capacity);
		if(vec->data == NULL)
		{
			return 1;
		}
	}
	memcpy(&vec->data[vec->count], range->data, sizeof(void*)*range->count);
	vec->count += range->count;
	return 0;
}

void vector_free(vector* vec)
{
	free(vec->data);
	free(vec);
}







