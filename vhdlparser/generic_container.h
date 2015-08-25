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

#ifndef _GENERIC_CONTAINER_H_
#define _GENERIC_CONTAINER_H_

#include "linked_list.h"
#include "vector.h"

#define GC_LIST     0
#define GC_VECTOR   1

inline void* gc_new(int type)
{
	switch(type)
	{
		case GC_LIST: return ll_new(); break;
		case GC_VECTOR: return vector_new(VECTOR_SIZE_GROWTH); break;
		default: return NULL;
	}
}

inline void gc_free(void* container, int type)
{
	switch(type)
	{
		case GC_LIST: ll_free(container); break;
		case GC_VECTOR: vector_free(container); break;
		default: ;
	}
}

inline void gc_append_back(void* container, void* data, int type)
{
	switch(type)
	{
		case GC_LIST: ll_append_back(container, data); break;
		case GC_VECTOR: vector_add(container, data); break;
		default: ;
	}
}

inline void gc_append_front(void* container, void* data, int type)
{
	switch(type)
	{
		case GC_LIST: ll_append_front(container, data); break;
		case GC_VECTOR: vector_append_front(container, data); break;
		default: ;
	}
}

inline void* gc_get(void * container, int index, int type)
{
	switch(type)
	{
		case GC_LIST: return ll_get(container, index); break;
		case GC_VECTOR: return  vector_get(container, index); break;
		default: return NULL ;
	}
}

inline int gc_set(void * container, int index, void* data, int type)
{
	switch(type)
	{
		case GC_LIST: return ll_set(container, index, data); break;
		case GC_VECTOR: return vector_set(container, index, data); break;
		default: return -1;
	}
}

inline void gc_reverse_order(void *container, int type)
{
	switch(type)
	{
		case GC_LIST: ll_reverse_order(container); break;
		case GC_VECTOR: vector_reverse_order(container); break;
		default: ;
	}
}


inline void * gc_merge(void* container1, void* container2, int type)
{
	switch(type)
	{
		case GC_LIST: return ll_merge(container1, container2);
		case GC_VECTOR: return vector_merge(container1, container2);
		default: return NULL;
	}
}

inline size_t gc_count(void *container, int type)
{
	switch(type) {
		case GC_LIST: return ll_count(container);
		case GC_VECTOR: return ((vector*)container)->count; 
		default: return 0;
	}
}



#define UNUSED(x) (void)(x)

#define gc_cleanup_iterate_begin()

//unholy macro monster
#define gc_iterate_begin(gc, iterator, type)                        \
	do {                                                            \
		size_t iterator ## _index = 0;                              \
		UNUSED(iterator ## _index);                                 \
		ll_node* iterator ## _node;                                 \
		UNUSED(iterator ## _node);                                  \
		if(type == GC_LIST){                                        \
			iterator ## _node = ((linked_list*)gc)->head;           \
		}                                                           \
		while(1) {                                                  \
			if(type == GC_LIST){                                    \
				if(iterator ## _node == NULL){                      \
					break;                                          \
				}                                                   \
				iterator = iterator ## _node->data;                 \
			}                                                       \
			if(type == GC_VECTOR){                                  \
				if(iterator ## _index == ((vector*)gc)->count){     \
					break;                                          \
				}                                                   \
				iterator = ((vector*)gc)->data[iterator ## _index]; \
			}                                                       
			//do{}while(0)


#define gc_iterate_end(gc, iterator, type)                          \
	if(type == GC_LIST){                                            \
		iterator ## _node = ((ll_node*)iterator ## _node)->next;   \
	}                                                               \
	if(type == GC_VECTOR){                                          \
		iterator ## _index++;                                       \
	}                                                               \
	} } while(0)


#endif /*_GENERIC_CONTAINER_H_*/



