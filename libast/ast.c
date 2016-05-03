#include <stdlib.h>
#include <stdio.h>
#include "ast.h"

struct ast * mk_node(void){
    struct ast *e = malloc(sizeof(struct ast));
    e->node = malloc(sizeof(union node));
    return e;
}

struct ast * mk_integer(int n){
    struct ast * e = mk_node();
    e->type = INTEGER;
    e->node->num = n;
    return e;
}
struct ast * mk_binop(enum binop binop){
    struct ast * e = mk_node();
    e->type = BINOP;
    e->node->binop = binop;
    return e;
}
struct ast * mk_unaryop(enum unaryop unaryop){
    struct ast * e = mk_node();
    e->type = UNARYOP;
    e->node->unaryop = unaryop;
    return e;
}
struct ast * mk_var(char * var){
    struct ast * e = mk_node();
    e->type = VAR;
    e->node->str = var;
    return e;

}
struct ast * mk_import(struct path * chemin){
    struct ast * e = mk_node();
    e->type = IMPORT;
    e->node->chemin = chemin;
    return e;
}
struct ast * mk_app(struct ast * fun, struct ast * arg){
    struct ast * e = mk_node();
    e->type = APP;
    e->node->app = malloc(sizeof(struct app));
    e->node->app->fun = fun;
    e->node->app->arg = arg;
    return e;
}
struct ast * mk_word(char * str){
    struct ast * e = mk_node();
    e->type = WORD;
    e->node->str = str;
    return e;
};
struct ast * mk_tree(char * label, bool is_value, bool nullary, bool space,
                     struct attributes * att, struct ast * daughters){
    struct ast * e = mk_node();
    e->type = TREE;
    e->node->tree = malloc(sizeof(struct tree));
    e->node->tree->label = label;
    e->node->tree->is_value=is_value;
    e->node->tree->nullary=nullary;
    e->node->tree->space=space;
    e->node->tree->attributes=att;
    e->node->tree->daughters=daughters;
    return e;
}
struct ast * mk_forest(bool is_value, struct ast * head, struct ast * tail){
    struct ast * e = mk_node();
    e->type = FOREST;
    e->node->forest = malloc(sizeof(struct forest));
    e->node->forest->is_value = is_value;
    e->node->forest->head=head;
    e->node->forest->tail=tail;
    return e;
}
struct ast * mk_fun(char * id, struct ast * body){
    struct ast * e = mk_node();
    e->type = FUN;
    e->node->fun = malloc(sizeof(struct fun));
    e->node->fun->id = id;
    e->node->fun->body=body;
    return e;
}
struct ast * mk_match(struct ast * ast, struct patterns * patterns){
    struct ast * e = mk_node();
    e->type = MATCH;
    e->node->match = malloc(sizeof(struct match));
    e->node->match->ast = ast;
    e->node->match->patterns=patterns;
    return e;
}
struct ast * mk_cond(struct ast * cond, struct ast * then_br, struct ast * else_br){
    struct ast * e = mk_node();
    e->type = COND;
    e->node->cond = malloc(sizeof(struct cond));
    e->node->cond->cond = cond;
    e->node->cond->then_br=then_br;
    e->node->cond->else_br=else_br;
    return e;
}

struct ast * mk_declrec(char * id, struct ast * body){
    struct ast * e = mk_node();
    e->type = DECLREC;
    e->node->fun=malloc(sizeof(struct fun));
    e->node->fun->id = id;
    e->node->fun->body=body;
    return e;
}

struct attributes * mk_attributes(struct ast * key, struct ast * value, struct attributes * next)
{
    struct attributes * e = malloc(sizeof(struct attributes));
    e->key = key;
    e->value = value;
    e->next = next;
    return e;
}

void set_next_attributes(struct attributes * attributesToUpdate, struct attributes * attibutesToSetAsNext)
{
    attributesToUpdate->next = attibutesToSetAsNext;
}


void print_ast(struct ast* ast){
    switch(ast->type){
        case WORD:
            printf("%s", ast->node->str);
            break;
        case TREE:
            print_tree(ast->node->tree);
            break;
        case FOREST:
            print_forest(ast->node->forest);
            break;
        default:
            printf("not implemented yet!\n");
            break;
    }
}

void print_tree(struct tree* tree){

    if(tree->is_value){
        
        if(tree->daughters != NULL ){
            
            print_ast(tree->daughters);
        }
        if(tree->space)
            printf(" ");
    }
    else{
        printf("<%s", tree->label);
    
        if(tree->attributes != NULL){
            print_attributes(tree->attributes);
        }
        if(tree->nullary)
            printf("/");
        printf(">");
        if(tree->daughters != NULL ){
            if(!tree->is_value)
            print_ast(tree->daughters);
        }
        if(!tree->nullary)
            printf("</%s>", tree->label);
    }


}

void print_attributes(struct attributes* attributes){
    if(attributes->next != NULL)
        print_attributes(attributes->next);
    printf(" ");
    print_ast(attributes->key);
    printf("=\""); print_ast(attributes->value);
    printf("\"");
    
}

void print_forest(struct forest* forest){
    if(!(forest->is_value) && forest->tail != NULL)
        print_ast(forest->tail);
    if(forest->head != NULL)
        print_ast(forest->head);
}


void setTailForest(struct forest * forest, struct ast * tailToAdd)
{
    forest->tail = tailToAdd;
}