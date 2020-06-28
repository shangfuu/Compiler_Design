#include "JBC.h"

GOTO_Manager gotoM;

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
    JBC << "\t\tputstatic int " << filename << "." << id << endl;
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

void JBC_RELOP(_CONDITION op)
{
    JBC << "\t\tisub" << endl;
    switch (op) 
    {
    case IFLT: JBC << "\t\tiflt "; break;
    case IFLE: JBC << "\t\tifle "; break;
    case IFGT: JBC << "\t\tifgt "; break;
    case IFGE: JBC << "\t\tifge "; break;
    case IFEE: JBC << "\t\tifeq "; break;
    case IFNE: JBC << "\t\tifne "; break;
    }

    int L1 = gotoM.updateLn();
    JBC << "L" << L1 << endl;
    JBC << "\t\ticonst_0" << endl;

    int L2 = gotoM.updateLn();
    JBC << "\t\tgoto L" << L2 << endl;

    JBC << "\tL" << L1 << ":" << endl;
    JBC << "\t\ticonst_1" << endl;
    JBC << "\tL" << L2 << ":" << endl;
}

/* Print */

void JBC_PrintBegin()
{
    JBC << "\t\tgetstatic java.io.PrintStream java.lang.System.out" << endl;
}

void JBC_Print(_Data_type type)
{
    JBC << "\t\tinvokevirtual void java.io.PrintStream.print(" << typeToString(type) << ")" << endl;
}

void JBC_PrintLn(_Data_type type)
{
    JBC << "\t\tinvokevirtual void java.io.PrintStream.println(" << typeToString(type) << ")" << endl;
}

/* Function */

void JBC_MainBegin()
{
    JBC << "\tmethod public static void main(java.lang.String[])" << endl;
    JBC << "\tmax_stack 15" << endl << "\tmax_locals 15" << endl << "\t{" << endl;
}

void JBC_FuncBegin(SymInfo id)
{
    JBC << "\tmethod public static " << typeToString(id.get_return_type()) << " " << id.get_id_name() << "(";
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

/* GOTO Manager */

L::L(int Ln)
{
    base = Ln;
}

GOTO_Manager::GOTO_Manager()
{
    Ln = 0;
}

void GOTO_Manager::pushL(int step)
{
    // Push current Ln and how much step can go.
    Lstack.push(L(Ln));
    Ln += step;
}

void GOTO_Manager::popL()
{
    Lstack.pop();
}

int GOTO_Manager::updateLn()
{
    return Ln++;
}

int GOTO_Manager::Lbase(int n)
{
    if (Lstack.top().base + n < Ln)
        return Lstack.top().base + n;
    else
        return Ln;
}

/* IF ELSE */
void JBC_IfBegin()
{
    // If have 2 Ln.
    gotoM.pushL(2);
    JBC << "\t\tifeq L" << gotoM.Lbase(0) << endl;
}

void JBC_IfEnd()
{
    JBC << "\tL" << gotoM.Lbase(0) << ":" << endl;
    gotoM.popL();
}
    
void JBC_ElseBegin()
{
    JBC << "\t\tgoto L" << gotoM.Lbase(1) << endl;
    JBC << "\tL" << gotoM.Lbase(0) << ":" << endl;
}

void JBC_IfElseEnd()
{
    JBC << "\tL" << gotoM.Lbase(1) << ":" << endl;
    gotoM.popL();
}

/* WHILE */
void JBC_WhileBegin()
{
    // While have 2 Ln.
    gotoM.pushL(2);
    JBC << "\tL" << gotoM.Lbase(0) << ":" << endl;
}

void JBC_WhileEnd()
{
    JBC << "\t\tgoto L" << gotoM.Lbase(0) << ":" << endl;
    JBC << "\tL" << gotoM.Lbase(1) << ":" << endl;
    gotoM.popL();
}

void JBC_WhileCondJump()
{
    JBC << "\t\tifeq L" << gotoM.Lbase(1) << ":" << endl;;
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