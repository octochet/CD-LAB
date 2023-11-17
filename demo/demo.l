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
COMMENT1 \/\/[^\n]*
COMMENT2 \/\*([^\*]|\*[^\/])*\*\/
STRING_LITERAL \"(\\.|[^\\"])*\"|\'(\\.|[^\\'])*\'
%%
"break"                     {ECHO; return BREAK;}
"continue"                  {ECHO; return CONTINUE;}
"default"                   {ECHO; return DEFAULT;}
"case"                      {ECHO; return CASE;}
"switch"                    {ECHO; return SWITCH;}
":"                         {ECHO; return COLON;}
","                         {ECHO; return COMMA;}
'.'                         {ECHO;
                            //take 2nd character of yytext number it and send it as a string
                            char*texttemp=yytext;
                            int toint=(int)texttemp[1];
                            char*tostring=(char*)malloc(sizeof(char)*20);
                            sprintf(tostring,"%d",toint);
                            strcpy(yylval.val,tostring);
                            return NUMBER;
                            }
"int"                       {ECHO;strcpy(yylval.val,yytext);
                             return INT;}
"long"                      {ECHO;strcpy(yylval.val,yytext); return LONG;}
"char"                      {ECHO;strcpy(yylval.val,yytext); return CHAR;}
"float"                     {ECHO;strcpy(yylval.val,yytext); return FLOAT;}
"double"                    {ECHO;strcpy(yylval.val,yytext); return DOUBLE;}
"]"                         {ECHO; return RSQUAREBR;}
"["                         {ECHO; return LSQUAREBR;}


{STRING_LITERAL}            {ECHO; strcpy(yylval.val,yytext); return STRING;}

({NUM}"."{NUM})("f"|"d")?  {ECHO; strcpy(yylval.val,yytext); return NUMBER;}
({NUM})                     {ECHO; strcpy(yylval.val,yytext); return INT_NUM;}
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