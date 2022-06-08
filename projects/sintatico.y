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
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "lexico.c"
    #include "estrut.c"

    void erro(char *);
    int yyerror(char *);
    int conta = 0;
    int rotulo = 0;
    char tipo;
%}

%start programa

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_ATRIB

%token T_LEIA
%token T_ESCREVA

%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE

%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_IGUAL
%token T_MAIOR
%token T_MENOR

%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NAO

%token T_NUMERO
%token T_ABRECOL
%token T_FECHACOL
%token T_ABRE
%token T_FECHA
%token T_INTEIRO
%token T_LOGICO

%token T_ENQTO
%token T_FACA
%token T_FIMENQTO

%token T_REPITA
%token T_ATE
%token T_FIMREPITA

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa 
    : cabecalho variaveis{ 
        mostra_tabela(); 
        fprintf (yyout, "\tAMEM\t%d\n", conta); 
        empilha(conta);
    }
    T_INICIO lista_comandos T_FIM{ 
        fprintf (yyout, "\tDMEM\t%d\n", desempilha()); 
        fprintf (yyout, "\tFIMP\n"); 
    }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF{
        fprintf(yyout, "\tINPP\n"); 
    }
    ;

variaveis
    :
    |  declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_INTEIRO{ 
        tipo = 'i'; 
    }
    | T_LOGICO{ 
        tipo = 'l'; 
    }
    ;

lista_variaveis
    : lista_variaveis T_IDENTIF{ 
        strcpy(elem_tab.id, atomo); 
        elem_tab.tipo = tipo;
    } tamanho
    | T_IDENTIF{ 
        strcpy(elem_tab.id, atomo);
        elem_tab.tipo = tipo;
    } tamanho
    ;
    
tamanho
    : T_ABRECOL T_NUMERO T_FECHACOL{
        elem_tab.endereco = conta;
        elem_tab.categoria = VET;
        elem_tab.tamanho = atoi(atomo);
        conta = conta + atoi(atomo);
        insere_simbolo(elem_tab);
    }
    | {
        elem_tab.categoria = VAR;
        elem_tab.tamanho = 1;
        elem_tab.endereco = conta++;
        insere_simbolo(elem_tab);
    }
    ;

lista_comandos
    :
    | comando lista_comandos
    ;

comando 
    : leitura
    | escrita
    | repeticao
    | selecao
    | atribuicao
    ;

leitura
    : T_LEIA T_IDENTIF{
        int pos = busca_simbolo(atomo);
        if (pos == -1) 
            erro("Variavel nao declarada!");
        empilha(pos);
    } indice{
        fprintf(yyout, "\tLEIA\n");
        int categoria = desempilha();
        int pos = desempilha();
        //TODO Verificação tipo AQUI
        if (categoria == VET){
            fprintf(yyout, "\tARZV\t%d\n", TabSimb[pos].endereco);
        }
        else if(categoria == VAR){
            fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco);
        }
    }
    ;

escrita
    : T_ESCREVA expr{
        desempilha(); //retira o resultado do tipo da expressão empilhada.
        fprintf(yyout, "\tESCR\n");
    }
    ;

repeticao
    : T_ENQTO {
        rotulo++;
        fprintf(yyout, "L%d\tNADA\n", rotulo);
        empilha(rotulo);
    }
    expr T_FACA {
        char t = desempilha(); //retira o tipo da expressão;
        if(t != 'l'){
            erro("Deve ser tipo logico");
        }
        rotulo++;
        fprintf(yyout, "\tDSVF\tL%d\n", rotulo);
        empilha(rotulo);
    }
    lista_comandos T_FIMENQTO{
        int r1 = desempilha();
        int r2 = desempilha();
        fprintf(yyout, "\tDSVS\tL%d\n", r2);
        fprintf(yyout, "L%d\tNADA\n", r1);
    }
    | T_REPITA {
        rotulo++;
        fprintf(yyout, "L%d\tNADA\n", rotulo);
        empilha(rotulo);
    }
    lista_comandos T_ATE expr{
        int t = desempilha(); //retira o tipo da expressão
        if (t != 'l'){
            erro("Tipo inválido");
        }
        int r1 = desempilha ();
        fprintf(yyout,"\tDSVF\tL%d\n",rotulo);
        rotulo++;
        empilha (rotulo);
    }
    T_FIMREPITA{
        int r1 = desempilha();
        fprintf(yyout,"\tDSVF\tL%d\n",r1);
        fprintf(yyout,"L%d\tNADA\n",r1);
    }
    ;

selecao
    : T_SE expr T_ENTAO {
        int t = desempilha(); //retira o tipo da expressão da pilha
        rotulo++;
        fprintf(yyout, "\tDSVF\tL%d\n", rotulo);
        empilha(rotulo);
    }
    lista_comandos T_SENAO {
        int r = desempilha();
        rotulo++;
        fprintf(yyout, "\tDSVS\tL%d\n", rotulo);
        empilha(rotulo);
        fprintf(yyout, "L%d\tNADA\n", r);
    }
    lista_comandos T_FIMSE{
        int r = desempilha();
        fprintf(yyout, "L%d\tNADA\n", r);
    }
    ;

atribuicao
    : T_IDENTIF{
        int pos = busca_simbolo(atomo);
        if (pos == -1){
            erro("Variável não declarada!");
        }
        empilha(pos);
    } indice T_ATRIB expr{  //o indice empilha a categoria; o expr empilha o tipoexpr
        int tipoexpr = desempilha(); //ja estamos recebendo o tipo da expressao;
        int categoria = desempilha(); //se é variavel ou vetor
        int pos = desempilha();
        if (TabSimb[pos].tipo == tipoexpr){
            if(categoria == VET){
                fprintf(yyout, "\tARZV\t%d\n", TabSimb[pos].endereco);
            }
            else if(categoria == VAR){
                fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco);
            }
        }
        else{
            erro("Tipos incompatíveis");
        }
    }
    ;

indice
    :T_ABRECOL expr T_FECHACOL{
        int tipoexpr = desempilha(); //desempilha o tipo da expressão;
        //a expressao desempilhada / atomo -> se o tipo da expressão == 'inteiro' 
        //verificar tipo do atomo/expr se o tipo for inteiro -> 
        // if(tipoexpr == 'i'){
        //     if(index >= 0 && index < TabSimb[pos].tamanho){
        //         empilha(VET);
        //         empilha(TabSimb[pos].endereco + index);
        //     }
        //     else
        //         erro("Indice invalido");
        // }
        // else
        //     erro("Tipo incompatível");
        if(tipoexpr == 'l'){
            erro("Tipo incompatível");
        }            
        empilha(VET);
    }
    |{
        empilha(VAR);
    }
    ;

expr
    : expr T_VEZES expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('i');
        fprintf(yyout, "\tMULT\n");
    }
    | expr T_DIV expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('i');
        fprintf(yyout, "\tDIVI\n");
    }
    | expr T_MAIS expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('i');
        fprintf(yyout, "\tSOMA\n");
    }
    | expr T_MENOS expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('i');
        fprintf(yyout, "\tSUBT\n");
    }
    | expr T_MAIOR expr {
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('l');
        fprintf(yyout, "\tCMMA\n");
    }
    | expr T_MENOR expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('l');
        fprintf(yyout, "\tCMME\n");
    }
    | expr T_IGUAL expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'i' || t2 != 'i'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('l');
        fprintf(yyout, "\tCMIG\n");
    }
    | expr T_E expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'l' || t2 != 'l'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('l');
        fprintf(yyout, "\tCONJ\n");
    }
    | expr T_OU expr{
        int t1 = desempilha();
        int t2 = desempilha();
        if (t1 != 'l' || t2 != 'l'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('l');
        fprintf(yyout, "\tDISJ\n");
    }
    | termo
    ;

termo
    : T_IDENTIF{
        int pos = busca_simbolo(atomo);
        if (pos == -1){
            erro("Variável não declarada");
        }
        empilha(TabSimb[pos].tipo);
        empilha(pos);
    } indice { 
        int categoria = desempilha();
        int pos = desempilha();
        if(categoria == VET){
            fprintf(yyout, "\tCRVV\t%d\n", TabSimb[pos].endereco);
        }
        else if(categoria == VAR){
            fprintf(yyout, "\tCRVG\t%d\n", TabSimb[pos].endereco);    
        }
    }
    | T_NUMERO{
        fprintf(yyout, "\tCRCT\t%s\n", atomo);
        empilha('i');
    }
    | T_V{
        fprintf(yyout, "\tCRCT\t1\n");
        empilha('l');
    }
    | T_F{
        fprintf(yyout, "\tCRCT\t0\n");
        empilha('l');
    }
    | T_NAO termo{
        char t = desempilha();
        if (t != 'l'){
            erro ("Incompatibilidade de tipos!");
        }
        empilha('l');
        fprintf(yyout, "\tNEGA\n");
    }
    | T_ABRE expr T_FECHA{
        //desempilha();
    }
    ;

%%

void erro (char *s) {
    printf("ERRO na linha %d: %s\n", numLinha, s);
    exit(10);
}

int yyerror(char *s) {
    erro(s);
}

int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) { 
        puts("\nCompilador Simples!");
        puts("    USO: ./simples <nomefonte>[.simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples");
    if (p)
        *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");

    yyin = fopen (nameIn, "rt");
    if(!yyin){ 
        puts("Programa fonte nao encontrado!");
        exit(10);
    }

    yyout = fopen(nameOut, "wt");

    if(!yyparse())
        puts ("Programa ok!");
}