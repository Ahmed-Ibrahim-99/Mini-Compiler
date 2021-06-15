#include <stdbool.h>
#define SYM_LIMIT 100
#define METHOD_OPERANDS_LIMIT 10
typedef enum { typeCon, typeId, typeOpr, typeMth } nodeEnum;
typedef enum { typeD, typeC} nodeMethodType;
// typedef enum { typeMissMatch } nodeDataType;

/* constants */
typedef struct {
    int dataType;
    union {
        int integerValue;
        float floatValue;
        char stringValue[100];
        bool boolValue;
    };
} conNodeType;

typedef struct {                     
    char variableName[100];
    int dataType;
    bool isConst;
} idNodeType;

/* operators */
typedef struct {
    int dataType;
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

/* method operands */
typedef struct {
    nodeMethodType type;
    char methodName[100];       /* method name */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} methodNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
        methodNodeType mth;     /* methods */
    };
} nodeType;

extern nodeType *symbolTable[SYM_LIMIT];
extern nodeType *methodsSymbolTable[SYM_LIMIT];
