#include <stdio.h>
#include "y.tab.h"

static int lbl;
static int breakLabel;
static int continueLabel;
static bool insideLoop;
static bool insideSwitch;
static FILE* fp;

int ex(nodeType *p) {
    int lbl1, lbl2;
    if(!boolFile) {
        boolFile = true;
        fp = fopen ("quadruples.txt","a");
    }

    if (!p) return 0;
    switch(p->type) {
    case typeCon:
        if(p->con.dataType == INTEGER) fprintf(fp, "\tpush\t%d\n", p->con.integerValue);
        if(p->con.dataType == FLOAT) fprintf(fp, "\tpush\t%f\n", p->con.floatValue);
        if(p->con.dataType == STRING) fprintf(fp, "\tpush\t%s\n", p->con.stringValue);
        if(p->con.dataType == BOOL) fprintf(fp, "\tpush\t%s\n", p->con.boolValue ? "true" : "false");
        break;
    case typeId:        
        fprintf(fp, "\tpush\t%s\n", p->id.variableName); 
        break;
    case typeMth:
        switch (p->mth.type){
        case typeD:
            fprintf(fp, "%s:\n", p->mth.methodName);
            for(int i=p->mth.nops-1 ; i>=0 ; i--){
                fprintf(fp, "\tpop\t%s\n", p->mth.op[i]->id.variableName);
            }
            ex(p->mth.op[p->mth.nops]);
            for(int i=p->mth.nops-1 ; i>=0 ; i--){
                fprintf(fp, "\tpush\t%s\n", p->mth.op[i]->id.variableName);
            }
            fprintf(fp, "ret\n");
            break;
        case typeC:
            for(int i=0 ; i<p->mth.nops ; i++){
                ex(p->mth.op[i]);
            }
            fprintf(fp, "call\t%s\n", p->mth.methodName);
            for(int i=0 ; i<p->mth.nops ; i++){
                if(p->mth.op[i]->type == typeId)
                    fprintf(fp, "\tpop\t%s\n", p->mth.op[i]->id.variableName);
                else
                    fprintf(fp, "\tpop\n");
            }
            break;
        }
        break;
    case typeOpr:
        switch(p->opr.oper) {
        case WHILE:
            insideLoop = true;
            fprintf(fp, "L%03d:\n", lbl1 = lbl++);
            continueLabel = lbl1;
            ex(p->opr.op[0]);
            fprintf(fp, "\tjnz\tL%03d\n", lbl2 = lbl++);
            breakLabel = lbl2;
            ex(p->opr.op[1]);
            fprintf(fp, "\tjmp\tL%03d\n", lbl1);
            fprintf(fp, "L%03d:\n", lbl2);
            insideLoop = false;
            break;
        case REPEAT:
            insideLoop = true;
            fprintf(fp, "L%03d:\n", lbl1 = lbl++);
            continueLabel = lbl++;
            breakLabel = lbl++;
            ex(p->opr.op[0]);
            fprintf(fp, "L%03d:\n", continueLabel);
            ex(p->opr.op[1]);
            fprintf(fp, "\tjnz\tL%03d\n", lbl1);
            fprintf(fp, "L%03d:\n", breakLabel);
            insideLoop = false;
            break;
        case SWITCH:
            insideSwitch = true;
            breakLabel = lbl++;
            ex(p->opr.op[0]);
            ex(p->opr.op[1]);
            fprintf(fp, "L%03d:\n", breakLabel);
            fprintf(fp, "\tpop\n");
            insideSwitch = false;
            break;
        case CASE:
            ex(p->opr.op[0]);
            fprintf(fp, "\tcompEQ\n");
            fprintf(fp, "\tjnz\tL%03d\n", lbl1 = lbl++);
            ex(p->opr.op[1]);
            fprintf(fp, "\tpop\t\n");
            fprintf(fp, "\tjmp\tL%03d\n", breakLabel);
            fprintf(fp, "L%03d:\n", lbl1);
            fprintf(fp, "\tpop\t\n");
            if(p->opr.nops == 3) ex(p->opr.op[2]);
            break;
        case FOR:
            insideLoop = true;
            ex(p->opr.op[0]);
            fprintf(fp, "L%03d:\n", lbl1 = lbl++);
            continueLabel = lbl++;
            ex(p->opr.op[1]);
            fprintf(fp, "\tjz\tL%03d\n", breakLabel = lbl++);
            ex(p->opr.op[3]);
            fprintf(fp, "L%03d:\n", continueLabel);
            ex(p->opr.op[2]);
            fprintf(fp, "\tjmp\tL%03d\n", lbl1);
            fprintf(fp, "L%03d:\n", breakLabel);
            insideLoop = false;
            break;
        case IF:
            ex(p->opr.op[0]);
            if (p->opr.nops > 2) {
                /* if else */
                fprintf(fp, "\tjnz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                fprintf(fp, "\tjmp\tL%03d\n", lbl2 = lbl++);
                fprintf(fp, "L%03d:\n", lbl1);
                ex(p->opr.op[2]);
                fprintf(fp, "L%03d:\n", lbl2);
            } else {
                /* if */
                fprintf(fp, "\tjnz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                fprintf(fp, "L%03d:\n", lbl1);
            }
            break;
        case PRINT:     
            ex(p->opr.op[0]);
            fprintf(fp, "\tprint\n");
            break;
        case CONTINUE:
            if(insideLoop) {
                fprintf(fp, "\tjmp\tL%03d\n", continueLabel);
            }
            else {
                yyerror("Invalid usage of continue");
            }
            break;
            
        case BREAK:
            if(insideLoop || insideSwitch) {
                fprintf(fp, "\tjmp\tL%03d\n", breakLabel);
            }
            else {
                yyerror("Invalid usage of break");
            }
            break;
        case ASSIG:       
            ex(p->opr.op[1]);
            fprintf(fp, "\tpop\t%s\n", p->opr.op[0]->id.variableName);
            break;
        case UMINUS:    
            ex(p->opr.op[0]);
            fprintf(fp, "\tneg\n");
            break;
        default:
            ex(p->opr.op[0]);
            ex(p->opr.op[1]);
            switch(p->opr.oper) {
            case PLUS:   fprintf(fp, "\tadd\n"); break;
            case MINUS:   fprintf(fp, "\tsub\n"); break; 
            case MULT:   fprintf(fp, "\tmul\n"); break;
            case DIV:   fprintf(fp, "\tdiv\n"); break;
            case AND:    fprintf(fp, "\tcompAND\n"); break;
            case OR:    fprintf(fp, "\tcompOR\n"); break;
            case LT:   fprintf(fp, "\tcompLT\n"); break;
            case GT:   fprintf(fp, "\tcompGT\n"); break;
            case GE:    fprintf(fp, "\tcompGE\n"); break;
            case LE:    fprintf(fp, "\tcompLE\n"); break;
            case NE:    fprintf(fp, "\tcompNE\n"); break;
            case EQ:    fprintf(fp, "\tcompEQ\n"); break;
            }
        }
    }
    if(boolFile == false) fclose(fp);
    return 0;
}
