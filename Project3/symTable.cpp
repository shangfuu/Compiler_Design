#include "symTable.h"

/* enum to string */

string data_type_to_string(_Data_type type)
{
    switch (type)
    {
    case TYPE_INT:
        return "TYPE_INT";
        break;
    case TYPE_FLOAT:
        return "TYPE_FLOAT";
        break;
    case TYPE_CHAR:
        return "TYPE_CHAR";
        break;
    case TYPE_STRING:
        return "TYPE_STRING";
        break; 
    case TYPE_BOOL:
        return "TYPE_BOOL";
        break;
    default:
        break;
    }
    return "TYPE_NONE";
}

string declare_type_to_string(_Declare_type dec)
{
    switch (dec)
    {
    case DEC_VAL:
        return "DEC_VAL";
        break;
    case DEC_VAR:
        return "DEC_VAR";
        break;
    case DEC_ARRAY:
        return "DEC_ARRAY";
        break;
    case DEC_DEF:
        return "DEC_DEF";
        break;
    case DEC_OBJECT:
        return "DEC_OBJECT";
        break;
    default:
        break;
    }
    return "DEC_ERROR";
}

/* Data */

Data::Data()
{
    modified = false;
    data_type = TYPE_NONE;
}
// Constructor
Data::Data(_Data_type dtype, int iv) { value.ival = iv; data_type = dtype; modified = true; }
Data::Data(_Data_type dtype, float fv) { value.fval = fv; data_type = dtype; modified = true; }
Data::Data(_Data_type dtype, string *sv) { value.sval = sv; data_type = dtype; modified = true; }
Data::Data(_Data_type dtype, char cv) { value.cval = cv; data_type = dtype; modified = true; }
Data::Data(_Data_type dtype, bool bv) { value.bval = bv; data_type = dtype; modified = true; }

// Set value
void Data::set_value(int iv) { value.ival = iv; modified = true; }
void Data::set_value(float fv) { value.fval = fv; modified = true; }
void Data::set_value(char cv) { value.cval = cv; modified = true; }
void Data::set_value(string* sv) { value.sval = sv; modified = true; }
void Data::set_value(bool bv) { value.bval = bv; modified = true; }

// Get value
int Data::get_int() { return value.ival; }
float Data::get_float() { return value.fval; }
char Data::get_char() { return value.cval; }
string* Data::get_string() { return value.sval; }
bool Data::get_bool() { return value.bval; }

void Data::set_data_type(_Data_type dtype) 
{
    data_type = dtype;
}

_Data_type Data::get_data_type()
{
    return data_type;
}

bool Data::isModified()
{
    return modified;
}


/* Symbol Table Entry Info */

SymInfo::SymInfo()
{
    id_name = "";
    declare_type = DEC_ERROR;
    return_type = TYPE_NONE;
    global = false;
    stackID = -1;
}
// Variable

SymInfo::SymInfo(string id, _Declare_type dec)
{
    id_name = id;
    declare_type = dec;
    global = false;
    stackID = -1;
    // func
    return_type = TYPE_NONE;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type)
{
    id_name = id;
    declare_type = dec;
    var_data.set_data_type(type);
    global = false;
    stackID = -1;
    // func
    return_type = TYPE_NONE;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type, Data dataValue)
{
    id_name = id;
    declare_type = dec;
    var_data = dataValue;
    global = false;
    stackID = -1;
    // func
    return_type = TYPE_NONE;
}

SymInfo::SymInfo(string id, _Declare_type dec, Data dataValue)
{
    id_name = id;
    declare_type = dec;
    var_data = dataValue;
    global = false;
    stackID = -1;
    // func
    return_type = TYPE_NONE;
}
// Array

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type, int length)
{
    id_name = id;
    declare_type = dec;
    array_num = length;
    global = false;
    stackID = -1;

    array_data = new Data[length];
    for (int i = 0 ; i < length; i++)
    {
        array_data[i].set_data_type(type);
    }
    // func
    return_type = TYPE_NONE;
}

_Data_type SymInfo::get_array_data_type()
{
    return array_data[0].get_data_type();
}

int SymInfo::get_array_length()
{
    return array_num;
}

// Function
void SymInfo::add_arg_type(_Data_type type)
{
    args_types.push_back(type);
}

void SymInfo::set_return_type(_Data_type type)
{
    return_type = type;
}

bool SymInfo::check_arg_match(vector<Data*>* func_call)
{
    if (func_call->size() != args_types.size())
    {
        return false;
    }
    // Check if every type is match
    for (int i = 0 ; i < func_call->size(); i++)
    {   
        if ((*func_call)[i]->get_data_type() != args_types[i])
        {
            return false;
        }
    }
    return true;
}

_Data_type SymInfo::get_return_type()
{
    return return_type;
}

vector<_Data_type> SymInfo::get_arg()
{
    return args_types;
}

// Common

string SymInfo::get_id_name()
{
    return id_name;
}

_Declare_type SymInfo::get_declare_type()
{
    return declare_type;
}

_Data_type SymInfo::get_data_type()
{
    return var_data.get_data_type();
}

void SymInfo::set_data(Data d)
{
    var_data = d;
}

void SymInfo::set_array_data(int index, Data d)
{
    array_data[index] = d;
}

Data* SymInfo::get_data()
{
    return &var_data;
}

Data* SymInfo::get_array_data(int index)
{
    return &array_data[index];
}

void SymInfo::test()
{
    cout << "ID name: " << get_id_name() << endl;
    cout << "Declare type: " << get_declare_type() << endl;
}
// Global Check
bool SymInfo::isGlobal()
{
    return global;
}

void SymInfo::set_global() 
{ 
    global = true; 
}

/* Single Symbol Table */

SymTable::SymTable()
{
    table.clear();
}

SymTable::~SymTable()
{
    table.clear();
}

int SymTable::insert(SymInfo* entry) 
{
    if (table.find(entry->get_id_name()) != table.end())
    {
        return -1;
    }
    table[entry->get_id_name()] = entry;

    return 1;
}

SymInfo* SymTable::lookup(string str)
{
    if(table.find(str) == table.end())
    {
        return NULL;
    }
    return table[str];
}

void SymTable::dump() 
{
    for(auto p : table)
    {
        cout << "ID: " << p.second->get_id_name() << "\t\tDeclare type: " << declare_type_to_string(p.second->get_declare_type());
        if (p.second->get_declare_type() == DEC_VAL || p.second->get_declare_type() == DEC_VAR)
        {
            cout << "\t\tData type: " << data_type_to_string(p.second->get_data_type()) << endl;
        }
        else if (p.second->get_declare_type() == DEC_ARRAY)
        {
            cout << "\t\tData type: "  << data_type_to_string(p.second->get_array_data_type()) << endl;
        }
        else
        {
            cout << endl;
        }
    }
}


/* Multiple Symbol Tables */

SymbolTables::SymbolTables()
{
    // Add the first Global Table
    top = -1;
    this->add_table();
}

SymbolTables::~SymbolTables()
{
    tables.clear();
}

int SymbolTables::insert(SymInfo* entry)
{
    if (top == 0)
    {
        entry->set_global();
    }
    return tables[top].insert(entry);
}

void SymbolTables::add_table() 
{
    tables.push_back(SymTable());
    top++;
}

void SymbolTables::pop_table()
{
    tables.pop_back();
    top--;
}

SymInfo* SymbolTables::look_up(string id_name)
{
    SymInfo* lookup_entry;

    for(int i = top; i >= 0; i--)
    {
        lookup_entry = tables[i].lookup(id_name);
        if (lookup_entry != NULL)
        {
            return lookup_entry;
        }
    }
    return NULL;
}

bool SymbolTables::isGlobalTable()
{
    if (top == 0)
        return true;
    else
        return false;
}

void SymbolTables::dump()
{
    cout << endl << "------------Dump Symbol Table------------" << endl;
    for(int i = 0; i <= top; i++)
    {
        cout << "================ Table " << i << " ================" << endl;
        tables[i].dump();
        cout << "=========================================" << endl;
    }
    cout << endl;
}

