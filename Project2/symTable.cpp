#include "symTable.h"

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
}
// Variable

SymInfo::SymInfo(string id, _Declare_type dec)
{
    id_name = id;
    declare_type = dec;
    // func
    return_type = TYPE_NONE;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type)
{
    id_name = id;
    declare_type = dec;
    var_data.set_data_type(type);
    // func
    return_type = TYPE_NONE;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type, Data dataValue)
{
    id_name = id;
    declare_type = dec;
    var_data = dataValue;
    // func
    return_type = TYPE_NONE;
}

SymInfo::SymInfo(string id, _Declare_type dec, Data dataValue)
{
    id_name = id;
    declare_type = dec;
    var_data = dataValue;
    // func
    return_type = TYPE_NONE;
}
// Array

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type, int length)
{
    id_name = id;
    declare_type = dec;
    array_num = length;

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
        cout << p.second->get_id_name() << endl;
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

void SymbolTables::dump()
{
    for(int i = 0; i <= top; i++)
    {
        cout << "===== Table " << i << " =====" << endl;
        tables[i].dump();
        cout << "===================" << endl;
    }
}