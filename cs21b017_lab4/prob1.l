%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}

digit [0-9]

%%
[ \t\n]    { /* Ignore whitespace and newline */ }
{digit}+   {printf("%s",yytext);return NUMBER;}
"+"        {printf("%s",yytext);return PLUS;}
"-"        {printf("%s",yytext);return MINUS;}
"i"        {printf("%s",yytext);return IOTA;}
";"        {printf("%s",yytext);return SCOL;}
[^i0-9+-;]+ {printf("%s",yytext);return ERROR;}
%%
