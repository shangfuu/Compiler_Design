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
%type <dataValue> expression literal_const
%type <func_arg> arg
%type <func_args> formal_args

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
                    Trace("Reducing var const or methd decs");
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

expression:
                literal_const
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

method_decs:    
                method_dec method_decs
                | method_dec
                /* one or more*/
                ;

method_dec:     
                DEF ID '(' formal_args ')' return_type
                {

                }
                '{' var_const_decs statements '}'
                {

                }
                /* Parentheses are not required when no arguments are declared */
                | DEF ID return_type
                {

                }
                '{' var_const_decs statements '}'
                {

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

// May have some Error.
formal_args:    
                arg ',' formal_args
                {
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
                    // Set Declare type later.
                    $$ = new SymInfo(*$1, $3);
                }
                ;

statements:     /* zero or more */
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
}
