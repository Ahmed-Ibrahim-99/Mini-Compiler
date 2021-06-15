%code requires {
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

}
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>
#include <math.h>
#define YYERROR_VERBOSE

int yylex(void);
int variablesCount = 0;
int methodsCount = 0;
int operandsCount = 0;

%}

%union {
    int iValue;                 /* integer value */
    char sValue[100];                /* string Value */
    bool bValue;                
    float fValue;
    nodeType *nPtr;             /* node pointer */
};

%token<iValue> INTEGER 
%token<iValue> typeMissMatch 
%token<fValue>FLOAT 
%token<sValue>STRING 
%token<bValue>BOOL 
%token<sValue>VARIABLE 
%token<sValue>METHOD METHOD_VARIABLE
%token WHILE IF PRINT CONST METHOD_DEF FOR SWITCH CASE REPEAT UNTIL BREAK CONTINUE GE LE EQ NE GT LT AND OR MINUS PLUS MULT DIV ASSIG WRONG_VARIABLE
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE GT LT AND OR
%left PLUS MINUS
%left MULT DIV
%left ','
%nonassoc ASSIG
%nonassoc UMINUS
%nonassoc ':'
%nonassoc ';'
%nonassoc '('
%nonassoc '{'

%type<nPtr> val expr assignStmt logicExpr stmt stmtList caseStmt
%%

program:
        function                {boolFile=false; exit(0);}  
        ;

function:
          function stmt         {ex($2);}
        |
        ;

stmt:
          ';'                                                                   {$$ = opr(';', 2, NULL, NULL);}
        | PRINT expr ';'                                                        {$$ = opr(PRINT, 1, $2);}                                           
        | BREAK ';'                                                             {$$ = opr(BREAK, 0);} 
        | CONTINUE ';'                                                          {$$ = opr(CONTINUE, 0);} 
        | SWITCH '(' val ')' '{' caseStmt '}'                                   {$$ = opr(SWITCH, 2, $3, $6);} 
        | assignStmt ';'                                                        {$$ = $1;}
        | REPEAT '{' stmtList '}' UNTIL '(' logicExpr ')' ';'                   {$$ = opr(REPEAT, 2, $3, $7);}
        | WHILE '(' logicExpr ')' '{' stmtList '}'                              {$$ = opr(WHILE, 2, $3, $6);} 
        | METHOD '(' passedOperand ')' ';'                                      {$$ = callMethod($1);}
        | METHOD_DEF METHOD '(' methodOperand ')' '{' stmtList '}'              {$$ = defineMethod($2, $7);}
        | FOR '(' assignStmt ';' logicExpr ';' assignStmt ')' '{' stmtList '}'  {$$ = opr(FOR, 4, $3, $5, $7, $10);}
        | IF '(' logicExpr ')' '{' stmtList '}' %prec IFX                       {$$ = opr(IF, 2, $3, $6);}                
        | IF '(' logicExpr ')' '{' stmtList '}' ELSE '{' stmtList '}'           {$$ = opr(IF, 3, $3, $6, $10); }
        | '{' stmtList '}'                                                      {$$ = $2;}
        | wrongAssigStmt                                                        {}
        ;

wrongAssigStmt:        
          WRONG_VARIABLE ASSIG expr                                             {yyerror("wrong variable name");}
        | CONST WRONG_VARIABLE ASSIG expr                                       {yyerror("wrong variable name");}
        ;

assignStmt:
          VARIABLE ASSIG expr                                                   {$$ = setAndDeclare($1, $3, false);}
        | METHOD_VARIABLE ASSIG expr                                            {$$ = setAndDeclare($1, $3, false);}
        | CONST VARIABLE ASSIG expr                                             {$$ = setAndDeclare($2, $4, true);}
        ;


caseStmt:
           CASE val ':' stmtList BREAK ';'                                      {$$ = opr(CASE, 2, $2, $4); }
        |  CASE val ':' stmtList BREAK ';' caseStmt                             {$$ = opr(CASE, 3, $2, $4, $7); }
        ;

stmtList:
          stmt                  {$$ = $1;} 
        | stmtList stmt         {$$ = opr(';', 2, $1, $2); } 
        ; 

expr:
          MINUS expr %prec UMINUS       {$$ = opr(UMINUS, 1, $2);}
        | val                           {$$ = $1;}           
        | expr MULT expr                {$$ = opr(MULT, 2, $1, $3);}
        | expr DIV expr                 {$$ = opr(DIV, 2, $1, $3);}
        | expr PLUS expr                {$$ = opr(PLUS, 2, $1, $3);}
        | expr MINUS expr               {$$ = opr(MINUS, 2, $1, $3);}
        | '(' expr ')'                  {$$ = $2;}
        ;

logicExpr: 
          logicExpr GT logicExpr           {$$ = opr(GT, 2, $1, $3);} 
        | logicExpr LT logicExpr           {$$ = opr(LT, 2, $1, $3);} 
        | logicExpr GE logicExpr           {$$ = opr(GE, 2, $1, $3);} 
        | logicExpr NE logicExpr           {$$ = opr(NE, 2, $1, $3);} 
        | logicExpr LE logicExpr           {$$ = opr(LE, 2, $1, $3);} 
        | logicExpr EQ logicExpr           {$$ = opr(EQ, 2, $1, $3);} 
        | logicExpr AND logicExpr          {$$ = opr(AND, 2, $1, $3);} 
        | logicExpr OR logicExpr           {$$ = opr(OR, 2, $1, $3);} 
        | val                              {$$ = $1;} 
        ;

val:
          BOOL         {$$ = conBool($1);}    
        | STRING       {$$ = conStr($1);}     
        | INTEGER      {$$ = conInt($1);}     
        | FLOAT        {$$ = conFloat($1);}     
        | VARIABLE     {$$ = id($1);}
        | METHOD_VARIABLE     {$$ = id($1);}
        ;

passedOperand:
          val                                          {passOperand($1);} 
        | passedOperand ',' passedOperand            
        |
        ; 

methodOperand:
          METHOD_VARIABLE                              {addOperand($1);}
        | methodOperand ',' methodOperand            
        |
        ; 

%%


int getDataType(nodeType *node) {
    int dataType;
    if (node->type == typeCon) {
        dataType = node->con.dataType;
    }
    else if (node->type == typeId) {
        dataType = node->id.dataType;
    }
    else if (node->type == typeOpr) {
        dataType = node->opr.dataType;
    }
    return dataType;
}

int isVariableDeclared(char *variableName) {

     for(int i = 0 ; i < variablesCount; i++) {
        if(strcmp(symbolTable[i]->id.variableName, variableName) == 0) {
            return i;
        }
    }
    return -1;
}

int isMethodDeclared(char *methodName) {

     for(int i = 0 ; i < methodsCount; i++) {
        if(strcmp(methodsSymbolTable[i]->mth.methodName, methodName) == 0) {
            return i;
        }
    }
    return -1;
}

void addOperand(char *variableName){
    nodeType *p;
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeId;
    strcpy(p->id.variableName, variableName);

    if(operandsCount >= METHOD_OPERANDS_LIMIT){
        yyerror("Number of operands exceeded the limit");
        return;
    }

    methodOperands[operandsCount] = p;
    operandsCount++;
}

void passOperand(nodeType *p){
    
    if(operandsCount >= METHOD_OPERANDS_LIMIT){
        yyerror("Number of operands exceeded the limit");
        return;
    }

    methodOperands[operandsCount] = p;
    operandsCount++;
}

nodeType *defineMethod( char *methodName, nodeType* statements){
    int methodIndex = isMethodDeclared(methodName);
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (operandsCount) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");
    
    if (methodIndex == -1) {
        if(methodsCount >= SYM_LIMIT){
            yyerror("Stack Overflow");
        }
        methodIndex = methodsCount;
        if ((methodsSymbolTable[methodIndex] = malloc(sizeof(nodeType))) == NULL)
            yyerror("out of memory");

        /* copy information */
        methodsSymbolTable[methodIndex]->type = typeMth;
        methodsSymbolTable[methodIndex]->mth.nops = operandsCount;
        strcpy(methodsSymbolTable[methodIndex]->mth.methodName, methodName);
        printSymTable(1);
        p->type = typeMth;
        p->mth.type = typeD;
        p->mth.nops = operandsCount;
        strcpy(p->mth.methodName, methodName);

        for (i = 0; i < operandsCount; i++) {
            p->mth.op[i] = methodOperands[i];
        }
        p->mth.op[operandsCount] = statements;

        methodsCount++;
    }
    else{
        yyerror("Method already defined");
    }
    operandsCount = 0;
    return p;
}

nodeType *callMethod(char *methodName){
    int methodIndex = isMethodDeclared(methodName);
    if(methodIndex == -1)
        yyerror("Method undefined");
    else if (methodsSymbolTable[methodIndex]->mth.nops != operandsCount){
        yyerror("Number of operands do not match with defined method");
    }

    nodeType *p;
    if ((p = malloc(sizeof(nodeType) + (operandsCount-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    p->type = typeMth;
    p->mth.type = typeC;
    p->mth.nops = operandsCount;
    strcpy(p->mth.methodName, methodName);

    for (int i = 0; i < operandsCount; i++) {
        p->mth.op[i] = methodOperands[i];
    }
    operandsCount = 0;
    return p;
}

nodeType *setAndDeclare(char *variableName, nodeType* rhs, bool isConst) {
    int variableIndex = isVariableDeclared(variableName);
    int dataType = getDataType(rhs);
    // printf("rhs datatype %d\n", dataType);
    if (variableIndex == -1) {
        if(variablesCount >= SYM_LIMIT){
            yyerror("Stack Overflow");
        }
        variableIndex = variablesCount;
        if ((symbolTable[variableIndex] = malloc(sizeof(nodeType))) == NULL)
            yyerror("out of memory");

        symbolTable[variableIndex]->type = typeId;
        symbolTable[variableIndex]->id.dataType = dataType;
        symbolTable[variableIndex]->id.isConst = isConst;
        strcpy(symbolTable[variableIndex]->id.variableName, variableName);
        printSymTable(0);
        // printf("declaring variable %s of datatype %d\n", variableName, symbolTable[variableIndex]->id.dataType);
        variablesCount++;
    }
    else {
        // printf("Setting variable %s of datatype %d\n", variableName, symbolTable[variableIndex]->id.dataType);
        if(symbolTable[variableIndex]->id.isConst){
            yyerror("Can not change a constant value");
        }
        else if(symbolTable[variableIndex]->id.dataType != dataType) {
            yyerror("Type Mismatch");
        }
    }
    return opr(ASSIG, 2, symbolTable[variableIndex], rhs);
}


nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;

    va_start(ap, nops);
    for (i = 0; i < nops; i++) {
        p->opr.op[i] = va_arg(ap, nodeType*);
    }
    va_end(ap);
    
    if(oper == MULT || oper == PLUS || oper == DIV || oper == MINUS || oper == UMINUS)
    {
        // printf("here*******\n");
        int dataType = getDataType(p->opr.op[0]);
        for(int i=1; i<nops; i++) {
            if(!(p->opr.op[i]->type == typeId && p->opr.op[i]->id.variableName[0] == '@')) {
                if(dataType != getDataType(p->opr.op[i])) {
                    // printf("operand %d of type %d\n", i, getDataType(p->opr.op[i]));
                    yyerror("Type Mismatch");
                    p->opr.dataType = typeMissMatch;
                }
            }
        }
        if(p->opr.dataType != typeMissMatch) {
            p->opr.dataType = dataType;
        }
        return p;
    }
    else if(oper == GT || oper == LT || oper == GE || oper == NE || oper == LE || oper == EQ || oper == AND || oper == OR){
        int dataType = getDataType(p->opr.op[0]);
        for(int i=1; i<nops; i++) {
            if(dataType != getDataType(p->opr.op[i])) {
                yyerror("Type Missmatch");
                p->opr.dataType = typeMissMatch;
            }
        }
        if(p->opr.dataType != typeMissMatch) {
            p->opr.dataType = dataType;
        }
    }
    return p;
}

nodeType *id(char *s) {
    nodeType *p;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeId;
    strcpy(p->id.variableName, s);
    
    int variableIndex = isVariableDeclared(s);
    if( variableIndex == -1) {
        if(s[0] != '@')
            yyerror("Using undeclared variable");
    }
    else {
        p->id.dataType = symbolTable[variableIndex]->id.dataType;
    }

    return p;
}

nodeType *conInt(int value){
    nodeType *p;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeCon;
    p->con.dataType = INTEGER;
    p->con.integerValue = value;

    return p;
}
nodeType *conFloat(float value){
    nodeType *p;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeCon;
    p->con.dataType = FLOAT;
    p->con.floatValue = value;

    return p;
}
nodeType *conStr(char *value){
    nodeType *p;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeCon;
    p->con.dataType = STRING;
    strcpy(p->con.stringValue, value);

    return p;
}
nodeType *conBool(bool value){
    nodeType *p;

    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    p->type = typeCon;
    p->con.dataType = BOOL;
    p->con.boolValue = value;

    return p;
}

void yyerror(char *s) {
    FILE * fp;
    fp = fopen ("errors.txt","a");
    fprintf(fp, "%s\n", s);
    fclose(fp);
}

void printSymTable(int choice)
{
    FILE * fp;
    fp = fopen ("SymbolTable.txt","a");
    if(choice == 0)
    {
        fprintf(fp, "Variable Name: %s, Is Constant: %s\n", symbolTable[variablesCount]->id.variableName, (symbolTable[variablesCount]->id.isConst)?"true":"false");
    }
    else
    {
        fprintf(fp, "Method Name: %s, Number of Operands: %d\n", methodsSymbolTable[methodsCount]->mth.methodName, methodsSymbolTable[methodsCount]->mth.nops);
    }
    fclose(fp);
}

int main(void) {
    yyparse();
    return 0;
}