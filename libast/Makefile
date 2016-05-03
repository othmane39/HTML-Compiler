all: libast 

libast: ast.c ast.h
	gcc -o ast.o -g -c ast.c
	ar rcs libast.a ast.o

clean:
	rm -f ast.o libast.a
