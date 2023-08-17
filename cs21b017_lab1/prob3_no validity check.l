%option noyywrap
%{
#include <stdio.h>
%}

%option noyywrap

HOST [a-zA-Z0-9.-]+
QUERY [a-zA-Z0-9.-=]+
PASS [a-zA-Z0-9._%+-]+
USERNAME [a-zA-Z0-9._-]+
%%

mailto:       {printf("%s      SCHEME\n",yytext);}
http(s)?:\/\/ {printf("%s      SCHEME\n",yytext);}
ftp:\/\/      {printf("%s      SCHEME\n",yytext);}
file:\/\/\/   {printf("%s      SCHEME\n",yytext);}


{USERNAME}(:|@)  {printf("%s      USERNAME\n",yytext);}
:{PASS}@      {printf("%s      PASSWORD\n",yytext);}
({HOST}\.)+{HOST}  {printf("%s      HOST\n",yytext);}
:[0-9]+  {printf("%s      PORT\n",yytext);}

(\/[a-zA-Z0-9_]+)*(\.[a-z]+|\/)?  {printf("%s      PATH\n",yytext);}

\?{QUERY}({QUERY}\&)*{QUERY}  {printf("%s      QUERY\n",yytext);}

\#[a-zA-Z]*  {printf("%s      FRAGMENT\n",yytext);} 

%%

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        printf("Error opening file\n");
        return 1;
    }

    yyin = fp;
    yylex();

    fclose(fp);
    return 0;
}
