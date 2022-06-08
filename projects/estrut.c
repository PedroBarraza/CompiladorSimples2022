/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
| UNIFAL - Universidade Federal de Alfenas
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho . . : Trabalho Final de Teoria de Linguagens e Compiladores
| Disciplina: Teoria de Linguagens e Compiladores
| P r o f e s s o r . : Luiz Eduardo da S i l v a
| Aluno . . . . . : Pedro Paschoalotti Barraza
| Data . . . . . . : 03/04/2022
+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/

#define TAM_TAB 100
#define TAM_PIL 100

// Pilha Semântica
int Pilha[TAM_PIL];
int topo = -1;

typedef enum{
    VET = 1,
    VAR = 2
} Cat;

// Tabela de Símbolos
struct elem_tab_simbolos{
    char id[30];
    int endereco;
    char tipo;
    Cat categoria;
    int tamanho;
} TabSimb[TAM_TAB], elem_tab;
int pos_tab;

// Rotina de Pilha Semântica
void empilha(int valor){
    if (topo == TAM_PIL){
        erro("Pilha cheia!");
    }
    Pilha[++topo] = valor;
}

int desempilha(){
    if (topo == -1){
        erro("Pilha Vazia!");
    }
    return Pilha[topo--];
}

// Rotinas da Tabela de Símbolos
int busca_simbolo(char *id){
    int i = pos_tab - 1;
    for (; strcmp(TabSimb[i].id, id) && i >= 0; i--);
    return i;
}

void insere_simbolo(struct elem_tab_simbolos elem){
    int i;
    if (pos_tab == TAM_TAB){
        erro("Tabela de Símbolos cheia!");
    }
    i = busca_simbolo(elem.id);
    if (i != -1){
        erro("Identificador duplicado");
    }
    TabSimb[pos_tab++] = elem;
}

int valor_log(int valor){

}

void mostra_tabela(){
    int i;
    puts("Tabela de Simbolos");
    printf("\n%5s|%5s|%5s|%5s|%5s|%5s \n", "#", "ID", "END", "TIP", "CAT", "TAM");
    for (i = 0; i < 50; i++){
        printf("-");
    }
    for (i = 0; i < pos_tab; i++){
        printf("\n%5d|%5s|%5d|%5c|%5d|%5d\n", i, TabSimb[i].id, TabSimb[i].endereco, TabSimb[i].tipo, TabSimb[i].categoria, TabSimb[i].tamanho);
    }
    puts("\n");
}