%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",t,i);}
#define tokenString(t,s) {LIST; printf("<%s: %s>\n",t,s);}

#define MAX_LINE_LENG 256

#include <stdio.h>

#define IDENTIFIER "id"
#define INTEGER "int"
#define STRING "string"

int linenum = 1;
char buf[MAX_LINE_LENG];


// Symbol Table: using hash table
#define TABLE_SIZE 53

typedef struct node_{
	char *name;
	struct node_ *next;
	int index;
} Node;

typedef struct hash_table_{
	Node **table;
	int size;
} HashTable;


HashTable* create();
int lookup(char*);
void insert(char*);
void dump();

// Hash function: djb2
unsigned int hash(unsigned char*);

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

 /* Hash Function: djb2 by Dan Bernstein */
unsigned int hash(unsigned char *str){
	unsigned int hash = 0U;
	int c;

	while(c = *str++){
		hash = ((hash << 5) + hash) ^ c;	// hash * 33 ^ c
	}
	return hash;
}

HashTable* create(){
	HashTable *symbol_table = malloc(sizeof(HashTable));
	symbol_table->table = malloc(sizeof(Node) * TABLE_SIZE);
	memset(symbol_table->table, 0, sizeof(Node) * TABLE_SIZE);

	return symbol_table;
}

int lookup(char *str){
	return NULL;
}

void insert(char *str){

}

void dump(){

}


int main() {
	// Open debug mode in lex
	yy_flex_debug = 1;
	yylex();
	
	return 0;
}
