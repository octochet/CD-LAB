%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
char input_string[100];
int input_index = 0;
%}

%%
"("                     { input_string[input_index++] = yytext[0]; return LEFT_PAREN; }
")"                     { input_string[input_index++] = yytext[0]; return RIGHT_PAREN; }
";"                     { input_string[input_index++] = yytext[0]; printf("%-50s",input_string);
                            //empty the input string
                            for (int i = 0; i < input_index; i++) {
                                input_string[i] = '\0';
                            }
                            //reset the input index
                            input_index = 0;
                            return SEMICOLON; }
"="                     { input_string[input_index++] = yytext[0]; return ASSIGN; }
"+"                     { input_string[input_index++] = yytext[0]; return PLUS; }
"-"                     { input_string[input_index++] = yytext[0]; return MINUS; }
"*"                     { input_string[input_index++] = yytext[0]; return MUL; }
"/"                     { input_string[input_index++] = yytext[0]; return DIV; }
"++"                    { input_string[input_index++] = yytext[0];input_string[input_index++] = yytext[1]; return INC; }
"--"                    { input_string[input_index++] = yytext[0];input_string[input_index++] = yytext[1]; return DEC; }
[0-9]+                  { //add the number to the input string
                            for (int i = 0; i < strlen(yytext); i++) {
                                input_string[input_index++] = yytext[i];
                            }
                            ; return INT_CONST; }
[0-9]*\.[0-9]+          { for (int i = 0; i < strlen(yytext); i++) {
                                input_string[input_index++] = yytext[i];
                            }
                            ; return FLOAT_CONST; }
[a-zA-Z_][a-zA-Z0-9_]*  { for (int i = 0; i < strlen(yytext); i++) {
                                input_string[input_index++] = yytext[i];
                            }
                            ; return IDENTIFIER; }
[\t\n ]+                { /* ignore whitespace */ }
.                       { input_string[input_index++] = yytext[0]; }
<<EOF>>                 { printf("%-50s",input_string);return EoF;}
%%

int yyinput(char *buf, int max_size) {
    int i;
    for (i = 0; i < max_size && input_string[input_index] != '\0'; i++) {
        buf[i] = input_string[input_index++];
    }
    return i;
}