%option noyywrap
%{
#include <stdio.h>
#include <string.h>

int E();
int Edash();
int T();
int Tdash();
int F();

const char *cursor;
char string[64];
%}

TERMINALS [i+*]

%%

{TERMINALS}*        {strcpy(string, yytext); cursor = string; if (E() && *cursor == '\0') printf("String is successfully parsed\n"); else printf("Error in parsing String\n");}

.                { fprintf(stderr, "Invalid character: %c\n", yytext[0]);}

\n               { /*PRINT THE RESULT*/ }
"exit"           { return 0; }



%%

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file)
    {
        perror("Error opening file");
        return 1;
    }

    yyin = input_file;
    yyrestart(yyin);

    yylex();

    fclose(input_file);
    return 0;
}

int E()
{
    printf("%-16s E -> TE'\n", cursor);
    if (T())
    {
        if (Edash())
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

int Edash()
{
    if (*cursor == '+')
    {
        printf("%-16s E' -> + T E'\n", cursor);
        cursor++;
        if (T())
        {
            if (Edash())
                return 1;
            else
                return 0;
        }
        else
            return 0;
    }
    else
    {
        printf("%-16s E' -> $\n", cursor);
        return 1;
    }
}

int T()
{
    printf("%-16s T -> F T'\n", cursor);
    if (F())
    {
        if (Tdash())
            return 1;
        else
            return 0;
    }
    else
        return 0;
}

int Tdash()
{
    if (*cursor == '*')
    {
        printf("%-16s T' -> * F T'\n", cursor);
        cursor++;
        if (F())
        {
            if (Tdash())
                return 1;
            else
                return 0;
        }
        else
            return 0;
    }
    else
    {
        printf("%-16s T' -> $\n", cursor);
        return 1;
    }
}

int F()
{
    if (*cursor == 'i')
    {
        printf("%-16s F -> i\n", cursor);
        cursor++;
        return 1;
    }
    else
    {
        return 0;
    }
}