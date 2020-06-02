// Symbol Table: using hash table
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 53

typedef struct node_{
	char *name;     // value
	struct node_ *next;
	int index;      // key
} Node;

typedef struct hash_table_{
	Node **table;
	int count;  // number of ID in table.
} HashTable;

HashTable* create();
int lookup(HashTable*, char*);
void insert(HashTable*, char*);
void dump(HashTable*);

// Hash function: djb2
unsigned int hash(char*);

 /* Hash Function: djb2 by Dan Bernstein */
unsigned int hash(char *str){
	unsigned int hash = 0U;
	int c;

	while(c = *str++){
		hash = ((hash << 5) + hash) ^ c;	// hash * 33 ^ c
	}
	return hash;
}

HashTable* create(){
	HashTable *symbol_table = (HashTable*)malloc(sizeof(HashTable));
	symbol_table->table = (Node**)malloc(sizeof(Node) * TABLE_SIZE);

    // Clear all table to NULL
	memset(symbol_table->table, 0, sizeof(Node) * TABLE_SIZE);

	return symbol_table;
}

int lookup(HashTable* symbol_table, char *str){

    int index = hash(str) % TABLE_SIZE;
    Node* iter = symbol_table->table[index];

    // Traverse the table[index] to find string
    while (iter != NULL) {
        if (strcmp(iter->name, str) == 0){
            return index;
        }
        iter = iter->next;
    }

	return NULL;
}

void insert(HashTable *symbol_Table, char *str){
    
    int index = hash(str) % TABLE_SIZE;
    Node* iter = symbol_Table->table[index];
    
    Node* newNode = (Node*)malloc(sizeof(Node));
    // newNode->name = (char*)malloc(sizeof(char) * strlen(str));
    newNode->name = strdup(str);
    newNode->index = index;
    newNode->next = NULL;

    // Empty slot
    if (iter == NULL) {
        symbol_Table->table[index] = newNode;
    }
    // Not Empty
    else {
        //  Name already exists in Symbol Table
        if(strcmp(iter->name, str) == 0){
            return;
        }
        
        for (;iter->next != NULL;iter = iter->next) {
            //  Name already exists in Symbol Table
            if (strcmp(iter->name, str) == 0){
                return;
            }
        }
        
        // iter is the last node in this index.
        iter->next = newNode;
    }
}

void dump(HashTable* symbol_table){

    // Run all the slot of Symbol Table
    for(int i = 0 ; i < TABLE_SIZE; i++){
        // Traverse table entry
        Node* entry = symbol_table->table[i];
        if (entry != NULL){
            printf("\n%d:", i);
        }
        while (entry != NULL){
            printf(" %s", entry->name);
            entry = entry->next;
        }
    }
    printf("\n");
}
