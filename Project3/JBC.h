#ifndef JBCFILE
#define JBCFILE

#include <iostream>
#include <fstream>
#include <stack>
#include "symTable.h"

extern string filename;
extern ofstream JBC;

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
void JBC_RELOP();   // NOT DONE

/* Statements */

// Statements Assign Local
void JBC_AssignLocal(int);
// Statements Assign Global
void JBC_AssignGlobal(string);

// Print
void JBC_PrintStart();
void JBC_Print(_Data_type);
void JBC_PrintLn(_Data_type);

/* Function */
void JBC_MainStart();
void JBC_FuncStart(SymInfo);
void JBC_FuncEnd(SymInfo);
void JBC_FuncInvo(SymInfo);

void JBC_Return();
void JBC_IReturn();

/* Tool */
string typeToString(_Data_type );

#endif