#ifndef AST
#define AST
#include <stdbool.h>
//#include "chemin.h"
//#include "pattern.h"

enum ast_type {
    INTEGER,  // L'expression est un entier
    BINOP,    // L'expression est un opÃ©rateur (addition, multiplication, comparaison,
              // opÃ©rateur logique ...)
    UNARYOP,  // L'expression est un opÃ©rateur unaire (ici, nous n'avons que la
              // nÃ©gation logique)
    VAR,      // L'expression est une variable
    IMPORT,   // L'expression est correspond Ã  une importation de fichier
    APP,      // L'expression est une application de fonction
    WORD,     // L'expression est un mot
    TREE,     // L'expression est un arbre
    FOREST,   // L'expression est une forÃªt
    FUN,      // L'expression est une fonction
    MATCH,    // L'expression est un filtre
    COND,     // L'expression est une conditionnelle
    DECLREC   // DÃ©clarations rÃ©cursives (let rec ... where rec ...)
};

enum binop{PLUS, MINUS, MULT, DIV, LEQ, LE, GEQ, GE, EQ, NEQ,OR, AND,EMIT};

enum unaryop {NOT,NEG};

struct ast;


struct app{
    struct ast *fun;
    struct ast *arg;
};

struct attributes{
    bool is_value;
    struct ast * key;
    struct ast * value;
    struct attributes * next;
};

struct tree{
    char * label;
    bool is_value;
    bool nullary;
    bool space;
    struct attributes * attributes;
    struct ast * daughters;
};

struct forest{
    bool is_value;
    struct ast * head;
    struct ast * tail;
};

struct fun{
    char *id;
    struct ast *body;
};

struct patterns{
    struct pattern * pattern; //filtre
    struct ast * res;         //rÃ©sultat si le filtre accepte
    struct patterns * next;   //filtres suivants si ce filtre Ã©choue
};

struct match {
    struct ast * ast;           // expression filtrÃ©e
    struct patterns * patterns; // liste des filtres
};

struct cond{
    struct ast *cond;
    struct ast *then_br;
    struct ast *else_br;
};

struct declrec{
    char * id;
    struct ast * body;
};


union node{
    int num;
    enum binop binop;
    enum unaryop unaryop;
    char * str;  // peut reprÃ©senter ou bien une variable ou encore un mot
    struct path * chemin; 
    struct app * app;
    struct tree * tree;
    struct forest * forest;
    struct fun * fun;
    struct match * match;
    struct cond * cond;
};

struct ast{
    enum  ast_type type;
    union node * node;
};

struct ast * mk_node(void);
struct ast * mk_integer(int n);
struct ast * mk_binop(enum binop binop);
struct ast * mk_unaryop(enum unaryop unaryop);
struct ast * mk_var(char * var);
struct ast * mk_import(struct path * chemin);
struct ast * mk_app(struct ast * fun, struct ast * arg);
struct ast * mk_word(char * str);
struct ast * mk_tree(char * label, bool is_value, bool nullary, bool space, 
                     struct attributes * att, struct ast * daughters);
struct ast * mk_forest(bool is_value, struct ast * head, struct ast * tail);
struct ast * mk_fun(char * id, struct ast * body);
struct ast * mk_match(struct ast * ast, struct patterns * patterns);
struct ast * mk_cond(struct ast * cond, struct ast * then_br, struct ast * else_br);
struct ast * mk_declrec(char * id, struct ast * body);

struct attributes * mk_attributes(struct ast * key, struct ast * value, struct attributes * next);
void set_next_attributes(struct attributes * attributesToUpdate, struct attributes * attibutesToSetAsNext);

void print_ast(struct ast* ast);
void print_tree(struct tree* tree);
void print_attributes(struct attributes* attributes);
void print_forest(struct forest* forest);

void setTailForest(struct forest * forest, struct ast * tailToAdd);

#endif