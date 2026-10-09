%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitness.tab.h"

extern int yylineno;
%}

%option noyywrap
%option yylineno
%option nounistd

%%

"KOSHISH"       { return KOSHISH; }
"GINTI"         { return GINTI; }
"KHORAK"        { return KHORAK; }
"BHAR"          { return BHAR; }
"DICHAK"        { return DICHAK; }

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.sval = strdup(yytext); 
    return ID; 
}

[0-9]+(\.[0-9]+)? { 
    yylval.dval = atof(yytext); 
    return NUMBER; 
}

\"([^"\\\n]|\\.)*\" { 
    // Strip quotes for string content
    int len = strlen(yytext);
    yylval.sval = (char*)malloc(len - 1);
    strncpy(yylval.sval, yytext + 1, len - 2);
    yylval.sval[len - 2] = '\0';
    return STRING; 
}

"//".*          { /* Ignore single-line comments */ }
"/*"([^*]|\*+[^/*])*\*+"/" { /* Ignore multi-line comments */ }

"="             { return '='; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
";"             { return ';'; }
"("             { return '('; }
")"             { return ')'; }

[ \t\r\n]+      { /* Ignore whitespace */ }

.               { 
    fprintf(stderr, "Lexical Error at line %d: Unrecognized character '%s'\n", yylineno, yytext); 
}

%%
