%option noyywrap

%{
#include "parser.tab.h"
%}

%%
"+"     { return PLUS; }
"\*"    { return TIMES; }
"i"     { return i; }
\n      { /* skip newline characters */ }
[ \t]   { /* skip whitespace */ }
.       { /* handle unknown characters */ }
%%

int main() {
    yylex();
    return 0;
}
