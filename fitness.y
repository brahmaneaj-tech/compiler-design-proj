%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yylineno;
extern FILE *yyin;

void yyerror(const char *s);

/* ========================================================================= */
/*                              SYMBOL TABLE                                 */
/* ========================================================================= */
#define MAX_SYMBOLS 100

typedef struct {
    char name[64];
    double value;
    int type; /* 1: KOSHISH, 2: GINTI, 3: KHORAK, 4: BHAR */
    int is_declared;
} Symbol;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

/* Lookup symbol by variable name */
int lookup_symbol(const char *name) {
    int i;
    for (i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

/* Insert a new symbol into table (Error on duplicate declaration) */
int insert_symbol(const char *name, int type) {
    if (lookup_symbol(name) != -1) {
        fprintf(stderr, "Semantic Error [Line %d]: Redeclaration of variable '%s'\n", yylineno, name);
        return -1;
    }
    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Fatal Error: Symbol table capacity reached!\n");
        return -1;
    }
    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].value = 0.0;
    symbol_table[symbol_count].type = type;
    symbol_table[symbol_count].is_declared = 1;
    symbol_count++;
    return symbol_count - 1;
}

/* Set symbol value (Error on undeclared variable) */
int set_symbol_value(const char *name, double val) {
    int idx = lookup_symbol(name);
    if (idx == -1) {
        fprintf(stderr, "Semantic Error [Line %d]: Assignment to undeclared variable '%s'\n", yylineno, name);
        return -1;
    }
    symbol_table[idx].value = val;
    return idx;
}

/* Retrieve symbol value (Error on undeclared variable) */
double get_symbol_value(const char *name) {
    int idx = lookup_symbol(name);
    if (idx == -1) {
        fprintf(stderr, "Semantic Error [Line %d]: Reference to undeclared variable '%s'\n", yylineno, name);
        return 0.0;
    }
    return symbol_table[idx].value;
}
%}

%union {
    double dval;
    char *sval;
    int type;
}

%token <dval> NUMBER
%token <sval> ID STRING
%token KOSHISH GINTI KHORAK BHAR DICHAK

%type <dval> expr
%type <type> type_spec

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%

program:
    stmt_list
    ;

stmt_list:
    stmt_list stmt
    | stmt
    ;

stmt:
    decl_stmt ';'
    | assign_stmt ';'
    | print_stmt ';'
    | ';'
    ;

decl_stmt:
    type_spec ID {
        insert_symbol($2, $1);
        free($2);
    }
    | type_spec ID '=' expr {
        if (insert_symbol($2, $1) != -1) {
            set_symbol_value($2, $4);
        }
        free($2);
    }
    ;

type_spec:
    KOSHISH { $$ = 1; }
    | GINTI   { $$ = 2; }
    | KHORAK  { $$ = 3; }
    | BHAR    { $$ = 4; }
    ;

assign_stmt:
    ID '=' expr {
        set_symbol_value($1, $3);
        free($1);
    }
    ;

print_stmt:
    DICHAK expr {
        if ($2 == (long long)$2) {
            printf("%lld\n", (long long)$2);
        } else {
            printf("%.2f\n", $2);
        }
    }
    | DICHAK STRING {
        printf("%s\n", $2);
        free($2);
    }
    ;

expr:
    NUMBER { $$ = $1; }
    | ID {
        $$ = get_symbol_value($1);
        free($1);
    }
    | expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr {
        if ($3 == 0.0) {
            fprintf(stderr, "Runtime Error [Line %d]: Division by zero!\n", yylineno);
            $$ = 0.0;
        } else {
            $$ = $1 / $3;
        }
    }
    | '(' expr ')' { $$ = $2; }
    | '-' expr %prec UMINUS { $$ = -$2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error [Line %d]: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    printf("====================================================\n");
    printf("        FitnessScript Interpreter (.fit)            \n");
    printf("====================================================\n");

    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Error: Cannot open source file '%s'\n", argv[1]);
            return 1;
        }
        yyin = file;
    } else {
        printf("Reading from standard input...\n");
    }

    if (yyparse() == 0) {
        printf("----------------------------------------------------\n");
        printf("Execution completed successfully.\n");
    } else {
        printf("----------------------------------------------------\n");
        printf("Execution failed due to errors.\n");
    }

    return 0;
}
