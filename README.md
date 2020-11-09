# Compiler_Design

Build up a simple Scala compiler using lex and yacc in c++.
First project you will implement the scanner using lex, in the second project you will implement the syntactic definition in yacc, and in the last assignment you will generate assembly code for the Java Virtual Machine by augmenting your yacc
parser.

## Project1
Build up a lex scanner and symbol table to recognize token.

## Project2
Your assignment is to write an LALR(1) parser for the Scala− language. You will have to write the grammar and create a parser using yacc. Furthermore, you will do some simple checking of semantic correctness. Code generation will be performed in the third phase of the project.

### Assignment
You first need to write your symbol table, which should be able to perform the following tasks:
• Push a symbol table when entering a scope and pop it when exiting the scope.
• Insert entries for variables, constants, and procedure declarations.
• Lookup entries in the symbol table.
You then must create an LALR(1) grammar using yacc. You need to write the grammar following the syntactic and semantic definitions in the following sections. Once the LALR(1) grammar is defined, you can then execute yacc to produce a C program called “y.tab.c”, which contains the parsing function yyparse().
You must supply a main function to invoke yyparse(). The parsing function yyparse() calls yylex(). You will have to revise your scanner function yylex().

## Project3
Your assignment is to generate code (in Java assembly language) for the Scala− language. The generated code will then be translated to Java bytecode by a Java assembler.

### Assignment
Your assignment will be divided into the following parts:
• initialization
• parsing declarations for constants and variables
• code generation for expressions and statements
• code generation for conditional statements and while loops
• code generation for procedure calls
