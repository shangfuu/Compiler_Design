#include "symTable.h"



/* Symbol Table Entry Info */

SymInfo::SymInfo()
{
    id_name = "";
    declare_type = DEC_ERROR;
    data_type = TYPE_NONE;
    data = NULL;
}

SymInfo::SymInfo(string id, _Declare_type dec)
{
    id_name = id;
    declare_type = dec;
    data_type = TYPE_NONE;
    data = NULL;
}

SymInfo::SymInfo(string id, _Data_type type)
{
    id_name = id;
    data_type = type;
    declare_type = DEC_ERROR;
    data = NULL;
}

SymInfo::SymInfo(string id, _Declare_type dec, _Data_type type)
{
    id_name = id;
    declare_type = dec;
    data_type = type;
    data = NULL;
}

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
    return data_type;
}

void SymInfo::test()
{
    cout << "ID name: " << get_id_name() << endl;
    cout << "Declare type: " << get_declare_type() << endl;
    cout << "Data type: " << get_data_type() << endl;
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