%{
#define Trace(t)        printf(t)

#include "symTable.h"
#include "lex.yy.cpp"


// Global Symbol Tables
SymbolTables symbol_tables;

void yyerror(string);
%}

/* tokens */

// KEYWORDS
%token BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT READ
%token NIL OBJECT PRINT PRINTLN REPEAT RETURN STRING TO TYPE VAL VAR WHILE FALSE TRUE

// OPERATOR Relational
%token LT LE GT GE NE EE

// OPERATOR Logical
%token AND OR NOT

// IDENTIFIERS
%token ID

// CONSTANTS
%token CONST_INT CONST_REAL CONST_STRING CONST_CHAR


// TEMPLATE
%token SEMICOLON

%%
program:        ID semi
                {
                Trace("Reducing to program\n");
                }
                ;

semi:           SEMICOLON
                {
                Trace("Reducing to semi\n");
                }
                ;
%%

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
