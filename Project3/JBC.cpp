#include "JBC.h"

/* Java Byte Code */

void JBC_Init()
{
    JBC << "class " << filename << endl << "{" << endl;
}

void JBC_End()
{
    JBC << "}" << endl;
}

/* Variable */

// Initial
void JBC_GlobalVar (string id)
{
    JBC << "\tfield static int " << id << endl;
}

void JBC_LocalVar(int index)
{
    JBC << "\t\tistore " << index << endl;
}

// = id
void JBC_getGlobalVar(string id)
{
    JBC << "\t\tgetstatic int " << filename << "." << id << endl;
}

void JBC_getLocalVar(int index)
{
    JBC << "\t\tiload " << index << endl;
}

// id =
void  JBC_AssignGlobal(string id)
{
    JBC << "\t\tputstatic type " << filename << "." << id << endl;
}

void JBC_AssignLocal(int index)
{
    JBC << "\t\tistore " << index << endl;
}

// Constant
void JBC_PushInt(int value)
{
    JBC << "\t\tsipush " << value << endl;
}

void JBC_PushStr(string str)
{
    JBC << "\t\tldc \"" << str << "\"" << endl;
}

/* OP */

void JBC_OP(char op)
{
    switch (op)
    {
    case '+': JBC << "\t\tiadd" << endl; break;
    case '-': JBC << "\t\tisub" << endl; break;
    case '*': JBC << "\t\timul" << endl; break;
    case '/': JBC << "\t\tidiv" << endl; break;
    case '%': JBC << "\t\tirem" << endl; break;
    case 'u': JBC << "\t\tineg" << endl; break;
    case '&': JBC << "\t\tiand" << endl; break;
    case '|': JBC << "\t\tior" << endl; break;
    case '!': JBC << "\t\tldc 1" << endl << "\t\tixor" << endl; break;
    }
}

void JBC_RELOP()
{

}

/* Print */

void JBC_PrintStart()
{
    JBC << "\t\tgetstatic java.io.PrintStream java.lang.System.out" << endl;
}

void JBC_PrintStr()
{
    JBC << "\t\tinvokevirtual void java.io.PrintStream.print(java.lang.String)" << endl;
}

void JBC_PrintInt()
{
    JBC << "\t\tinvokevirtual void java.io.PrintStream.print(int)" << endl;
}

/* Function */

void JBC_MainStart()
{
    JBC << "\tmethod public static void main(java.lang.String[])" << endl;
    JBC << "\tmax_stack 15" << endl << "\tmax_locals 15" << endl << "\t{" << endl;
}

void JBC_FuncStart(SymInfo id)
{
    JBC << "\tmethod public static " << typeToString(id.get_return_type()) << id.get_id_name() << "(";
    // args type
    for(int i = 0 ; i < id.get_arg().size(); i++)
    {
        if (i != 0)
            JBC << ", ";
        JBC << typeToString(id.get_arg()[i]);
    }
    JBC << ")" << endl << "\tmax_stack 15" << endl << "\tmax_locals 15" << endl << "\t{" << endl;
}

void JBC_FuncEnd(SymInfo id)
{
    if (id.get_return_type() == TYPE_NONE)
        JBC << "\t\treturn" << endl << "\t}" << endl;
    else
        JBC << "\t}" << endl;
}

void JBC_FuncInvo(SymInfo id)
{
    JBC << "\t\tinvokestatic " << typeToString(id.get_return_type()) << " " << filename << "." << id.get_id_name() << "(";
    // args type
    for(int i = 0 ; i < id.get_arg().size(); i++)
    {
        if (i != 0)
            JBC << ", ";
        JBC << typeToString(id.get_arg()[i]);
    }
    JBC << ")" << endl;
}

void JBC_Return()
{
    JBC << "\t\treturn" << endl;
}

void JBC_IReturn()
{
    JBC << "\t\tireturn" << endl;
}


/* Tool */

string typeToString(_Data_type type)
{
    switch (type)
    {
    case TYPE_INT:
        return "int";
        break;
    case TYPE_FLOAT:
        return "float";
        break;
    case TYPE_CHAR:
        return "char";
        break;
    case TYPE_STRING:
        return "java.lang.String";
        break; 
    case TYPE_BOOL:
        return "int";
        break;
    default:
        break;
    }
    return "void";
}