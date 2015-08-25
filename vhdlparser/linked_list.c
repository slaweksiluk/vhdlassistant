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

#include "linked_list.h"



linked_list * ll_new()
{
	linked_list * list = malloc(sizeof(linked_list));
	list->head = NULL;
	list->tail = NULL;
	return list;
}

void ll_free(linked_list * list)
{
	ll_node *node = list->head;
	ll_node *temp = NULL;
	while(node != NULL)
	{
		temp = node;
		node = node->next;
		free(temp);
	}
	free(list);
}

void ll_append_front(linked_list *list, void* data)
{
	ll_node *node = malloc(sizeof(ll_node));
	node->prev = NULL; //first node has no predecessor
	node->next = list->head;
	node->data = data;
	
	if(list->head != NULL){ // list is NOT empty
		list->head->prev = node;
	}else{
		list->tail = node;
	}
	
	list->head = node; //set new head pointer
}


void ll_append_back(linked_list *list, void *data)
{
	ll_node *node = malloc(sizeof(ll_node));
	node->prev = list->tail; 
	node->next = NULL;//last node has no succecessor
	node->data = data;
	
	if(list->tail != NULL)//list was NOT empty
	{
		list->tail->next = node;
	} else {
		list->head = node;
	}
	
	list->tail = node;
}

int ll_count(linked_list *list)
{
	int length = 0;
	ll_node *node = list->head;
	while(1)
	{
		if (node == NULL)
		{
			break;
		}
		length ++;
		node = node->next;
	}
	return length;
}

void* ll_get(linked_list *list, int index)
{
	int length = 0;
	ll_node *node = list->head;
	while(1)
	{
		if (node == NULL) {
			return NULL;
		}
		if (length == index) {
			return node->data;
		}
		length ++;
		node = node->next;
	}
	return NULL;
}

int ll_set(linked_list *list, int index, void *data)
{
	int length = 0;
	ll_node *node = list->head;
	while(1)
	{
		if (node == NULL) {
			return -1;
		}
		if (length == index) {
			node->data = data;
			return 0;
		}
		length ++;
		node = node->next;
	}
	return -1;
}

#if 0
void ll_reverse_order(linked_list* list)
{
	ll_node *temp = NULL;
	ll_node *node = list->head;
	while(node != NULL)
	{
		temp = node->prev;
		node->prev = node->next;
		node->next = temp;
		
		node = node->prev;
	}
	temp = list->head;
	list->head = list->tail;
	list->tail = temp;
}
#endif

void ll_reverse_order(linked_list* list)
{
	ll_node *head = list->head;
	if(head == NULL){
		return; //nothing to do
	}
	ll_node *tail = list->tail;
	void* temp;
	while(1)
	{
		if(head == tail){
			return;
		}
		temp = head->data;
		head->data =  tail->data;
		tail->data = temp;
		
		head = head->next;
		if(head == tail){
			return;
		}
		tail = tail->prev;
	}
	temp = list->head;
	list->head = list->tail;
	list->tail = temp;
}

linked_list * ll_merge(linked_list* list1, linked_list* list2)
{
	list1->tail->next = list2->head;
	list2->head->prev = list1->tail;
	list1->tail = list2->tail;
	ll_free(list2);
	return list1;
}



