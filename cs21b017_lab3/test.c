#include <stdio.h>
#include <string.h>

#define SUCCESS 1
#define FAILED 0

int E(), Edash(), T(), Tdash(), F();

const char *cursor;
char string[64];

int main()
{
    while (1)
    {
        puts("Enter the string");
        scanf("%s", string);
        //sscanf("i+(i+i)*i", "%s", string);
        cursor = string;
        puts("");
        puts("Input      Action");
        puts("--------------------------------");

        if (E() && *cursor == '\0')
        {
            puts("--------------------------------");
            puts("String is successfully parsed");
            return 0;
        }
        else
        {
            puts("--------------------------------");
            puts("Error in parsing String");
            return 1;
        }
    }
}

// E -> TE'
int E()
{
    printf("%-16s E -> TE'\n", cursor);
    if (T())
    {
        if (Edash())
        {
            return SUCCESS;
        }
        else
        {
            return FAILED;
        }
    }
    else
    {
        return FAILED;
    }
}

// E' -> +TE' | $
int Edash()
{
    if (*cursor == '+')
    {
        printf("%-16s E' -> + T E'\n", cursor);
        cursor++;
        if (T())
        {
            if (Edash())
                return SUCCESS;
            else
                return FAILED;
        }
        else
            return FAILED;
    }
    else
    {
        printf("%-16s E' -> $\n", cursor);
        return SUCCESS;
    }
}

// T -> FT'
int T()
{
    printf("%-16s T -> F T'\n", cursor);
    if (F())
    {
        if (Tdash())
            return SUCCESS;
        else
            return FAILED;
    }
    else
        return FAILED;
}

// T' -> *FT' | $
int Tdash()
{
    if (*cursor == '*')
    {
        printf("%-16s T' -> * F T'\n", cursor);
        cursor++;
        if (F())
        {
            if (Tdash())
                return SUCCESS;
            else
                return FAILED;
        }
        else
            return FAILED;
    }
    else
    {
        printf("%-16s T' -> $\n", cursor);
        return SUCCESS;
    }
}

// F -> i
int F()
{
    if (*cursor == 'i')
    {
        printf("%-16s F -> i\n", cursor);
        cursor++;
        return SUCCESS;
    }
    else
    {
        return FAILED;
    }
}