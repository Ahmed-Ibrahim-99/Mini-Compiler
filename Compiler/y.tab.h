
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* "%code requires" blocks.  */

/* Line 1676 of yacc.c  */
#line 1 ".\\lang.y"

    #include "lang.h"

    nodeType *conInt(int value);
    nodeType *conFloat(float value);
    nodeType *conStr(char *value);
    nodeType *conBool(bool value);
    nodeType *id(char *s);
    nodeType *symbolTable[SYM_LIMIT];
    nodeType *methodsSymbolTable[SYM_LIMIT];
    nodeType *methodOperands[METHOD_OPERANDS_LIMIT];
    nodeType *opr(int oper, int nops, ...);
    nodeType *setAndDeclare(char *variableName, nodeType* rhs, bool isConst);
    nodeType *defineMethod(char *methodName, nodeType* statements);
    nodeType *callMethod(char *methodName);
    int isVariableDeclared(char *variableName);
    int isMethodDeclared(char *methodName);
    int ex(nodeType *p);
    void addOperand(char *variableName);
    void passOperand(nodeType *p);
    void yyerror(char *);
    void printSymTable(int choice);
    static bool boolFile;




/* Line 1676 of yacc.c  */
#line 68 "y.tab.h"

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INTEGER = 258,
     typeMissMatch = 259,
     FLOAT = 260,
     STRING = 261,
     BOOL = 262,
     VARIABLE = 263,
     METHOD = 264,
     METHOD_VARIABLE = 265,
     WHILE = 266,
     IF = 267,
     PRINT = 268,
     CONST = 269,
     METHOD_DEF = 270,
     FOR = 271,
     SWITCH = 272,
     CASE = 273,
     REPEAT = 274,
     UNTIL = 275,
     BREAK = 276,
     CONTINUE = 277,
     GE = 278,
     LE = 279,
     EQ = 280,
     NE = 281,
     GT = 282,
     LT = 283,
     AND = 284,
     OR = 285,
     MINUS = 286,
     PLUS = 287,
     MULT = 288,
     DIV = 289,
     ASSIG = 290,
     WRONG_VARIABLE = 291,
     IFX = 292,
     ELSE = 293,
     UMINUS = 294
   };
#endif
/* Tokens.  */
#define INTEGER 258
#define typeMissMatch 259
#define FLOAT 260
#define STRING 261
#define BOOL 262
#define VARIABLE 263
#define METHOD 264
#define METHOD_VARIABLE 265
#define WHILE 266
#define IF 267
#define PRINT 268
#define CONST 269
#define METHOD_DEF 270
#define FOR 271
#define SWITCH 272
#define CASE 273
#define REPEAT 274
#define UNTIL 275
#define BREAK 276
#define CONTINUE 277
#define GE 278
#define LE 279
#define EQ 280
#define NE 281
#define GT 282
#define LT 283
#define AND 284
#define OR 285
#define MINUS 286
#define PLUS 287
#define MULT 288
#define DIV 289
#define ASSIG 290
#define WRONG_VARIABLE 291
#define IFX 292
#define ELSE 293
#define UMINUS 294




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 42 ".\\lang.y"

    int iValue;                 /* integer value */
    char sValue[100];                /* string Value */
    bool bValue;                
    float fValue;
    nodeType *nPtr;             /* node pointer */



/* Line 1676 of yacc.c  */
#line 173 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


