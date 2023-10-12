%option noyywrap
%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "y.tab.h"
%}

NUM [0-9]+
COMP "=="|"!="|">"|"<"|">="|"<="
IF "if"
ELSE "else"
WHILE "while"
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
COMMENT1 "//"(.)*\n
COMMENT2 "/*"(.)*"*/"

%%
{NUM}|{NUM}"."{NUM}         {ECHO; strcpy(yylval.val,yytext); return NUMBER;}
{IF}                        {ECHO; return IF;}
{ELSE}                      {ECHO; return ELSE;}
{WHILE}                     {ECHO; return WHILE;}
"{"                         {ECHO; return LBRACE;}
"}"                         {ECHO; return RBRACE;}
{COMP}                      {ECHO; strcpy(yylval.val,yytext); return COMPARISON;}
"&&"                        {ECHO; return LOGICAL_AND;}
"||"                        {ECHO; return LOGICAL_OR;}
"!"                         {ECHO; return LOGICAL_NOT;}
"+"                         {ECHO; return PLUS;}
"-"                         {ECHO; return MINUS;}
"++"                        {ECHO; return INCREMENT;}
"--"                        {ECHO; return DECREMENT;}
"="                         {ECHO; return ASSIGN;}
"*"                         {ECHO; return MULTIPLY;}
"/"                         {ECHO; return DIVIDE;}
"("                         {ECHO; return LPAREN;}
")"                         {ECHO; return RPAREN;}
{IDENTIFIER}                {ECHO; strcpy(yylval.val,yytext);  return ID;}
[ \t]                       {ECHO;}
";"                         {ECHO; return SEPERATOR;}
[\n]+                       {ECHO;
                            //return EOL;
                            }
{COMMENT1}|{COMMENT2}       {ECHO; }
<<EOF>>                     {return EOFf;}
.                           {;}
%%