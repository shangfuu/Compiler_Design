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
#include <typeinfo>

#include <stdio.h>
#include <stdlib.h>

using namespace std;

// Data Type
enum _Data_type {
    TYPE_CHAR,
    TYPE_STRING,
    TYPE_INT,
    TYPE_BOOL,
    TYPE_FLOAT,
    TYPE_NONE,
};

// ID Declaration
enum _Declare_type {
    DEC_VAL,
    DEC_VAR,
    DEC_ARRAY,
    DEC_OBJECT,
    DEC_DEF,
    DEC_ERROR,
};

/*
*   Reocrd Data Value and Data Type:
*   Every declaretions, expression, function will only
*   have an unique data type.
*   Make it a class because things like expression
*   will have type and value, but no id name and declare.
*/

class Data
{

private:

    union u_data
    {
        /* data */
        int ival;
        float fval;
        char cval;
        string *sval;
        bool bval;
    };

    u_data value;
    _Data_type data_type;

    // If not inital, modified is false;
    bool modified;

public:
    Data();

    // Set value in template. Set Data Type.s
    template <typename T>
    Data(_Data_type, T);

    // Set only type Int, Float, Bool, Char, String to value.
    template <typename T>
    void set_value(_Data_type, T);

    // Get different type of value.s
    template <typename T>
    T get_value();

    _Data_type get_data_type();
    
    // Used in VAL to check if modified.
    bool isModified();
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
    Data data;

    // Array
    int array_num;

public:
    SymInfo();
    // Used like:  object ID.
    SymInfo(string, _Declare_type);
    // Used like:  var ID : type
    SymInfo(string, _Declare_type, _Data_type);
    // Used like:  var ID : type = value
    SymInfo(string, _Declare_type, _Data_type, Data);
    // Used like:  var ID  = value
    SymInfo(string, _Declare_type, Data);



    string get_id_name();
    _Declare_type get_declare_type();


    void test();
};


/*
*   Single Symbol Table:
*   Can easily access a ID like map[ID].
*   Manage as a local symbol table.
*/
class SymTable 
{

private:
    map<string, SymInfo*> table;

public:
    SymTable();
    ~SymTable();
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
    ~SymbolTables();
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
