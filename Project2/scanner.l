%{

// #include "y.tab.hpp"

#define LEX_DEBUG 0

#define LIST     strcat(buf,yytext)
// Add return
#define token(t) {	LIST; if(LEX_DEBUG){ printf("<%s>\n", #t);} return t; }
#define tokenInteger(t,i) {LIST; if(LEX_DEBUG){ printf("<%s: %d>\n",t,i);} }
#define tokenString(t,s) {LIST; if(LEX_DEBUG){ printf("<%s: %s>\n",t,s);} }

#define MAX_LINE_LENG 256

#include "hash_table.h"

#define IDENTIFIER "id"
#define INTEGER "int"
#define STRING "string"

int linenum = 1;
char buf[MAX_LINE_LENG];

HashTable * SymbolTable;

%}

%option noyywrap yylineno
%x COMMENTB

digit [0-9]
letter [a-zA-Z]

delim [,:.;\(\)\[\]\{\}]
OP_arith [-%+*/]
OP_relat <|<=|>=|>|==|!=
OP_logic "&&"|"||"|"!"

%%

{delim} {
		token(yytext);
		}

 /* OPERATOR */
 /* Abandoned */
= 		{
		token(yytext);
		}

 /* Arithmetic */
{OP_arith} {
		token(yytext);
		}

 /* Relational */
{OP_relat} {
		token(yytext);
		}

 /* Logical */
{OP_logic} {
		token(yytext);
		}

 /* KEYWORDS */
boolean {
		token(BOOLEAN);
		}

break   {
		token(BREAK);
		}

char	{
		token(CHAR);
		}

case 	{
		token(CASE);
		}

class 	{
		token(CLASS);
		}

continue {
		token(CONTINUE);
		}

def 	{
		token(DEF);
		}

do 		{
		token(DO);
		}

else 	{
		token(ELSE);
		}

exit 	{
		token(EXIT);
		}

float 	{
		token(FLOAT);
		}

for 	{
		token(FOR);
		}

if 		{
		token(IF);
		}

int 	{
		token(INT);
		}

null  	{
		token(NULL);
		}

object  {
		token(OBJECT);
		}

print 	{
		token(PRINT);
		}

println	{
		token(PRINTLN);
		}

repeat	{
		token(REPEAT);
		}

return	{
		token(RETURN);
		}

string	{
		token(STRING);
		}

to 		{
		token(TO);
		}

type	{
		token(TYPE);
		}

val		{
		token(VAL);
		}

var		{
		token(VAR);
		}

while	{
		token(WHILE);
		}

 /* KEYWORDS & BOOLEAN CONSTANTS */
false 	{
		token(FALSE);
		}

true	{
		token(TRUE);
		}


 /* IDENTIFIERS */
{letter}({digit}|{letter})* {
		insert(SymbolTable, yytext);
		tokenString(IDENTIFIER , yytext);
		}

 /* INTEGER CONSTANTS */
{digit}+ {
		tokenInteger(INTEGER, atoi(yytext));
		}

 /* REAL CONSTANTS */
[+-]?({digit}+\.{digit}*|{digit}*\.{digit}+)([Ee][+-]?[0-9]+)? {
		token(yytext);
		}

 /* STRING CONSTANTS */
\"(\"\"|[^\"\n])*\"	{

		int nextc = input();	// Read the next character
		if (nextc == '"') {
			unput(nextc);	// Put char back to read again later
			yymore();	// Cause the next token's yytext to include current yytext
		}
		/* Need Else Only, uppper code can delete */
		else { 
			char *tokenS = (char *)malloc(yyleng * sizeof(char));
			char *temp = (char *)malloc(yyleng * sizeof(char));

			// Take off the "" from the front and rear.
			for(int i = 1; i < yyleng - 1; i++) {
				temp[i-1] = yytext[i];
			}

			// Change "" to "
			for (int i = 0, j = 0; i < strlen(temp); i++) {
				if (temp[i] == '"') {
					if (i+1 < strlen(temp) && temp[i+1] == '"'){
						tokenS[j++] = temp[i];
						i = i + 1;
					}
				}
				else {
					tokenS[j++] = temp[i];
				}
			}
			tokenString(STRING, tokenS);
			free(tokenS);
			free(temp);
			unput(nextc);	// Put char back to read again later
		}
		}


 /* LINE COMMENTS */
\/\/[^\n]* 	{
		LIST;
		}

 /* BLOCK COMMENTS */
"/*"	{
		BEGIN COMMENTB;
		LIST;
		}

<COMMENTB>.	{
		// Matches everythin except newline.
		LIST;
		}

<COMMENTB>\n	{
		LIST;
		printf("%d: %s", linenum++, buf);
		buf[0] = '\0';
		}

<COMMENTB>"*/"	{
		BEGIN 0;
		LIST;
		}

<<EOF>> {
		yyterminate();
		}

 /* DISCARD TOKEN */
\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum, buf);
        printf("bad character:'%s'\n",yytext);
        //exit(-1);
		yyterminate();
        }

%%

int main(int argc, char const * argv) {
	// Open debug mode in lex
	yy_flex_debug = 1;
	
	SymbolTable = create();

	yylex();

	// Dumps all entries of the symbol table.
	printf("\nSymbol Table:\n");
	dump(SymbolTable);

	return 0;
}
