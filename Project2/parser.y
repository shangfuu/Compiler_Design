%{
#define YACC_DEBUG 1
#define Trace(t)    if(YACC_DEBUG){ cout << "Trace: " << t << endl; }

#include "symTable.h"
#include "lex.yy.cpp"


// Global Symbol Tables
SymbolTables symbol_tables;

void yyerror(string);

// Insert ID in current table (tables[top]).
void insertTableEntry(SymInfo*);
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
%type <dataType> type return_type function_invocation
%type <dataValue> expression literal_const
%type <func_arg> arg
%type <func_args> formal_args
%type <func_call> comma_separated_expression

%start program

%%
program:
                OBJECT ID
                {
                    Trace("Reducing to program\n");
                    // Insert ID in current table.
                    insertTableEntry(new SymInfo(*$2, DEC_OBJECT));
                }
                '{' var_const_decs method_decs '}'
                {
                    symbol_tables.dump();
                    // End block then pop current table.
                    symbol_tables.pop_table();
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
                    insertTableEntry(new SymInfo(*$2, DEC_VAL, $4, *$6));
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
                    insertTableEntry(new SymInfo(*$2, DEC_VAR, $4, *$6));
                }
                | VAR ID ':' type
                {
                    insertTableEntry(new SymInfo(*$2, DEC_VAR, $4));
                }
                | VAR ID '=' expression
                {
                    insertTableEntry(new SymInfo(*$2, DEC_VAR, *$4));
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
                DEF ID '(' formal_args ')' return_type
                {
                    Trace("Reducing to method declartion");
                    // New a function type STEI.
                    SymInfo* func = new SymInfo(*$2, DEC_DEF);
                    // Add function arg type. use to check.
                    for(int i = 0 ; i < $4->size(); i++)
                    {
                        func->add_arg_type((*$4)[i]->get_data_type());
                    }
                    func->set_return_type($6);

                    // Add func into current table.
                    insertTableEntry(func);

                    /* Create a new child table. */
                    symbol_tables.add_table();
                    // Add func ags into new table.
                    for (int i = 0 ; i < $4->size(); i++)
                    {
                        insertTableEntry((*$4)[i]);
                    }
                }
                '{' var_const_decs statements '}'
                {
                    symbol_tables.dump();
                    // End block then pop current table.
                    symbol_tables.pop_table();
                }
                /* Parentheses are not required when no arguments are declared */
                | DEF ID return_type
                {
                    Trace("Reducing to method declartion");
                    // New a function type STEI.
                    SymInfo* func = new SymInfo(*$2, DEC_DEF);
                    func->set_return_type($3);
                    // Add func into current table.
                    insertTableEntry(func);

                    /* Create a new child table. */
                    symbol_tables.add_table();
                }
                '{' var_const_decs statements '}'
                {
                    symbol_tables.dump();
                    // End block then pop current table.
                    symbol_tables.pop_table();
                }
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
                    // Method args are all immutable
                    $$ = new SymInfo(*$1, DEC_VAL, $3);
                }
                ;

statements:     
                statement statements
                | /* zero or more */
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
                    Trace("Reducing to simple statement");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    // Declare must be DEC_VAR
                    if (id->get_declare_type() != DEC_VAR)
                    {
                        yyerror(string("ID " + *$1 + " VAL can't be assign"));
                    }   
                    // Only assign with same data type
                    if (id->get_data_type() != $3->get_data_type())
                    {
                        yyerror(string("ID " + *$1 + " Assign with different Data type"));
                    }
                    // Set variable data
                    id->set_data(*$3);
                }
                | ID '[' expression ']' '=' expression
                {
                    Trace("Reducing to simple statement");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    // Index must be int
                    if ($3->get_data_type() != TYPE_INT)
                    {
                        yyerror(string("ID " + *$1 + " array index must be int"));
                    }
                    // Declare type must be DEC_ARRAY;
                    if (id->get_declare_type() != DEC_ARRAY)
                    {
                        yyerror(string("ID " + *$1 + " not array type"));
                    }
                    // Only assign with same data type
                    if (id->get_array_data_type() != $6->get_data_type())
                    {
                        yyerror(string("ID " + *$1 + " Assign with different Data type"));
                    }
                    // Check if index out of range
                    if (id->get_array_length() <= $3->get_int())
                    {
                        yyerror(string("ID " + *$1 + " array index out of range"));
                    }
                    // Set array[index] data.
                    id->set_array_data($3->get_int(), *$6);
                }
                | PRINT '(' expression ')'
                | PRINTLN '(' expression ')'
                | READ ID
                | RETURN expression
                | RETURN
                ;

expression:     
                literal_const
                {
                    Trace("Reducing to literal constants expression");
                    $$ = $1;
                }
                | function_invocation
                {
                    // Only get function type
                    Data* d = new Data();
                    d->set_data_type($1);
                    $$ = d;
                }
                | ID
                {
                    Trace("Reducing to ID expression");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    // Return ID data.
                    $$ = id->get_data();
                }
                | ID '[' expression ']'
                {
                    Trace("Reducing to array expression");
                    // Check if ID exist in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
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
                /* Arithmetic expression */
                | '-' expression %prec UMINUS
                {
                    Trace("Reducing to UMINUS expression");
                    if ($2->get_data_type() == TYPE_INT)
                    {
                        $2->set_value($2->get_int() * -1);
                        $$ = $2;
                    }
                    else if ($2->get_data_type() == TYPE_FLOAT)
                    {
                        $2->set_value($2->get_float() * -1);
                        $$ = $2;
                    }
                    else 
                    {
                        yyerror("TYPE ERROR in - exp");
                    }
                }
                | expression '*' expression
                {
                    Trace("Reducing to exp * exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() * $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() * $3->get_float());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp * exp");
                    }
                }
                | expression '/' expression
                {
                    Trace("Reducing to exp / exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() / $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() / $3->get_float());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp / exp");
                    }
                }
                | expression '+' expression
                {
                    Trace("Reducing to exp + exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() + $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() + $3->get_float());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp + exp");
                    }
                }
                | expression '-' expression
                {
                    Trace("Reducing to exp - exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() - $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() - $3->get_float());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp - exp");
                    }
                }
                | expression LT expression
                {
                    Trace("Reducing to exp < exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() < $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() < $3->get_float());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() < $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp < exp");
                    }
                    $$->set_data_type(TYPE_BOOL);
                }
                | expression LE expression
                {
                    Trace("Reducing to exp <= exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() <= $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() <= $3->get_float());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() <= $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp <= exp");
                    }
                    $$->set_data_type(TYPE_BOOL);
                }
                | expression GT expression
                {
                    Trace("Reducing to exp > exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() > $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() > $3->get_float());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() > $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp > exp");
                    }
                    $$->set_data_type(TYPE_BOOL);
                }
                | expression GE expression
                {
                    Trace("Reducing to exp >= exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() >= $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() >= $3->get_float());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() >= $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp >= exp");
                    }
                    $$->set_data_type(TYPE_BOOL);
                }
                | expression EE expression
                {
                    Trace("Reducing to exp == exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() == $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() == $3->get_float());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() == $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp == exp");
                    }
                    $$->set_data_type(TYPE_BOOL);
                }
                | expression NE expression
                {
                    Trace("Reducing to exp != exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_INT)
                    {
                        $1->set_value($1->get_int() != $3->get_int());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_FLOAT)
                    {
                        $1->set_value($1->get_float() != $3->get_float());
                        $$ = $1;
                    }
                    else if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() != $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp != exp");
                    }
                    $$->set_data_type(TYPE_BOOL);
                }
                | NOT expression
                {
                    Trace("Reducing to ! exp");
                    if ($2->get_data_type() == TYPE_BOOL)
                    {
                        $2->set_value(!$2->get_bool());
                        $$ = $2;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in !exp");
                    }
                }
                | expression AND expression
                {
                    Trace("Reducing to exp && exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() && $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp && exp");
                    }
                }
                | expression OR expression
                {
                    Trace("Reducing to exp || exp");
                    if ($1->get_data_type() != $3->get_data_type())
                    {
                        yyerror("Types of the left/right-hand-side must be matched.");
                    }
                    if ($1->get_data_type() == TYPE_BOOL)
                    {
                        $1->set_value($1->get_bool() || $3->get_bool());
                        $$ = $1;
                    }
                    else
                    {
                        yyerror("TYPE ERROR in exp || exp");
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
                    Trace("Reducing to function invocation");
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                    if (id->get_declare_type() != DEC_DEF)
                    {
                        yyerror(string("ID " + *$1 +" function invocation must be declare as DEF"));
                    }
                    // Check if comma_separated_exp type is equal to function args
                    if (id->check_arg_match($3) == false)
                    {
                        yyerror("Function arg type mismatch");
                    }
                    if (id->get_return_type() == TYPE_NONE)
                    {
                        yyerror(string("ID " + *$1 + " function without return"));
                    }
                    $$ = id->get_return_type();
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
                    Trace("Reducing to block");
                    // Create a new child table
                    symbol_tables.add_table();
                }
                var_const_decs one_or_more_statements '}'
                {
                    symbol_tables.dump();
                    // Pop the current table.
                    symbol_tables.pop_table();
                }
                ;

one_or_more_statements:
                statement statements /* one or more*/
                ;

condition:
                IF '(' expression ')'
                {
                    Trace("Reducing to IF ELSE condition");
                    if ($3->get_data_type() != TYPE_BOOL)
                    {
                        yyerror("IF condition must be boolean");
                    }
                }
                else
                ;

else:
                block_or_simple_statement ELSE block_or_simple_statement
                | block_or_simple_statement     /* with out else */
                ;

block_or_simple_statement:
                block | simple_statement
                ;

loop:
                WHILE '(' expression ')'
                {
                    Trace("Reducing to while");
                    if ($3->get_data_type() != TYPE_BOOL)
                    {
                        yyerror("WHILE expression must be boolean");
                    }
                }
                block_or_simple_statement
                | FOR '(' ID '<' '-' CONST_INT TO CONST_INT ')'
                {
                    Trace("Reducing to for");
                }
                block_or_simple_statement
                ;

procedure_invocation:
                ID
                {
                    Trace("Reducing to procedure invocation");
                    // Check if ID procedure is in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                }
                | ID '(' comma_separated_expression ')'
                {
                     Trace("Reducing to procedure invocation");
                    // Check if ID procedure is in symbol table.
                    SymInfo* id = symbol_tables.look_up(*$1);
                    if (id == NULL)
                    {
                        yyerror(string("ID " + *$1 +" Not FOUND"));
                    }
                }
                ;


%%

void insertTableEntry(SymInfo *id)
{
    if (symbol_tables.insert(id) == -1)
    {
        yyerror("Insert table entry faild: " + id->get_id_name());
    }
}

void yyerror(string msg)
{
    cout << "yyerror: " << msg << endl;
}

main(int argc, char* argv[])
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
    

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
    else
        cout << "Parsing succedd!" << endl;
}
