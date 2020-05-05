%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n","t");}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n","t",i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n","t",s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];

%}

/* Operators */
Arith_OP [+-*/]
Relat_OP "<="|">="|"=="|"!="|"<"|">"
Logi_OP "&&"|"||"|"!"



%%

while {token("while");}

y {token('y');}

"x" {token('x');}

"("     {token('(');}

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


int main() {
	// Open debug mode in lex
	yy_flex_debug = 1;
	yylex();
	return 0;
}
