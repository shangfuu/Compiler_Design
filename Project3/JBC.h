#ifndef JBCFILE
#define JBCFILE

#include <iostream>
#include <fstream>
#include <stack>
#include "symTable.h"

extern string filename;
extern ofstream JBC;

/* Used in RELOP and Condition*/
enum _CONDITION {
    IFLT,
    IFLE,
    IFGT,
    IFGE,
    IFEE,
    IFNE,
};

/* For a single if or while */
struct L {
    // base n
    int base;
    L(int);
};

/* For all Program */
class GOTO_Manager{
private:
    int Ln;
public:
    GOTO_Manager();
    // Used for seperate each individual L, and first in last out
    stack<L> Lstack;
    // Push L and update Ln with specific step. Means start a block of if/while.
    void pushL(int);
    // Pop L Stack. Means end a block of if/while.
    void popL();
    // Update Ln, add 1 per time.
    int updateLn();
    // Take the current Ln base on L.
    int Lbase(int);
};

/* Initialization */

void JBC_Init();
void JBC_End();

/* Declarations for Variables and Constants */

// Global Variables
void JBC_GlobalVar(string);
// Local Variables
void JBC_LocalVar(int);

/* Expression */
// Get Global Variable
void JBC_getGlobalVar(string);
// Get Local Variable
void JBC_getLocalVar(int);

// Constant Int
void JBC_PushInt(int);
void JBC_PushStr(string);

// Arithmetic Operator
void JBC_OP(char);
// Conditional Operator
void JBC_RELOP(_CONDITION);   // NOT DONE

/* Statements */
// Statements Assign Local
void JBC_AssignLocal(int);
// Statements Assign Global
void JBC_AssignGlobal(string);

// Print
void JBC_PrintBegin();
void JBC_Print(_Data_type);
void JBC_PrintLn(_Data_type);

/* Function */
void JBC_MainBegin();
void JBC_FuncBegin(SymInfo);
void JBC_FuncEnd(SymInfo);
void JBC_FuncInvo(SymInfo);

void JBC_Return();
void JBC_IReturn();

/* IF ELSE */
void JBC_IfBegin();
void JBC_ElseBegin();
void JBC_IfEnd();
void JBC_IfElseEnd();

/* WHILE */
void JBC_WhileBegin();
void JBC_WhileEnd();
void JBC_WhileCondJump();

/* TOOL */
string typeToString(_Data_type );

#endif