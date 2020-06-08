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
    TYPE_NONE,
    TYPE_CHAR,
    TYPE_STRING,
    TYPE_INT,
    TYPE_BOOL,
    TYPE_FLOAT,
};

// ID Declaration
enum _Declare_type {
    DEC_ERROR,
    DEC_VAL,
    DEC_VAR,
    DEC_ARRAY,
    DEC_OBJECT,
    DEC_DEF,
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
    /* Set value, type and modified. */
    Data(_Data_type dtype, int iv);
    Data(_Data_type dtype, float fv);
    Data(_Data_type dtype, string *sv);
    Data(_Data_type dtype, char cv);
    Data(_Data_type dtype, bool bv);

    /* Set Value function */
    void set_value(int iv);
    void set_value(float fv);
    void set_value(char cv);
    void set_value(string* sv);
    void set_value(bool bv);
    
    // Set data type.
    void set_data_type(_Data_type);

    /* Get Value */
    string* get_string();
    int get_int();
    float get_float();
    char get_char();
    bool get_bool();

    // Get data type
    _Data_type get_data_type();
    
    // Check if modified.
    bool isModified();
};


/*
*  Symbol Table Entry Info (STEI):
*  All the information that an Symbol
*  may need.
*  Involves Variable, Array and Function type.
*/
class SymInfo
{

private:
    string id_name;
    _Declare_type declare_type;
    // Store data value and data type.
    Data var_data;

    /* Array */
    // Array stoage length
    int array_num;
    // Store array data and data type.
    Data *array_data;

    /* Function */
    _Data_type return_type;
    // Store args types, use to check function call.
    vector<_Data_type> args_types;

public:
    SymInfo();
    // Used like:  object ID, def ID
    SymInfo(string, _Declare_type);
    // Used like:  var ID : type, function args
    SymInfo(string, _Declare_type, _Data_type);
    // Used like:  var ID : type = value
    SymInfo(string, _Declare_type, _Data_type, Data);
    // Used like:  var ID  = value
    SymInfo(string, _Declare_type, Data);

    /* Array */
    // Used like:  var ID : type [num]
    SymInfo(string, _Declare_type, _Data_type, int);
    _Data_type get_array_data_type();
    int get_array_length();

    /* Function */
    void add_arg_type(_Data_type);
    void set_return_type(_Data_type);
    bool check_arg_match(vector<Data*>*);
    _Data_type get_return_type();

    /* Common Function */
    string get_id_name();
    _Declare_type get_declare_type();
    _Data_type get_data_type();

    // Set data.
    void set_data(Data);
    void set_array_data(int, Data);

    // Get data
    Data *get_data();
    Data *get_array_data(int);


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
    // Lookup entries in the table. Return NULL if not found.
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
    // Lookup all table Entries. Return if not found.
    SymInfo* look_up(string);
    // Dump all tables and their entry
    void dump();
};

string data_type_to_string(_Data_type);
string declare_type_to_string(_Declare_type);

#endif  
