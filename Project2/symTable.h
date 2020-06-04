#ifndef SYM_TABLE
#define SYM_TABLE

/* Change Symbol structure into C++ class map and vector
*  will be much more easier to implement. Rather than 
*  implement a fixed hash table, we can use c++ map
*  and vector to do a dynamic table easily.
*/


#include <iostream>
#include <string>
#include <map>
#include <vector>

#include <stdio.h>
#include <stdlib.h>

using namespace std;

// Data Type
enum _Data_type {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_CHAR,
    TYPE_STRING,
    TYPE_BOOL,
    TYPE_NONE,
};

// ID Declaration
enum _Declare_type {
    TYPE_VAR,
    TYPE_VAL,
    TYPE_OBJECT,
    TYPE_DEF,
    TYPE_ARRAY,
    TYPE_ERROR,
};

/*
*  Symbol Table Entry Info:
*  All the information that an Symbol
*  may need.
*/
class SymInfo
{

private:
    string id_name;
    _Declare_type declare_type;
    _Data_type data_type;

public:
    SymInfo();
    string get_id_name();
    _Declare_type get_declare_type();
    _Data_type get_data_type();

};


/*
*  Single Symbol Table:
*  Can easily access a ID like map[ID],
*  and get the ID attribute.
*/
class SymTable 
{

private:
    map<string, SymInfo*> table;

public:
    SymTable();
    // Lookup entries in the table
    SymInfo* lookup(string);
    // Insert the entry, return 1: success, -1: failed
    int insert(SymInfo*);
    // Dump the table
    void dump();
};

/*
*  Multi Symbol Tables:
*  Used as Global Symbol Table.
*  ID will insert in the top table.
*/
class SymbolTables 
{

private:
    vector<SymTable> tables;
    int top;    // used as stack
public:
    SymbolTables();
    // Add a new symTable at the top
    void add_table();
    // Pop the table at the top
    void pop_table();
    // Insert the entry at the top table, return 1: success, -1: failed
    int insert(SymInfo*);
    // Lookup all table Entries
    SymInfo* look_up(SymInfo*);
    // Dump all tables and their entry
    void dump();
};

#endif
