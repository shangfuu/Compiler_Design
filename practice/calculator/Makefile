
all: lex
lex: calculator.l
	lex calculator.l
	cc -o scanner -O lex.yy.c -ll -lm

