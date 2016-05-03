%{

#include "parser.tab.h"
#include <stdio.h>
#include <string.h>
void count();
extern int yyerror (char *);

#ifdef DEBUGFLEX
	#define DEBUG_PRINTF 1
#else
	#define DEBUG_PRINTF 0
#endif

%}

LETTER [A-Za-z]
IDCOMPL [_.']
NUMBER [0-9]
IDALL {LETTER}|{IDCOMPL}|{NUMBER}
X [Xx]
M [Mm]

FSTWOX [A-Za-z]{-}[Xx] 
ALLWOM [A-Za-z0-9_.']{-}[Mm]
ALLWOL [A-Za-z0-9_.']{-}[Ll]

/*ID node with XML conventions*/
IDNODE {X}|{X}{M}|(({FSTWOX}|{X}{ALLWOM}|{X}{M}{ALLWOL}|_{IDALL}){IDALL}*)

%option yylineno stack

%x QUOTE
%x ATTR

%%
"if"/[[:space:]]			{if(DEBUG_PRINTF) {printf("IF ");}						count(); return(IF_S);}
"else"/[[:space:]]			{if(DEBUG_PRINTF) {printf("else ");}					count(); return(ELSE_S);}
"then"/[[:space:]]			{if(DEBUG_PRINTF) {printf("then ");}					count(); return(THEN_S);}
"let"/[[:space:]]			{if(DEBUG_PRINTF) {printf("LET ");}						count(); return(LET);}
"rec"/[[:space:]]			{if(DEBUG_PRINTF) {printf("REC ");}						count(); return(REC);}
"fun"/[[:space:]]			{if(DEBUG_PRINTF) {printf("FUN ");}						count(); return(F);}
{IDALL}/[[:space:]]			{if(DEBUG_PRINTF) {printf("ID_%s ", yytext);}			count(); yylval.str=strdup(yytext); return(ID);}						
"["							{if(DEBUG_PRINTF) {printf("LBRACK ");} 					count(); yy_push_state(ATTR); return('[');}
<ATTR>"]"/[\/]				{if(DEBUG_PRINTF) {printf("RBRACKCLOSE");} 				count(); yy_pop_state (); return(']');}
<ATTR>"]"					{if(DEBUG_PRINTF) {printf("RBRACK ");} 					count(); yy_pop_state (); return(']');}
^{IDNODE}/[\{\[\/] 			{if(DEBUG_PRINTF) {printf("IDNODE_%s ", yytext);} 		count(); yylval.str=strdup(yytext); return(IDNODE);} 
{IDNODE}/[\{\[\/] 			{if(DEBUG_PRINTF) {printf("IDNODE_%s ", yytext);} 		count(); yylval.str=strdup(yytext); return(IDNODE);}
\/							{if(DEBUG_PRINTF) {printf("BACKSLASH ");} 				count(); return('/');}

<ATTR>{IDNODE}/[=]			{if(DEBUG_PRINTF) {printf("ATTR_%s ", yytext);} 		count(); yylval.str=strdup(yytext); return(ATT);}
<ATTR>"="			 		{if(DEBUG_PRINTF) {printf("EQUAL ");} 					count(); return('=');}


 
<INITIAL,ATTR>[\"] 			{if(DEBUG_PRINTF) {printf("QOT_OPN ");} 					count(); yy_push_state(QUOTE); }/*return(QOT_OPN);}*/
<ATTR>.						{if(DEBUG_PRINTF) {printf("NC_%s", yytext);} 					count(); }

<QUOTE>[\"] 				{if(DEBUG_PRINTF) {printf("QOT_CL ");} 					count(); yy_pop_state (); } /*return(QOT_CL);}*/
<QUOTE>\\\"					{if(DEBUG_PRINTF) {printf("&quot_PoC ");}}
<QUOTE>[^[\\\"[:space:]]+/[[:space:]] 	{if(DEBUG_PRINTF) {printf("TEXT_SPACE_%s ", yytext);} 			count(); yylval.str=strdup(yytext); return(TEXT_SPACE);}
<QUOTE>[^[\\\"[:space:]]+ 	{if(DEBUG_PRINTF) {printf("TEXT_%s ", yytext);} 			count(); yylval.str=strdup(yytext); return(TEXT);}
<QUOTE>. 					{count();}

"="			 				{if(DEBUG_PRINTF) {printf("EQUAL ");} 					count(); return('=');}
"->"						{if(DEBUG_PRINTF) {printf("-> ");} 					count(); return(AFFECT);}
"{"							{if(DEBUG_PRINTF) {printf("LBRACE ");} 					count(); return('{');}
"}"							{if(DEBUG_PRINTF) {printf("RBRACE ");} 					count(); return('}');}
";"							{if(DEBUG_PRINTF) {printf(";");} 					count(); return(';');}
"+"							{if(DEBUG_PRINTF) {printf("+");} 					count(); return('+');}
"-"							{if(DEBUG_PRINTF) {printf("-");} 					count(); return('-');}
"("							{if(DEBUG_PRINTF) {printf("(");} 					count(); return('(');}
")"							{if(DEBUG_PRINTF) {printf(")");} 					count(); return(')');}
">"							{if(DEBUG_PRINTF) {printf(">");} 					count(); return('>');}
">="						{if(DEBUG_PRINTF) {printf(">=");} 					count(); return(SUP_EQ);}
"<"							{if(DEBUG_PRINTF) {printf("<");} 					count(); return('<');}
"<="						{if(DEBUG_PRINTF) {printf("<=");} 					count(); return(INF_EQ);}
"=="						{if(DEBUG_PRINTF) {printf("==");} 					count(); return(EQIV);}
"&&"						{if(DEBUG_PRINTF) {printf("&&");} 					count(); return(AND_t);}
"||"						{if(DEBUG_PRINTF) {printf("||");} 					count(); return(OR_t);}
"!"							{if(DEBUG_PRINTF) {printf("!");} 					count(); return('!');}
[ \t\v\f]					{count();}
[\n] 						{if(DEBUG_PRINTF) {printf("\n");}						count(); }
. 							{count(); }


%%

int yywrap() {
	return 1;
}

int column = 0;
/* This function counts the number of character, for debugging*/
void count() {
	int i;
	for (i = 0; yytext[i] != '\0'; i++) {
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;
	}
}