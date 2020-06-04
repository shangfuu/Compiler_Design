CC = g++
CFLAG = -ll -ly -std=c++11 -W

LEX_FILE = scanner.l
YACC_FILE = parser.y
SYM_TABLE_H = symTable.h
SYM_TABLE_CPP = symTable.cpp

all: compile

compile: y.tab.cpp lex.yy.cpp $(SYM_TABLE_H) $(SYM_TABLE_CPP)
	$(CC) y.tab.cpp symTable.cpp -o proj2.o $(CFLAG)

y.tab.cpp: $(YACC_FILE)
	yacc -d $(YACC_FILE) -o y.tab.cpp

lex.yy.cpp: $(LEX_FILE) y.tab.hpp
	lex -o lex.yy.cpp $(LEX_FILE)


PHONY: clean

clean:
	-rm y.tab.*
	-rm *.o
	-rm lex.yy.*
