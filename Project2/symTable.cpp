#include "symTable.h"

/* Data */

Data::Data()
{
    modified = false;
    data_type = TYPE_NONE;
}

template <typename T>
Data::Data(_Data_type dtype, T tvalue)
{
    modified = true;
    set_value(dtype, tvalue);
}

template <typename T>
void Data::set_value(_Data_type dtype, T tvalue)
{
    data_type = dtype;

    // Use typeid to make sure value type is match.
    switch (typeid(tvalue))
    {
    case typeid(value.ival):
        value.ival = tvalue;
        break;
    case typeid(value.fval):
        value.fval = tvalue;
        break;
    case typeid(value.cval):
        value.cval = tvalue;
        break;
    case typeid(value.sval):
        value.sval = tvalue;
        break;
    case typeid(value.bval):
        value.bval = tvalue;
        break;
    default:
        cout << "Data initial Error" << endl;
        exit(EXIT_FAILURE);
        break;
    }
}

template <typename T>
T Data::get_value()
{
    switch (data_type)
    {
    case TYPE_INT:
        return value.ival;
        break;
    case TYPE_FLOAT:
        return value.fval;
        break;
    case TYPE_CHAR:
        return value.cval;
        break;
    case TYPE_STRING:
        return value.sval;
        break;
    case TYPE_BOOL:
        return value.bval;
        break;
    default:    // TYPE_NONE
        cout << "NOT INITIAL" << endl;
        break;
    }

    return NULL;
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
}

SymInfo::SymInfo(string id, _Declare_type dec)
{
    id_name = id;
    declare_type = dec;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type)
{
    id_name = id;
    declare_type = dec;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type, Data dataValue)
{
    id_name = id;
    declare_type = dec;
    data = dataValue;
}

SymInfo::SymInfo(string id, _Declare_type dec, Data dataValue)
{
    id_name = id;
    declare_type = dec;
    data = dataValue;
}

string SymInfo::get_id_name()
{
    return id_name;
}

_Declare_type SymInfo::get_declare_type()
{
    return declare_type;
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

SymInfo* SymbolTables::look_up(SymInfo* entry)
{
    string id_name = entry->get_id_name();
    SymInfo* lookup_entry;

    for(int i = top; i >= 0; i++)
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
    for(int i = 0; i < top; i++)
    {
        cout << "Table" << i << endl;
        tables[i].dump();
    }
}