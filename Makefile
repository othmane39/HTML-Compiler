CC=gcc

all: parser.tab.c parser.c compiler.c libast/libast.a
	$(CC) -ocompiler compiler.c parser.c parser.tab.c -lfl -last -L libast/

debug: parser.tab.c parser.c compiler.c libast/libast.a
	$(CC) -ocompiler compiler.c parser.c parser.tab.c -g -lfl -last -L libast/ -D DEBUGFLEX -D DEBUGBISON -D DEBUG

debug-flex: parser.tab.c parser.c compiler.c libast/libast.a
	$(CC) -ocompiler compiler.c parser.c parser.tab.c -g -lfl -last -L libast/ -D DEBUGFLEX

debug-bison: parser.tab.c parser.c compiler.c libast/libast.a
	$(CC) -ocompiler compiler.c parser.c parser.tab.c -g -lfl -last -L libast/ -D DEBUGBISON

parser.c: parser.lex
	flex -oparser.c parser.lex

parser.tab.c: parser.y
	bison -d -oparser.tab.c parser.y

libast/libast.a:
	make -C libast/

clean:
	rm -f parser.tab.c parser.tab.h parser.c compiler
	make -C libast/ clean

test: 
	./compiler test1.customhtml