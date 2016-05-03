#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef DEBUG
  #define DEBUG_PRINTF 1
#else
  #define DEBUG_PRINTF 0
#endif

int yyparse();
extern FILE* yyin;
extern int column;
extern int yylineno;
int yyerror(char*);
char* file_name=NULL;

int main(int argc, char** argv){
	FILE* input = NULL;

  if(argc > 1){
  	input = fopen(argv[1], "r");
  	file_name = strdup(argv[1]);

		if(input)
			yyin = input;
		else fprintf(stderr, "%s: Could not open %s\n", *argv, argv[1]);

	}else file_name = "input_error";
  
  /* If we are debugging, prints a message */
  if(DEBUG_PRINTF){
    printf("====================\nDEBUG PRINTF ENABLED\n====================\n");
  }
  if(!yyparse()){
    if(DEBUG_PRINTF)
      printf("Success\n");
    return EXIT_SUCCESS;
  }
  else
  {
    if(DEBUG_PRINTF)
      printf("Error\n");
  	return EXIT_FAILURE;
  }
  free(file_name);
  return 0;
}

int yyerror (char *s) {
    fflush (stdout);
    fprintf (stderr, "%s:%d:%d: %s\n",file_name, yylineno, column, s);
    return 0;
}