lex_file = proj1.l

all: lex
lex: $(lex_file)
	$(LEX) $(lex_file)
	cc -o scanner -O lex.yy.c -ll

.PHONT: d

d: $(lex_file)
	$(LEX) -d $(lex_file)
	cc -o scanner -O lex.yy.c -ll

