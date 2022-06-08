/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
| UNIFAL - Universidade Federal de Alfenas
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho . . : Trabalho Final de Teoria de Linguagens e Compiladores
| Disciplina: Teoria de Linguagens e Compiladores
| P r o f e s s o r . : Luiz Eduardo da S i l v a
| Aluno . . . . . : Pedro Paschoalotti Barraza
| Data . . . . . . : 03/04/2022
+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/

%{
    #include "sintatico.h"
    void erro (char *s);
    char atomo[100];
    int numLinha = 1;
%}

identificador   [a-zA-Z]([a-zA-Z0-9])*
numero          [0-9]+
espaco          [ \t\r]+
novalinha       [\n]

%x comment
%option noyywrap

%%

programa        return T_PROGRAMA;
inicio          return T_INICIO;
fimprograma     return T_FIM;
leia            return T_LEIA;
escreva         return T_ESCREVA;
se              return T_SE;
entao           return T_ENTAO;
senao           return T_SENAO;
fimse           return T_FIMSE;
enquanto        return T_ENQTO;
faca            return T_FACA;
fimenquanto     return T_FIMENQTO;
repita          return T_REPITA;
ate             return T_ATE;
fimrepita       return T_FIMREPITA;
"+"             return T_MAIS;
"-"             return T_MENOS;
"*"             return T_VEZES;
div             return T_DIV;
">"             return T_MAIOR;
"<"             return T_MENOR;
"="             return T_IGUAL;
e               return T_E;
ou              return T_OU;
nao             return T_NAO;
"<-"            return T_ATRIB;
"("             return T_ABRE;
")"             return T_FECHA;
inteiro         return T_INTEIRO;
logico          return T_LOGICO;
V               return T_V;
F               return T_F;
"["             return T_ABRECOL;
"]"             return T_FECHACOL;

{identificador} { strcpy(atomo, yytext); return T_IDENTIF; }
{numero}        { strcpy(atomo, yytext); return T_NUMERO; }
{espaco}        /*Não faz nada*/
{novalinha}     { numLinha++; }
"//".*          ; //não faz nada
"/*"            BEGIN(comment);
<comment>"*/"   BEGIN(INITIAL);
<comment>.      ; //Não faz nada
<comment>\n     { numLinha++; }
.               erro ("LEXICO");

%%