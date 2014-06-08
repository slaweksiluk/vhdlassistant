
GCC_ARGS=-Wall

all:
	flex snippetformatter.l 
	gcc $(GCC_ARGS) lex.yy.c -o snippetformatter

clean:
	rm -f snippetformatter
	rm -f lex.yy.c

