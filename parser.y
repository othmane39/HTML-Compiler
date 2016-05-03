%{
#include <stdio.h>
#include "libast/ast.h"  
extern int yyerror(char*);
int yylex(void);
extern int yylineno;

#ifdef DEBUGBISON
	#define DEBUG_PRINTF_BISON 1
#else
	#define DEBUG_PRINTF_BISON 0
#endif

%}

%left ID
%left IDNODE
%left QOT_OPN
%left QOT_CL
%left TEXT
%left TEXT_SPACE
%left ATT
%left LET
%left REC
%left F
%left AFFECT
%left IF_S
%left THEN_S
%left ELSE_S
%left SUP_EQ
%left INF_EQ
%left EQIV
%left AND_t
%left OR_t

%union {
	struct attributes* attributes;
	struct ast* ast;
	char* str;
	int n;
}

%type <str> ID
%type <str> IDNODE
%type <str> ATT
%type <str> TEXT
%type <str> TEXT_SPACE
%type <ast> st
%type <ast> forest_serie
%type <ast> forest_content 
%type <ast> forest
%type <ast> tree
%type <ast> expression
%type <attributes> params
%type <attributes> attribute






%type <ast> txt
%type <ast> content
%type <ast> object



%start st

%%
/*actual start type elements*/
st : 
	forest_serie	
		{	if(DEBUG_PRINTF_BISON) {printf("start -> forest_serie\n");}
			print_ast($1);	}			
|	forest_content	
		{	if(DEBUG_PRINTF_BISON) {printf("start -> forest_content\n");}
			print_ast($1);	}
|	instructions
		{	if(DEBUG_PRINTF_BISON) {printf("start -> instructions\n");	}}
|	if_statement
		{	if(DEBUG_PRINTF_BISON) {printf("start -> if_statement\n");	}}




/*a succession of forest*/
forest_serie : 
	forest_serie forest 			
		{	if(DEBUG_PRINTF_BISON) {printf("forest_serie -> forest_serie forest\n");}
			$$ = mk_forest(false, $2, $1);	}
|	forest
		{	if(DEBUG_PRINTF_BISON) {printf("forest_serie -> forest\n");}
			$$ = mk_forest(false, $1, NULL);	}

/*a succession of let declaration*/
instructions:
	instructions var_instruction
		{	if(DEBUG_PRINTF_BISON) {printf("instructions -> instructions var_instruction\n");	}}
|	var_instruction
		{	if(DEBUG_PRINTF_BISON) {printf("instructions -> var_instruction\n");}}




/*let var & fct*/
var_instruction:
	LET ID args '=' var_value ';'
		{	if(DEBUG_PRINTF_BISON) {printf("var_instruction -> let %s = var_value\n", $2);}}
|	LET ID args '=' fun_value var_value ';'
		{	if(DEBUG_PRINTF_BISON) {printf("var_instruction -> let %s args = fun_value var_value\n", $2);}}


/*actual types of let var values*/
var_value:
	forest
		{	if(DEBUG_PRINTF_BISON) {printf("var_value -> forest\n");}}
|	tree


/*imbriqued function declaration of arguments supported*/
fun_value:
	fun_value F args_f AFFECT 
		{	if(DEBUG_PRINTF_BISON) {printf("fun_value -> fun_value fun args ->\n");}}
|	F args_f AFFECT 
		{	if(DEBUG_PRINTF_BISON) {printf("fun_value -> fun args ->\n");}}

/*let f x1 x2 x3.. =   card(x1, x2,..)>=0*/
args:
	args ID
	{	if(DEBUG_PRINTF_BISON) {printf("args -> args %s\n", $2);}}
| 	%empty
	{	if(DEBUG_PRINTF_BISON) {printf("args -> empty\n");}}

/*fun x1 x2 .. -> card(x1, x2)>0*/ 
args_f:
	args_f ID
	{	if(DEBUG_PRINTF_BISON) {printf("args -> args %s\n", $2);}}
| 	ID
	{	if(DEBUG_PRINTF_BISON) {printf("args -> %s\n", $1);}}
	





forest : 
	'{' forest_content '}' 			
		{	if(DEBUG_PRINTF_BISON) {printf("forest -> { forest_content }\n");}
			$$ = $2;		}


/* a forest can be empty {} */
forest_content : 
	forest_content tree
		{	if(DEBUG_PRINTF_BISON) {printf("forest_content -> forest_content tree\n");}
			setTailForest((struct forest *)$1, $2);
			$$ = mk_forest(false, $2, $1);	}
|	%empty
		{	if(DEBUG_PRINTF_BISON) {printf("forest_content -> empty\n");}
			$$ = mk_forest(true, NULL, NULL);	}


/* all tree grammar definitions*/
tree : 
	IDNODE '[' params ']' '{' content '}'	
		{	if(DEBUG_PRINTF_BISON) {printf("tree -> %s[ params ] { content }\n", $1);}
			$$ = mk_tree($1, false, false, false, $3, $6);		}
|	IDNODE '{' content '}'	
		{	if(DEBUG_PRINTF_BISON) {printf("tree -> %s{ content }\n", $1);}
			$$ = mk_tree($1, false, false, false, NULL, $3);	}
|	IDNODE '[' params ']' '/'	
		{	if(DEBUG_PRINTF_BISON) {printf("tree -> %s[ params ]/\n", $1);}
			$$ = mk_tree($1, false, true, false, $3, NULL);		}
|	IDNODE '/'
		{	if(DEBUG_PRINTF_BISON) {printf("tree -> %s/\n", $1);}
			$$ = mk_tree($1, false, true, false, NULL, NULL);}

/*attributes concatenantion of a tree*/
params : 
	params attribute
		{	if(DEBUG_PRINTF_BISON) {printf("params -> params attribute\n");}
			set_next_attributes($2, $1);
			$$ = $2;		}
|	attribute
		{	if(DEBUG_PRINTF_BISON) {printf("params -> attribute\n");}
			$$ = $1	;	}


attribute :
	ATT '=' txt
		{if(DEBUG_PRINTF_BISON) {printf("attribute -> %s = string\n", $1);}
			$$ = mk_attributes(mk_word($1), $3, NULL);	}





/*make difference between text and text with space in a tree*/
txt : 
	TEXT
		{	if(DEBUG_PRINTF_BISON) {printf("txt -> %s\n", $1);}	
			$$= mk_tree("text", true, false, false, NULL, mk_word($1));}
| 	TEXT_SPACE
		{	if(DEBUG_PRINTF_BISON) {printf("txt -> %s_SPACE\n", $1);}
			$$= mk_tree("text", true, false, true, NULL, mk_word($1));}

/*concatenantion of all elements in tree*/
content : 
	content object	
		{	if(DEBUG_PRINTF_BISON) {printf("content -> content object\n");}
			$$ = mk_forest(false, $2, $1);		}
|	object		
		{	if(DEBUG_PRINTF_BISON) {printf("content -> object\n");}
			$$ = mk_forest(true, $1, NULL);	}

/*actual type of elements in tree*/
object	:
	txt
		{	if(DEBUG_PRINTF_BISON) {printf("object -> string\n");}
			$$ = $1;		}
|	tree		
		{if(DEBUG_PRINTF_BISON) {printf("object -> tree\n");}		
			$$ = $1;	}


/*if statement with else expression */
if_statement:
	if_req expression
		{	if(DEBUG_PRINTF_BISON) {printf("if_statement -> if_incremented expression\n");}}



/*if e1 then e2 else if ... imbriqued without else expression*/
if_req:
	if_req IF_S union_expression_bool THEN_S expression ELSE_S
		{	if(DEBUG_PRINTF_BISON) {printf("if_req -> if_req IF expr_bool THEN exp ELSE\n");}}
| 	IF_S union_expression_bool THEN_S expression ELSE_S
		{	if(DEBUG_PRINTF_BISON) {printf("if_req -> IF expr_bool THEN exp ELSE\n");}}

/*AND, OR concatenantion boolean_expressions*/
union_expression_bool:
	union_expression_bool AND_t expression_bool
		{	if(DEBUG_PRINTF_BISON) {printf("union_expression_bool -> union_expression_bool AND expression_bool\n");}}

|	union_expression_bool OR_t expression_bool
		{	if(DEBUG_PRINTF_BISON) {printf("union_expression_bool -> union_expression_bool OR expression_bool\n");}}
|	expression_bool
		{	if(DEBUG_PRINTF_BISON) {printf("union_expression_bool -> expression_bool\n");}}



/*comparaison of 2 expression for boolean result*/
expression_bool:	
	exp comp_OP exp
		{	if(DEBUG_PRINTF_BISON) {printf("expression_bool -> exp OP exp\n");}}
|	'(' expression_bool ')'
		{	if(DEBUG_PRINTF_BISON) {printf("expression_bool -> ( expression_bool )\n");}}
|	'!' expression_bool
		{	if(DEBUG_PRINTF_BISON) {printf("expression_bool -> ! expression_bool\n");}}


expression:
	expression '+' exp
		{	if(DEBUG_PRINTF_BISON) {printf("expression -> expression + exp\n");}}
|	expression '-' exp
		{	if(DEBUG_PRINTF_BISON) {printf("expression -> expression - exp\n");}}
|	'(' expression ')'
		{	if(DEBUG_PRINTF_BISON) {printf("expression -> ( expression )\n");}}
| 	exp 
		{	if(DEBUG_PRINTF_BISON) {printf("expression -> exp\n");}}


/*Actual type of expression*/
exp:
	forest
		{	if(DEBUG_PRINTF_BISON) {printf("exp -> forest\n");}}
| 	tree
		{	if(DEBUG_PRINTF_BISON) {printf("exp -> tree\n");}}

comp_OP:
	'>'
|	SUP_EQ
|	'<'
|	INF_EQ
|	EQIV

%%
