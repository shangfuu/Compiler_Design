%{
#define YACC_DEBUG 0
#define Trace(t)    if(YACC_DEBUG){ cout << "Trace: " << t << endl; }

// #include <math.h>
#include "symTable.h"
#include "lex.yy.cpp"
#include "JBC.h"

// Global Symbol Tables
SymbolTables symbol_tables;

void yyerror(string);

// Flags
bool hasDefineMain = false;
bool error = false;

// 
string filename;
ofstream JBC;

// Variable stack index
int stackVarID = 0;

// Insert ID in current table (tables[top]), return 1 if succedd.
int insertTableEntry(SymInfo*);
%}

/* Can be used in yylval, use in yacc $, non-terminal type */
%union{
    int 	ival;
    float 	fval;
    char    cval;
    bool    bval;

    // pointer use *$
    string *sval;

    // Non-terminal type
    _Data_type dataType;
    Data *dataValue;

    SymInfo *func_arg;
    vector<SymInfo*>* func_args;
    vector<Data*>* func_call;
}

/* tokens */

// KEYWORDS
%token BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT 
%token NIL OBJECT PRINT PRINTLN REPEAT RETURN STRING TO TYPE VAL VAR WHILE READ

// OPERATOR Relational
%token LT LE GT GE NE EE

// OPERATOR Logical
%token AND OR NOT

// IDENTIFIERS
%token  <sval>  ID

// CONSTANTS
%token  <bval>  CONST_BOOL
%token  <ival>  CONST_INT
%token  <fval>  CONST_REAL
%token  <sval>  CONST_STRING
%token  <cval>  CONST_CHAR

/* operator PRECEDENCE */
%left OR
%left AND
%left NOT
%left LT LE GT GE NE EE
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

/* Return type of NON-TERMINAL */
%type <dataType> type return_type
%type <dataValue> expression literal_const function_invocation
%type <func_arg> arg
%type <func_args> formal_args
%type <func_call> comma_separated_expression

%start program

%%
program:
                OBJECT ID
                {
                    Trace("REDUCE < PROGRAM >\n");
                    // Insert ID in current table.
                    insertTableEntry(new SymInfo(*$2, DEC_OBJECT));
                    // Generate Java byte Code
                    JBC_Init();
                }
                '{' var_const_decs method_decs '}'
                {
                    symbol_tables.dump();
                    // If no main declare then Error
                    if (hasDefineMain == false) {
                        yyerror("No Main function Declare");
                    }
                    // End block then pop current table.
                    symbol_tables.pop_table();
                    JBC_End();
                }
                ;

var_const_decs: 
                var_const_dec var_const_decs
                | /* zero or more */
                ;

var_const_dec:  
                const_dec | var_dec
                ;

const_dec:
                VAL ID ':' type '=' expression
                {
                    if ($4 != $6->get_data_type()) 
                    {
                        yyerror("Declartion Type Inconsistent");
                    }
                    else
                    {
                        insertTableEntry(new SymInfo(*$2, DEC_VAL, $4, *$6));
                    }
                }
                | VAL ID '=' expression
                {
                    insertTableEntry(new SymInfo(*$2, DEC_VAL, *$4));
                }
                ;

var_dec:
                VAR ID ':' type '=' expression
                {
                    if ($4 != $6->get_data_type())
                    {
                        yyerror("Declartion Type Inconsistent");
                    }
                    else
                    {
                        if ( insertTableEntry(new SymInfo(*$2, DEC_VAR, $4, *$6)) )
                        {
                            if (symbol_tables.isGlobalTable())
                            {
                                JBC_GlobalVar(*$2);
                                // JBC_AssignGlobal(*$2);
                            }
                            else
                            {
                                SymInfo *id = symbol_tables.look_up(*$2);
                                id->stackID = stackVarID;
                                JBC_LocalVar(stackVarID++);
                            }
                        }
                    }
                }
                | VAR ID ':' type
                {
                    if (insertTableEntry(new SymInfo(*$2, DEC_VAR, $4)))
                    {
                        if (symbol_tables.isGlobalTable())
                        {
                            JBC_GlobalVar(*$2);
                        }
                        else 
                        {
                            JBC_PushInt(0);
                            SymInfo *id = symbol_tables.look_up(*$2);
                            id->stackID = stackVarID;
                            JBC_LocalVar(stackVarID++);
                        }
                    }
                }
                | VAR ID '=' expression
                {
                    if (insertTableEntry(new SymInfo(*$2, DEC_VAR, *$4)))
                    {
                        if (symbol_tables.isGlobalTable())
                        {
                            JBC_GlobalVar(*$2);
                            // JBC_AssignGlobal(*$2);
                        }
                        else 
                        {
                            SymInfo *id = symbol_tables.look_up(*$2);
                            id->stackID = stackVarID;
                            JBC_LocalVar(stackVarID++);
                        }
                    }
                }
                | VAR ID ':' type '[' CONST_INT ']'   /* Array */
                {
                    if ($6 < 1)
                    {
                        yyerror("Array length must greater than 1");
                    }
                    insertTableEntry(new SymInfo(*$2, DEC_ARRAY, $4, $6));
                }
                ;

type:
                INT
                {
                    $$ = TYPE_INT;
                }
                | FLOAT
                {
                    $$ = TYPE_FLOAT;
                }
                | CHAR
                {
                    $$ = TYPE_CHAR;
                }
                | STRING
                {
                    $$ = TYPE_STRING;
                }
                | BOOLEAN
                {
                    $$ = TYPE_BOOL;
                }
                ;

method_decs:    
                method_dec method_decs
                | method_dec
                /* one or more*/
                ;

method_dec:     
                DEF ID 
                {
                    Trace("REDUCE < METHOD () >");
                    // New a function type STEI.
                    SymInfo* func = new SymInfo(*$2, DEC_DEF);
                    // Add func into current table.
                    insertTableEntry(func);
                    // Zero out variable stack
                    stackVarID = 0;

                    /* Create a new child table. */
                    symbol_tables.add_table();
                }
                '(' formal_args ')' return_type
                {
                    SymInfo* func = symbol_tables.look_up(*$2);
                    if (func != NULL)
                    {
                        func->set_return_type($7);

                        // Add function arg type. use to check.
                        for(int i = 0 ; i < $5->size(); i++)
                        {
                            func->add_arg_type((*$5)[i]->get_data_type());
                        }

                        // Check if main declare
                        if (func->get_id_name() == "main") 
                        {
                            hasDefineMain = true;
                            JBC_MainBegin();
                        }
                        else
                        {
                            JBC_FuncBegin(*func);
                        }
                    }
                    // // Add func ags into new table.
                    // for (int i = 0 ; i < $5->size(); i++)
                    // {
                    //     insertTableEntry((*$5)[i]);
                    // }
                }
                '{' var_const_decs_statements '}'
                {
                    SymInfo *func = symbol_tables.look_up(*$2);
                    JBC_FuncEnd(*func);
                    
                    symbol_tables.dump();
                    // End block then pop current table.
                    symbol_tables.pop_table();
                }
                /* Parentheses are not required when no arguments are declared */
                | DEF ID return_type
                {
                    Trace("REDUCE < METHOD >");
                    // New a function type STEI.
                    SymInfo* func = new SymInfo(*$2, DEC_DEF);
                    
                    func->set_return_type($3);
                    // Zero out variable stack
                    stackVarID = 0;

                    // Check if main declare
                    if (func->get_id_name() == "main") 
                    {
                        hasDefineMain = true;
                        JBC_MainBegin();
                    }
                    else
                    {
                        JBC_FuncBegin(*func);
                    }
                    
                    // Add func into current table.
                    insertTableEntry(func);

                    /* Create a new child table. */
                    symbol_tables.add_table();
                }
                '{' var_const_decs_statements '}'
                {
                    SymInfo *func = symbol_tables.look_up(*$2);
                    JBC_FuncEnd(*func);

                    symbol_tables.dump();
                    // End block then pop current table.
                    symbol_tables.pop_table();
                }
                ;

var_const_decs_statements:
                var_const_decs_statement var_const_decs_statements
                |
                ;

var_const_decs_statement:
                var_const_dec | statement
                ;

return_type:    
                ':' type
                {
                    $$ = $2;
                }
                | /* No return type */
                {
                    $$ = TYPE_NONE;
                }
                ;

formal_args:    
                arg
                {
                    // Create a vector which store only one arg.
                    $$ = new vector<SymInfo*>();
                    $$->push_back($1);
                }
                | arg ',' formal_args
                {
                    // Store arg into formal_args
                    $3->push_back($1);
                    $$ = $3;
                }
                | /* zero or more */
                {
                    $$ = new vector<SymInfo*>();
                }
                ;

arg:            
                ID ':' type
                {
                    $$ = new SymInfo(*$1, DEC_VAR, $3);
                    if (insertTableEntry($$))
                    {
                        $$->stackID = stackVarID++;
                    }
                }
                ;

statement:
                simple_statement
                | block
                | condition
                | loop
                | procedure_invocation
                ;

simple_statement:
                ID '=' expression
                {
                    Trace("REDUCE < ID = EXP >");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    else
                    {
                        // Declare must be DEC_VAR
                        if (id->get_declare_type() != DEC_VAR)
                        {
                            yyerror(string("ID " + *$1 + " VAL can't be assign"));
                        }   
                        // Only assign with same data type
                        else if (id->get_data_type() != $3->get_data_type())
                        {
                            yyerror(string("ID " + *$1 + " Assign with different Data type"));
                        }
                        else 
                        {
                            // Set variable data
                            id->set_data(*$3);
                            if (id->isGlobal())
                            {
                                JBC_AssignGlobal(id->get_id_name());
                            }
                            else
                            {
                                JBC_AssignLocal(id->stackID);
                            }
                        }
                    }
                }
                | ID '[' expression ']' '=' expression
                {
                    Trace("REDUCE < ID[EXP] = EXP >");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    else 
                    {
                        // Index must be int
                        if ($3->get_data_type() != TYPE_INT)
                        {
                            yyerror(string("ID " + *$1 + " array index must be int"));
                        }
                        // Declare type must be DEC_ARRAY;
                        else if (id->get_declare_type() != DEC_ARRAY)
                        {
                            yyerror(string("ID " + *$1 + " not array type"));
                        }
                        // Only assign with same data type
                        else if (id->get_array_data_type() != $6->get_data_type())
                        {
                            yyerror(string("ID " + *$1 + " Assign with different Data type"));
                        }
                        // Check if index out of range
                        else if (id->get_array_length() <= $3->get_int())
                        {
                            yyerror(string("ID " + *$1 + " array index out of range"));
                        }
                        else 
                        {
                            // Set array[index] data.
                            id->set_array_data($3->get_int(), *$6);
                        }
                    }
                }
                | PRINT
                {
                    Trace("REDUCE < PRINT EXP >");
                    JBC_PrintBegin();
                } 
                expression
                {
                    JBC_Print($3->get_data_type());
                }
                | PRINTLN 
                {
                    Trace("REDUCE < PRINTLN EXP >");
                    JBC_PrintBegin();
                }
                expression
                {
                    JBC_PrintLn($3->get_data_type());
                }
                | READ ID
                | RETURN expression
                {
                    Trace("REDUCE < RETURN EXP >");
                    JBC_IReturn();
                }
                | RETURN
                {
                    Trace("REDUCE < RETURN >");
                    JBC_Return();
                }
                ;

expression:     
                '(' expression ')'
                {
                    Trace("REDUCE < ( EXP ) >");
                    $$ = $2;
                }
                | literal_const
                {
                    Trace("REDUCE < LITERAL CONST >");
                    $$ = $1;
                    if (!symbol_tables.isGlobalTable())
                    {
                        if ($1->get_data_type() == TYPE_STRING)
                        {
                            JBC_PushStr(*($1->get_string()));
                        }
                        else if ($1->get_data_type() == TYPE_INT)
                        {
                            JBC_PushInt($1->get_int());
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            JBC_PushInt($1->get_bool()? 1:0);
                        }
                    }   
                }
                | function_invocation
                | ID
                {
                    Trace("REDUCE < ID >");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    else
                    {
                        // Return ID data.
                        Data *idData = id->get_data();
                        $$ = id->get_data();
                        
                        // JBC
                        if (id->get_declare_type() == DEC_VAL)
                        {
                            if (id->get_data_type() == TYPE_INT)
                            {
                                int val = idData->get_int();
                                JBC_PushInt(val);
                            }
                            else if (id->get_data_type() == TYPE_BOOL)
                            {
                                int val = idData->get_bool() ? 1 : 0;
                                JBC_PushInt(val);
                            }
                            else if (id->get_data_type() == TYPE_STRING)
                            {
                                JBC_PushStr(*(idData->get_string()));
                            }
                        }
                        else if (id->get_declare_type() == DEC_VAR)
                        {
                            // global
                            if (id->isGlobal())
                            {
                                JBC_getGlobalVar(id->get_id_name());
                            }
                            // local
                            else
                            {
                                JBC_getLocalVar(id->stackID);
                            }
                        }
                    }
                }
                | ID '[' expression ']'
                {
                    Trace("REDUCE < ID[EXP] >");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    else
                    {
                        // Check if index out of range
                        if (id->get_array_length() <= $3->get_int())
                        {
                            yyerror(string("ID " + *$1 + " array index out of range"));
                        }
                        // Declare type must be DEC_ARRAY;
                        if (id->get_declare_type() != DEC_ARRAY)
                        {
                            yyerror(string("ID " + *$1 + " not array type"));
                        }
                        // Return ID[index] data.
                        $$ = id->get_array_data($3->get_int());
                    }
                }
                /* Arithmetic expression */
                | '-' expression %prec UMINUS
                {
                    Trace("REDUCE < - EXP >");
                    // Only calculate the type INT and FLOAT
                    if ($2->get_data_type() == TYPE_INT)
                    {
                        Data *d = new Data(TYPE_INT, $2->get_int() * -1);
                        $$ = d;
                        JBC_OP('u');
                    }
                    else if ($2->get_data_type() == TYPE_FLOAT)
                    {
                        Data *d = new Data(TYPE_FLOAT, $2->get_float() * -1);
                        $$ = d;
                    }
                    else 
                    {
                        yyerror("TYPE ERROR in - exp");
                    }
                }
                /* | expression '%' expression
                {
                    Trace("REDUCE <EXP % EXP>");
                    // Only calculate the type INT and FLOAT
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            Data *d = new Data(TYPE_INT, $1->get_int() % $3->get_int());
                            $$ = d;
                            JBC_OP('%');
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            Data *d = new Data(TYPE_FLOAT, fmod($1->get_float(), $3->get_float()));
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp % exp");
                        }
                    }
                } */
                | expression '*' expression
                {
                    Trace("REDUCE < EXP * EXP >");
                    // Only calculate the type INT and FLOAT
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            Data *d = new Data(TYPE_INT, $1->get_int() * $3->get_int());
                            $$ = d;
                            JBC_OP('*');
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            Data *d = new Data(TYPE_FLOAT, $1->get_float() * $3->get_float());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp * exp");
                        }
                    }
                }
                | expression '/' expression
                {
                    Trace("REDUCE < EXP / EXP >");
                    // Only calculate the type INT and FLOAT
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            Data *d = new Data(TYPE_INT, $1->get_int() / $3->get_int());
                            $$ = d;
                            JBC_OP('/');
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            Data *d = new Data(TYPE_FLOAT, $1->get_float() / $3->get_float());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp / exp");
                        }
                    }
                }
                | expression '+' expression
                {
                    Trace("REDUCE < EXP + EXP >");
                    // Only calculate the type INT and FLOAT
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            Data *d = new Data(TYPE_INT, $1->get_int() + $3->get_int());
                            $$ = d;
                            JBC_OP('+');
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            Data *d = new Data(TYPE_FLOAT, $1->get_float() + $3->get_float());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp + exp");
                        }
                    }
                }
                | expression '-' expression
                {
                    Trace("REDUCE < EXP - EXP >");
                    // Only calculate the type INT and FLOAT
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            Data *d = new Data(TYPE_INT, $1->get_int() - $3->get_int());
                            $$ = d;
                            JBC_OP('-');
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            Data *d = new Data(TYPE_FLOAT, $1->get_float() - $3->get_float());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp - exp");
                        }
                    }
                }
                | expression LT expression
                {
                    Trace("REDUCE < EXP < EXP >");
                    // Only calculate the type INT, FLOAT and BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        // Used to return
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            d->set_value($1->get_int() < $3->get_int());
                            $$ = d;
                            JBC_RELOP(IFLT);
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            d->set_value($1->get_float() < $3->get_float());
                            $$ = d;
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            
                            d->set_value($1->get_bool() < $3->get_bool());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp < exp");
                        }
                    }
                }
                | expression LE expression
                {
                    Trace("REDUCE < EXP <= EXP >");
                    // Only calculate the type INT, FLOAT and BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            d->set_value($1->get_int() <= $3->get_int());
                            $$ = d;
                            JBC_RELOP(IFLE);
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            d->set_value($1->get_float() <= $3->get_float());
                            $$ = d;
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() <= $3->get_bool());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp <= exp");
                        }
                    }
                }
                | expression GT expression
                {
                    Trace("REDUCE < EXP > EXP >");
                    // Only calculate the type INT, FLOAT and BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            d->set_value($1->get_int() > $3->get_int());
                            $$ = d;
                            JBC_RELOP(IFGT);
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            d->set_value($1->get_float() > $3->get_float());
                            $$ = d;
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() > $3->get_bool());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp > exp");
                        }
                    }
                }
                | expression GE expression
                {
                    Trace("REDUCE < EXP >= EXP >");
                    // Only calculate the type INT, FLOAT and BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            d->set_value($1->get_int() >= $3->get_int());
                            $$ = d;
                            JBC_RELOP(IFGE);
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            d->set_value($1->get_float() >= $3->get_float());
                            $$ = d;
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() >= $3->get_bool());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp >= exp");
                        }
                    }
                }
                | expression EE expression
                {
                    Trace("REDUCE < EXP == EXP >");
                    // Only calculate the type INT, FLOAT and BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            d->set_value($1->get_int() == $3->get_int());
                            $$ = d;
                            JBC_RELOP(IFEE);
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            d->set_value($1->get_float() == $3->get_float());
                            $$ = d;
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() == $3->get_bool());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp == exp");
                        }
                    }
                }
                | expression NE expression
                {
                    Trace("REDUCE < EXP != EXP >");
                    // Only calculate the type INT, FLOAT and BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_INT)
                        {
                            d->set_value($1->get_int() != $3->get_int());
                            $$ = d;
                            JBC_RELOP(IFNE);
                        }
                        else if ($1->get_data_type() == TYPE_FLOAT)
                        {
                            d->set_value($1->get_float() != $3->get_float());
                            $$ = d;
                        }
                        else if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() != $3->get_bool());
                            $$ = d;
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp != exp");
                        }
                    }
                }
                | NOT expression
                {
                    Trace("REDUCE < ! EXP >");
                    // Only calculate the type BOOL
                    if ($2->get_data_type() == TYPE_BOOL)
                    {
                        Data *d = new Data(TYPE_BOOL, false);
                        d->set_value(!$2->get_bool());
                        $$ = d;
                        JBC_OP('!');
                    }
                    else
                    {
                        yyerror("TYPE ERROR in !exp");
                    }
                }
                | expression AND expression
                {
                    Trace("REDUCE < EXP && EXP >");
                    // Only calculate the type BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() && $3->get_bool());
                            $$ = d;
                            JBC_OP('&');
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp && exp");
                        }
                    }
                }
                | expression OR expression
                {
                    Trace("REDUCE < EXP || EXP >");
                    // Only calculate the type BOOL
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    else {
                        Data *d = new Data(TYPE_BOOL, false);
                        if ($1->get_data_type() == TYPE_BOOL)
                        {
                            d->set_value($1->get_bool() || $3->get_bool());
                            $$ = d;
                            JBC_OP('|');
                        }
                        else
                        {
                            yyerror("TYPE ERROR in exp || exp");
                        }
                    }
                }
                ;

literal_const:
                CONST_INT
                {
                    Data *d = new Data(TYPE_INT, $1);
                    $$ = d;
                }
                | CONST_REAL
                {
                    Data *d = new Data(TYPE_FLOAT, $1);
                    $$ = d;
                }
                | CONST_CHAR
                {
                    Data *d = new Data(TYPE_CHAR, $1);
                    $$ = d;
                }
                | CONST_STRING
                {
                    Data *d = new Data(TYPE_STRING, $1);
                    $$ = d;
                }
                | CONST_BOOL
                {
                    Data *d = new Data(TYPE_BOOL, $1);
                    $$ = d;
                }
                ;

function_invocation:
                ID '(' comma_separated_expression ')'
                {
                    Trace("REDUCE < ID(EXP) >");
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    else
                    {
                        if (id->get_declare_type() != DEC_DEF)
                        {
                            yyerror(string("ID " + *$1 +" function invocation must be declare as DEF"));
                        }
                        // Check if comma_separated_exp type is equal to function args
                        else if (id->check_arg_match($3) == false)
                        {
                            yyerror("Function arg type mismatch");
                        }
                        else if (id->get_return_type() == TYPE_NONE)
                        {
                            yyerror(string("ID " + *$1 + " function without return"));
                        }
                        else
                        {
                            $$ = new Data();
                            $$->set_data_type(id->get_return_type());
                            JBC_FuncInvo(*id);
                        }
                    }
                }
                ;

comma_separated_expression:
                expression
                {
                    $$ = new vector<Data*>();
                    $$->push_back($1);
                }
                | expression ',' comma_separated_expression
                {
                    $3->push_back($1);
                    $$ = $3;
                }
                | /* optional */
                {
                    $$ = new vector<Data*>();
                }
                ;

block:
                '{'
                {
                    Trace("REDUCE < BLOCK {} >");
                    // Create a new child table
                    symbol_tables.add_table();
                }
                var_const_decs_statements '}'
                {
                    symbol_tables.dump();
                    // Pop the current table.
                    symbol_tables.pop_table();
                }
                ;

condition:
                IF '(' expression ')'
                {
                    Trace("REDUCE < IF (EXP) >");
                    if ($3->get_data_type() != TYPE_BOOL)
                    {
                        yyerror("IF condition must be boolean");
                    }
                    else
                    {
                        JBC_IfBegin();
                    }
                }
                else
                ;

else:
                block_or_simple_statement ELSE 
                {
                    JBC_ElseBegin();
                }
                block_or_simple_statement
                {
                    JBC_IfElseEnd();
                }
                /* with out else */
                | block_or_simple_statement
                {
                    JBC_IfEnd();
                }
                ;

block_or_simple_statement:
                block | simple_statement
                ;

loop:
                WHILE 
                {
                    JBC_WhileBegin();
                }
                '(' expression ')'
                {
                    Trace("REDUCE < WHILE (EXP) >");
                    if ($4->get_data_type() != TYPE_BOOL)
                    {
                        yyerror("WHILE expression must be boolean");
                    }
                    else
                    {
                        JBC_WhileCondJump();
                    }
                }
                block_or_simple_statement
                {
                    JBC_WhileEnd();
                }
                | FOR '(' ID LT '-' CONST_INT TO CONST_INT ')'
                {
                    Trace("REDUCE < FOR >");
                }
                block_or_simple_statement
                ;

procedure_invocation:
                ID
                {
                    Trace("REDUCE < PROCEDURE ID >");
                    // Check if ID procedure is in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                }
                | ID '(' comma_separated_expression ')'
                {
                     Trace("REDUCE < PROCEDURE ID (COMMA-SEP-EXP) >");
                    // Check if ID procedure is in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                }
                ;


%%

int insertTableEntry(SymInfo *id)
{
    if (symbol_tables.insert(id) == -1)
    {
        yyerror("Insert table entry faild: " + id->get_id_name());
        return -1;
    }
    return 1;
}

void yyerror(string msg)
{
    cout << "yyerror: " << msg << endl;
    error = true;
}

int main(int argc, char* argv[])
{
    /* open the source program file */
    if (argc == 1) {
        yyin = stdin;
    }
    else if (argc == 2) {
        yyin = fopen(argv[1], "r");         /* open input file */
    }
    else {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    
    if (argc != 1)
    {
        filename = string(argv[1]);
        int dot = filename.find(".");
        filename = filename.substr(0, dot);
        JBC.open(filename + ".jasm");
    }

    // JBC file not opened
    if (!JBC)
    {
        cout << "Java Byte Code open error" << endl;
        exit(1);
    }

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
    if (!error)
        cout << "Parsing succeed!" << endl;
    JBC.close();
}
