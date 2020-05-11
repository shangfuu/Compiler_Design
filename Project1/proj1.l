%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",t,i);}
#define tokenString(t,s) {LIST; printf("<%s: %s>\n",t,s);}

#define MAX_LINE_LENG 256

#define IDENTIFIER "id"
#define INTEGER "int"
#define STRING "string"

int linenum = 1;
char buf[MAX_LINE_LENG];

%}

%option noyywrap yylineno

digit [0-9]
letter [a-zA-Z]

delim [,:.;\(\)\[\]\{\}]
OP_arith [-%\+\*\/]
OP_relat <|<=|>=|>|==|!=
OP_logic "&&"|"||"|"!"

%%

{delim} {
		token(yytext);
		}

 /* OPERATOR */
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
		token("BOOLEAN");
		}

break   {
		token("BREAK");
		}

char	{
		token("CHAR");
		}

case 	{
		token("CASE");
		}

class 	{
		token("CLASS");
		}

continue {
		token("CONTINUE");
		}

def 	{
		token("DEF");
		}

do 		{
		token("DO");
		}

else 	{
		token("ELSE");
		}

exit 	{
		token("EXIT");
		}

float 	{
		token("FLOAT");
		}

for 	{
		token("FOR");
		}

if 		{
		token("IF");
		}

int 	{
		token("INT");
		}

null  	{
		token("NULL");
		}

object  {
		token("OBJECT");
		}

print 	{
		token("PRINT");
		}

println	{
		token("PRINTLN");
		}

repeat	{
		token("REPEAT");
		}

return	{
		token("RETURN");
		}

string	{
		token("STRING");
		}

to 		{
		token("TO");
		}

type	{
		token("TYPE");
		}

val		{
		token("VAL");
		}

var		{
		token("VAR");
		}

while	{
		token("WHILE");
		}

 /* KEYWORDS & BOOLEAN CONSTANTS */
false 	{
		token("FALSE");
		}

true	{
		token("TRUE");
		}


 /* IDENTIFIERS */
{letter}({digit}|{letter})* {
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
\"({letter}|{digit}|\"|\t|" ")*\"	{
		tokenString(STRING, yytext);
		}

 /* COMMENTS */

<<EOF>> {
		yyterminate();
		}

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


int main() {
	// Open debug mode in lex
	yy_flex_debug = 1;
	yylex();
	return 0;
}
