%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void printFileURLTokens(char *url);
void printMailtoURLTokens(char *url);
void printhttpsURLTokens(char *url);
%}

%option noyywrap

USERNAME [a-zA-Z0-9_]+
PASSWORD [a-zA-Z0-9_]+
HOST [a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*
PORT [0-9]+
PATH (\/[a-zA-Z0-9_]+)*((\.[a-zA-Z0-9_]+)|\/)?
QUERY (\?[a-zA-Z0-9_]+=[a-zA-Z0-9_]+(&[a-zA-Z0-9_]+=[a-zA-Z0-9_]+)*)
FRAGMENT (\#[a-zA-Z0-9_]+)
%%

(http(s)?|ftp):\/\/({USERNAME}:{PASSWORD}@)?{HOST}(:{PORT})?({PATH})?({QUERY})?({FRAGMENT})? {printf("VALID HTTP(S)/FTP URL\n: %s",yytext); printhttpsURLTokens(yytext);}

file:\/\/{PATH} {printf("VALID FILE URL\n: %s",yytext); printFileURLTokens(yytext);}

mailto:{USERNAME}@{HOST} {printf("VALID MAILTO URL\n: %s",yytext); printMailtoURLTokens(yytext);}

.* {printf("INVALID URL\n: %s",yytext);}

\n {printf("\n");}

%%

void printFileURLTokens(char *url) {
    char *scheme, *path, *token;
    int i;
    int len = strlen(url);
    int scheme_end = -1;
    int path_start = -1;
    for (i = 0; i < len; i++) {
        if (url[i] == ':' && url[i+1] == '/' && url[i+2] == '/') {
            scheme_end = i;
            path_start = i + 3;
            break;
        }
    }
    if (scheme_end == -1 || path_start == -1) {
        printf("Invalid URL\n");
        return;
    }
    scheme = malloc(scheme_end + 1);
    strncpy(scheme, url, scheme_end);
    scheme[scheme_end] = '\0';
    path = malloc(len - path_start + 1);
    strncpy(path, url + path_start, len - path_start);
    path[len - path_start] = '\0';
    printf("\nScheme: %s\n", scheme);
    printf("Path: %s\n", path);
    free(scheme);
    free(path);
}

void printMailtoURLTokens(char *url) {
    char *scheme, *username, *host, *token;
    int i;
    int len = strlen(url);
    int scheme_end = -1;
    int username_start = -1;
    int username_end = -1;
    int host_start = -1;
    for (i = 0; i < len; i++) {
        if (url[i] == ':') {
            scheme_end = i;
            username_start = i + 1;
            break;
        }
    }
    if (scheme_end == -1 || username_start == -1) {
        printf("Invalid URL\n");
        return;
    }
    scheme = malloc(scheme_end + 1);
    strncpy(scheme, url, scheme_end);
    scheme[scheme_end] = '\0';
    for (i = username_start; i < len; i++) {
        if (url[i] == '@') {
            username_end = i;
            host_start = i + 1;
            break;
        }
    }
    if (username_end == -1 || host_start == -1) {
        printf("Invalid URL\n");
        free(scheme);
        return;
    }
    username = malloc(username_end - username_start + 1);
    strncpy(username, url + username_start, username_end - username_start);
    username[username_end - username_start] = '\0';
    host = malloc(len - host_start + 1);
    strncpy(host, url + host_start, len - host_start);
    host[len - host_start] = '\0';
    printf("\nScheme: %s\n", scheme);
    printf("Username: %s\n", username);
    printf("Host: %s\n", host);
    free(scheme);
    free(username);
    free(host);
}

void printhttpsURLTokens(char *url) {
    char *scheme, *username, *password, *host, *port, *path, *query, *fragment, *token;
    int i;
    int len = strlen(url);
    int scheme_end = -1;
    int username_start = -1;
    int username_end = -1;
    int password_start = -1;
    int password_end = -1;
    int host_start = -1;
    int host_end = -1;
    int port_start = -1;
    int port_end = -1;
    int path_start = -1;
    int path_end = -1;
    int query_start = -1;
    int query_end = -1;
    int fragment_start = -1;
    int fragment_end = -1;
    for (i = 0; i < len; i++) {
        if (url[i] == ':' && url[i+1] == '/' && url[i+2] == '/') {
            scheme_end = i;
            host_start = i + 3;
            break;
        }
    }
    if (scheme_end == -1 || host_start == -1) {
        printf("Invalid URL\n");
        return;
    }
    scheme = malloc(scheme_end + 1);
    strncpy(scheme, url, scheme_end);
    scheme[scheme_end] = '\0';
    for (i = host_start; i < len; i++) {
        if (url[i] == '@') {
            password_end = i;
            username_start = host_start;
            host_start = i + 1;

            //username:password format
            for (i = username_start; i < password_end; i++) {
                if (url[i] == ':') {
                    username_end = i;
                    password_start = i + 1;
                    break;
                }
            }

            //assign username and password
            username = malloc(username_end - username_start + 1);
            strncpy(username, url + username_start, username_end - username_start);
            username[username_end - username_start] = '\0';
            password = malloc(password_end - password_start + 1);
            strncpy(password, url + password_start, password_end - password_start);
            password[password_end - password_start] = '\0';
            break;
        }
    }
    //check for :port
    for(i = host_start; i < len; i++) {
        if (url[i] == ':') {
            host_end = i;
            port_start = i + 1;
            break;
        }
        else if(url[i] == '/') {
            host_end = i;
            path_start = i;
            break;
        }
        else if(i == len - 1) {
            host_end = i + 1;
        }
    }
    if (port_start != -1) {
        for (i = port_start; i < len; i++) {
            if (url[i] == '/') {
                port_end = i;
                path_start = i;
                break;
            }
            if (i == len - 1) {
                port_end = i + 1;
            }
        }
    }
    if (path_start != -1) {
        for (i = path_start; i < len; i++) {
            if (url[i] == '?') {
                path_end = i;
                query_start = i + 1;
                break;
            }
            if (url[i] == '#') {
                path_end = i;
                fragment_start = i + 1;
                break;
            }
            if (i == len - 1) {
                path_end = i + 1;
            }
        }
    }
    if (query_start != -1) {
        for (i = query_start; i < len; i++) {
            if (url[i] == '#') {
                query_end = i;
                fragment_start = i + 1;
                break;
            }
            if (i == len - 1) {
                query_end = i + 1;
            }
        }
    }
    if (fragment_start != -1) {
        fragment_end = len;
    }
    host = malloc(host_end - host_start + 1);
    strncpy(host, url + host_start, host_end - host_start);
    host[host_end - host_start] = '\0';
    if (port_start != -1) {
        port = malloc(port_end - port_start + 1);
        strncpy(port, url + port_start, port_end - port_start);
        port[port_end - port_start] = '\0';
    }
    if (path_start != -1) {
        path = malloc(path_end - path_start + 1);
        strncpy(path, url + path_start, path_end - path_start);
        path[path_end - path_start] = '\0';
    }
    if (query_start != -1) {
        query = malloc(query_end - query_start + 1);
        strncpy(query, url + query_start, query_end - query_start);
        query[query_end - query_start] = '\0';
    }
    if (fragment_start != -1) {
        fragment = malloc(fragment_end - fragment_start + 1);
        strncpy(fragment, url + fragment_start, fragment_end - fragment_start);
        fragment[fragment_end - fragment_start] = '\0';
    }
    printf("\nScheme: %s\n", scheme);
    if (username_end != -1) {
        printf("Username: %s\n", username);
    }
    if (password_end != -1) {
        printf("Password: %s\n", password);
    }
    printf("Host: %s\n", host);
    if (port_start != -1) {
        printf("Port: %s\n", port);
    }
    if (path_start != -1) {
        printf("Path: %s\n", path);
    }
    if (query_start != -1) {
        printf("Query: %s\n", query);
    }
    if (fragment_start != -1) {
        printf("Fragment: %s\n", fragment);
    }
    free(scheme);
    if (username_end != -1) {
        free(username);
    }
    if (password_end != -1) {
        free(password);
    }
    free(host);
    if (port_start != -1) {
        free(port);
    }
    if (path_start != -1) {
        free(path);
    }
    if (query_start != -1) {
        free(query);
    }
    if (fragment_start != -1) {
        free(fragment);
    }
}


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