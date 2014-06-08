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

#include "linked_list.h"


struct ll_node * ll_create_node(void* data)
{
	struct ll_node * node = malloc(sizeof(struct ll_node));
	node->next = NULL;
	node->data = data;
	return node;
}


struct ll_node * ll_append_front(struct ll_node *list, void* data)
{
	struct ll_node *node = ll_create_node(data);
	node->next = list;
	return node;
}


struct ll_node * ll_append_back(struct ll_node *list, void *data)
{
	struct ll_node *node = ll_create_node(data);
	struct ll_node *last_node = list;
	if (list == NULL)
	{
		return node;
	}
	
	while (1)
	{
		if (last_node->next == NULL)
		{
			last_node->next = node;
			break;
		}
		last_node = last_node->next;
	}
	
	return list;
}

int ll_length(struct ll_node *list)
{
	int length = 0;
	while(1)
	{
		if (list == NULL)
		{
			break;
		}
		length ++;
		list = list->next;
	}
	return length;
}

