#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define MAX_SCOPES 1000
#define MAX_VARIABLES_IN_A_SCOPE 1000
#define MAX_DIMENSION 100

struct VariableNode
{
    char name[100];
    char type[100];
    char value[100];
    char addressLabel[100];
    int noOfDimensions;
    int offset;
    int totalSize;
    int dimensions[MAX_DIMENSION];
    char codeAtInitialization[1000];
};

struct TypeNode
{
    char *name;
    int noOfVariables;
    struct VariableNode **variables;
}; // TODO handle struct types for future

struct EnvironmentScope
{
    int noOfVariables; // kind of like stack pointer
    struct VariableNode *variables[MAX_VARIABLES_IN_A_SCOPE];
};

struct Environment
{
    int levelOfCurrentScope; // level of current scope
    struct EnvironmentScope scopes[MAX_SCOPES];
};

// global env and pointer to current scope
struct Environment *env;
struct VariableNode TotalVariablesSpace[MAX_VARIABLES_IN_A_SCOPE * MAX_SCOPES];
int spaceptr = 0;


void enterScope()
{
    env->levelOfCurrentScope++;
    env->scopes[env->levelOfCurrentScope].noOfVariables = 0;
    for (int i = 0; i < MAX_VARIABLES_IN_A_SCOPE; i++)
    {
        env->scopes[env->levelOfCurrentScope].variables[i] = NULL;
    }
}
void exitScope()
{
    env->scopes[env->levelOfCurrentScope].noOfVariables = 0;
    for (int i = 0; i < MAX_VARIABLES_IN_A_SCOPE; i++)
    {
        env->scopes[env->levelOfCurrentScope].variables[i] = NULL;
    }
    env->levelOfCurrentScope--;
}
void addVariableToCurrentScope(struct VariableNode *variable)
{
    env->scopes[env->levelOfCurrentScope].variables[env->scopes[env->levelOfCurrentScope].noOfVariables] = variable;
    env->scopes[env->levelOfCurrentScope].noOfVariables++;
    TotalVariablesSpace[spaceptr++] = *variable;
    int noOfElements = 1;
    for (int i = 0; i < variable->noOfDimensions; i++)
    {
        noOfElements *= variable->dimensions[i];
    }

    variable->totalSize = getWidth(variable->type) * noOfElements;
    TotalVariablesSpace[spaceptr - 1].totalSize = variable->totalSize;
    variable->offset = 0;
    if (spaceptr > 1)
    {
        variable->offset = TotalVariablesSpace[spaceptr - 2].offset +
                           TotalVariablesSpace[spaceptr - 2].totalSize;
        TotalVariablesSpace[spaceptr - 1].offset = variable->offset; // to notice that copy is saved in space and not pointer
    }
}

void deleteVariableFromCurrentScope(char *name)
{
    for (int i = 0; i < env->scopes[env->levelOfCurrentScope].noOfVariables; i++)
    {
        if (strcmp(env->scopes[env->levelOfCurrentScope].variables[i]->name, name) == 0)
        {
            env->scopes[env->levelOfCurrentScope].variables[i] = NULL;
            break;
        }
    }
}

struct VariableNode *getNodeDetailsUsingAddressLabel(char *addressLabel)
{
    for (int i = env->levelOfCurrentScope; i >= 0; i--)
    {
        for (int j = 0; j < env->scopes[i].noOfVariables; j++)
        {
            if (strcmp(env->scopes[i].variables[j]->addressLabel, addressLabel) == 0)
            {
                // return env->scopes[i].variables[j]->addressLabel;
                return env->scopes[i].variables[j];
            }
        }
    }
    return NULL;
}

struct VariableNode *getNodeDetails(char *name)
{
    for (int i = env->levelOfCurrentScope; i >= 0; i--)
    {
        for (int j = 0; j < env->scopes[i].noOfVariables; j++)
        {
            if (strcmp(env->scopes[i].variables[j]->name, name) == 0)
            {
                return env->scopes[i].variables[j];
            }
        }
    }
    return NULL;
}

bool checkInCurrentScope(char *name)
{
    for (int i = 0; i < env->scopes[env->levelOfCurrentScope].noOfVariables; i++)
    {
        if (strcmp(env->scopes[env->levelOfCurrentScope].variables[i]->name, name) == 0)
        {
            return true;
        }
    }
    return false;
}
bool checkInAllScope(char *name)
{
    for (int i = env->levelOfCurrentScope; i >= 0; i--)
    {
        for (int j = 0; j < env->scopes[i].noOfVariables; j++)
        {
            if (strcmp(env->scopes[i].variables[j]->name, name) == 0)
            {
                return true;
            }
        }
    }
    return false;
}

int getWidth(char *type)
{
    if (strcmp(type, "int") == 0)
        return 4;
    else if (strcmp(type, "float") == 0)
        return 8;
    else if (strcmp(type, "char") == 0)
        return 1;
    else if (strcmp(type, "double") == 0)
        return 8;
    else if (strcmp(type, "long") == 0)
        return 8;
    else if (strcmp(type, "short") == 0)
        return 2;
    return 0;
}

void PrintSymbolTable()
{
    // loop over space print all in a table fashion
    int offset = 0;
    printf("Name\tType\tAddress\tDimensions\tOffset\n");
    for (int i = 0; i < spaceptr; i++)
    {
        int noOfElements = 1;
        printf("%s\t%s\t%s\t", TotalVariablesSpace[i].name, TotalVariablesSpace[i].type, TotalVariablesSpace[i].addressLabel);
        for (int j = 0; j < TotalVariablesSpace[i].noOfDimensions; j++)
        {
            printf("%d ", TotalVariablesSpace[i].dimensions[j]);
            noOfElements *= TotalVariablesSpace[i].dimensions[j];
        }
        if (TotalVariablesSpace[i].noOfDimensions == 0)
        {
            printf("1");
        }
        // print offset
        printf("\t\t%d", TotalVariablesSpace[i].offset);
        printf("\n");
    }
}