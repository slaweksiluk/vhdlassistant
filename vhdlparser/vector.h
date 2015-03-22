


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
int vector_add_range(vector* vec, vector* range);
void *vector_get(vector *vec, int idx);
void vector_free(vector* vec);


#endif /*_VECTOR_H_*/

