%option noyywrap
%{
#include <stdio.h>
#include "y.tab.h" // Include the y.tab.h header

%}

MONTH Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec

%%

[0-3]?[0-9]      { yylval.day = atoi(yytext);printf("%s",yytext); return DAY; }
{MONTH}          { yylval.str = strdup(yytext);printf("%s",yytext); return MONTH; }
[0-9]{4}         { yylval.year = atoi(yytext);printf("%s",yytext); return YEAR; }
";"              { printf("%s",yytext); return SCOL; }
"-"              { printf("%s",yytext); return DASH; }
[ \n\t]          { /* Ignore spaces */ }

%%
