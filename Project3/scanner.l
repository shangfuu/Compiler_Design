%{

#include "y.tab.hpp"
#include "iostream"
#include "string"

#define LEX_DEBUG 0

#define LIST     strcat(buf,yytext)
// Add return
#define token(t) {	LIST; if(LEX_DEBUG){ std::cout << '<' << t << '>' << std::endl;} return t; }
#define tokenInteger(t,i) {LIST; if(LEX_DEBUG){ std::cout << '<' << t << ": " << i << '>' << std::endl;} }
#define tokenString(t,s) {LIST; if(LEX_DEBUG){ std::cout << '<' << t << ": " << s << '>' << std::endl;} }
#define tokenFloat(t,f)  {LIST; if(LEX_DEBUG){ std::cout << '<' << t << ": " << f << '>' << std::endl;} }
// #define token(t) {	LIST; if(LEX_DEBUG){ printf("<%s>\n", #t);} return t; }
// #define tokenInteger(t,i) {LIST; if(LEX_DEBUG){ printf("<%s: %d>\n",#t,i);} }
// #define tokenString(t,s) {LIST; if(LEX_DEBUG){ printf("<%s: %s>\n",#t,s);} }
// #define tokenFloat(t,f)  {LIST; if(LEX_DEBUG){ printf("<%s: %lf>\n",#t,f);} }

#define MAX_LINE_LENG 256


int linenum = 1;
char buf[MAX_LINE_LENG];
%}

%option noyywrap yylineno
%x COMMENTB

digit [0-9]
letter [a-zA-Z]

delim [,:.;\(\)\[\]\{\}]
OP_arith [-%+*/]
OP_relat <|<=|>=|>|==|!=
OP_logic "&&"|"||"|"!"
assign =

%%

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

 /* Change NULL to NILL because there will be error using c keyword NULL*/ 
null  	{
		token(NIL);
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
		// True False is both bool type, no difference.
		yylval.bval = false;
		token(CONST_BOOL);
		}

true	{
		// True False is both bool type, no difference.
		yylval.bval = true;
		token(CONST_BOOL);
		}

 /* Add KEYWORDS read */
read	{
		token(READ);
		}



 /* Delim */
{delim} {
		token(*yytext);
		}

 /* OPERATOR: new version */

 /* Arithmetic */
{OP_arith} {
		token(*yytext);
		}

 /* Assign */
{assign} {
		token(*yytext);
		}

 /* Relational */
"<"		{
		token(LT);
		}

"<="	{
		token(LE);
		}

">"		{
		token(GT);
		}

">="	{
		token(GE);
		}

"!="	{
		token(NE);
		}

"=="	{
		token(EE);
		}

 /* Logical */
"&&"	{
		token(AND);
		}

"||"	{
		token(OR);
		}

"!"		{
		token(NOT);
		}

 /* IDENTIFIERS */
{letter}({digit}|{letter})* {

		// insert(SymbolTable, yytext);
		tokenString("id" , yytext);
		yylval.sval = new string(yytext);
		return ID;
		}

 /* INTEGER CONSTANTS */
{digit}+ {
		tokenInteger("int", atoi(yytext));
		yylval.ival = atoi(yytext);
		return CONST_INT;
		}

 /* REAL CONSTANTS */
[+-]?({digit}+\.{digit}*|{digit}*\.{digit}+)([Ee][+-]?[0-9]+)? {
		tokenFloat("float", atof(yytext));
		yylval.fval = atof(yytext);
		return CONST_REAL;
		}

 /* STRING CONSTANTS */
\"(\"\"|[^\"\n])*\"	{

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

		tokenString("string", tokenS);
		yylval.sval = new string(tokenS);

		free(tokenS);
		free(temp);
		return CONST_STRING;
		}

 /* CHAR CONSTANTS */
\'([^\'\n])\'	{

		tokenString("char", yytext);
		// Not taking ''.
		yylval.cval = yytext[1];
		return CONST_CHAR;
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
		// Matches everything except newline.
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
		exit(-1);
        }

%%

