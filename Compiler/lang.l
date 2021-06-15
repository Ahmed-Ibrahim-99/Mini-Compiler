%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
void yyerror(char *);
%}

%%

"#".*                       { /* SINGLE LINE COMMENT */ }

"+"             {return PLUS;}
"-"             {return MINUS;}
"/"             {return DIV;}
"*"             {return MULT;}
">"             {return GT;}
"<"             {return LT;}
">="            {return GE;}
"<="            {return LE;}
"=="            {return EQ;}
"!="            {return NE;}
"&&"            {return AND;}
"||"            {return OR;}
"="             {return ASSIG;}

"const"         {return CONST;}

"for"           {return FOR;}
"while"         {return WHILE;}

"if"            {return IF;}
"else"          {return ELSE;}
"switch"        {return SWITCH;}
"case"          {return CASE;}
"repeat"        {return REPEAT;}
"until"         {return UNTIL;}
"break"         {return BREAK;}
"continue"      {return CONTINUE;}

"print"         {return PRINT;}
"false"         {
                    yylval.bValue = false;
                    return BOOL;
                }
"true"          {
                    yylval.bValue = true;
                    return BOOL;
                }
"def"           {
                            return METHOD_DEF;
                }


[a-zA-Z][a-zA-Z0-9]*  {
                            strcpy(yylval.sValue, yytext);
                            return VARIABLE;
                      }

[0-9]+[a-zA-Z]+[a-zA-Z0-9]*    {
                            return WRONG_VARIABLE;
                      }

@[a-zA-Z][a-zA-Z0-9]*   {
                            strcpy(yylval.sValue, yytext);
                            return METHOD_VARIABLE;
                        }

[0-9]+              {
                        yylval.iValue = atoi(yytext);
                        return INTEGER;
                    }

[0-9]+[.][0-9]+     {
                        yylval.fValue = atof(yytext);
                        return FLOAT;
                    }

[\"][^"]*[\"]           {
                        strcpy(yylval.sValue, yytext);
                        return STRING;
                    }


[$][a-zA-Z][a-zA-Z0-9]* {
                        strcpy(yylval.sValue, yytext);
                        return METHOD;
                    }

[()/;:{}.,]         {
                        return *yytext;
                    }

[ \t\n]+            ;       /* ignore whitespace */

.                   {
                        yyerror("Unknown character");
                    }
%%

int yywrap(void) {
    return 1;
}
