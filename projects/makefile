simples : estrut.c lexico.l sintatico.y;\
	flex -o lexico.c lexico.l;\
	bison -o sintatico.c sintatico.y -v -d;\
	gcc sintatico.c -o simples;

limpa :	;\
	rm -f lexico.c sintatico.c sintatico.output *~ sintatico.h simples\
