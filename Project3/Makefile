CC = g++
CFLAG = -ll -ly -std=c++11 -Wno-deprecated-register

LEX_FILE = scanner.l
YACC_FILE = parser.y
SYM_TABLE_H = symTable.h
SYM_TABLE_CPP = symTable.cpp
JBC_H = JBC.h
JBC_CPP = JBC.cpp

ifeq ($(shell uname -s), Darwin)
	javaa := ./javaa_mac
else
	javaa := ./javaa
endif

all: compile

compile: y.tab.cpp lex.yy.cpp $(SYM_TABLE_H) $(SYM_TABLE_CPP) $(JBC_H) $(JBC_CPP)
	$(CC) y.tab.cpp symTable.cpp $(JBC_CPP) -o compiler $(CFLAG)

y.tab.cpp: $(YACC_FILE)
	yacc -d $(YACC_FILE) -o y.tab.cpp

lex.yy.cpp: $(LEX_FILE) y.tab.hpp
	lex -o lex.yy.cpp $(LEX_FILE)

PHONY: clean run

clean:
	-rm y.tab.*
	-rm *.o
	-rm lex.yy.*
	-rm compiler
	-rm *.jasm
	-rm *.class
	-rm test_files/*.jasm
	-rm test_files/*.class

run: compiler
	./compiler $(file).scala
	$(javaa) $(file).jasm
	java $(file)

