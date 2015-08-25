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

#ifndef _LINKED_LIST_2_H_
#define _LINKED_LIST_2_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <malloc.h>


typedef struct ll_node ll_node;

typedef struct ll_node
{
	void* data;
	ll_node* next;
	ll_node* prev;
} ll_node;

typedef struct 
{
	ll_node* head;
	ll_node* tail;
} linked_list;


linked_list * ll_new();
void ll_free(linked_list* list);
void ll_append_front(linked_list *list, void* data);
void ll_append_back(linked_list *list, void *data);
int ll_count(linked_list *list);

void* ll_get(linked_list *list, int index);
int ll_set(linked_list *list, int index, void *data);

void ll_reverse_order(linked_list* list);

linked_list * ll_merge(linked_list* list1, linked_list* list2);

#endif


