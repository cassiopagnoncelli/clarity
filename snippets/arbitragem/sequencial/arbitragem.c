/*
  Arbitragem

  

  --
  Cássio Jandir Pagnoncelli, Gabriel Augusto Sobral
  {cjp07,gags07}@inf.ufpr.br
*/
#include <stdio.h>
#include <stdlib.h>

/*------------------------------------------------------------------------------
 --- Estruturas. ---------------------------------------------------------------
 -----------------------------------------------------------------------------*/
/*
  Caminho no grafo com seu respectivo custo.
*/
typedef struct caminho_t {
  unsigned int *C, tamanho, capacidade;
  double custo;
} caminho;

/*
  Tabela de menores caminhos entre cada par de vértices distintos.
*/
#define TBL_DIM 20
typedef struct {
  caminho *tabela[TBL_DIM][TBL_DIM];
  unsigned int dimensao;
} tbl_t;

tbl_t tbl;

/*
  Estrutura de um conjunto de inteiros não negativos
*/
typedef struct conjunto_t {
  unsigned int *C;
  unsigned int tamanho, capacidade;
} conjunto;
/*------------------------------------------------------------------------------
 --- Mensagem de erro. ---------------------------------------------------------
 -----------------------------------------------------------------------------*/
int
erro(const char *str)
{
  fprintf(stderr, "%s.\n", str);
  return EXIT_FAILURE;
}
/*------------------------------------------------------------------------------
 --- Caminho. ------------------------------------------------------------------
 -----------------------------------------------------------------------------*/
/* Capacidade inicial do conjunto. Busque definir um valor de modo que
   `struct conjunto_t' seja uma potência de 2. */
#define CONJUNTO_TAM_INICIAL 14

conjunto *
conjunto_constroi()
{
  conjunto *C = malloc(sizeof(conjunto));
  if (!C)
    return NULL;

  C->capacidade = CONJUNTO_TAM_INICIAL;
  C->C = malloc(C->capacidade * sizeof(unsigned int));
  if (!C->C)
    return NULL;

  C->tamanho = 0;

  return C;
}

void
conjunto_destroi(conjunto *C)
{
  if (!C)
    return;

  if (C->C)
    free(C->C);

  free(C);
}

int
conjunto_busca(conjunto *C, unsigned int x)
{
  if (!C || !C->C || C->tamanho == 0 || C->capacidade == 0)
    return -1;

  if (C->C[C->tamanho - 1] == x)
    return ((int) C->tamanho) - 1;

  unsigned int i;
  for (i = 0; i < C->tamanho; i++)
    if (C->C[i] == x)
      return (int) i;

  return -1;
}

conjunto *
conjunto_adiciona(conjunto *C, unsigned int x)
{
  if (!C)
    return NULL;

  if (C->tamanho == C->capacidade) {
    C->capacidade = 4 * (C->capacidade + 2) - 2;
    C->C = realloc(C->C, C->capacidade * sizeof(unsigned int));
    if (!C->C)
      return NULL;
  }

  C->C[C->tamanho] = x;
  C->tamanho++;

  return C;
}

conjunto *
conjunto_remove(conjunto *C, unsigned int x)
{
  int lugar = conjunto_busca(C, x);
  if (lugar == -1)
    return C;

  int i;
  for (i = lugar; i < ((int)C->tamanho) - 1; i++)
    C->C[i] = C->C[i + 1];

  C->tamanho--;

  return C;
}

/*conjunto *conjunto_clone(conjunto *c)
{
  conjunto *clone = malloc(sizeof(conjunto));
  if (!clone)
    return NULL;

  clone->capacidade = c->capacidade;
  clone->tamanho = c->tamanho;
  clone->C = malloc(clone->capacidade * sizeof(unsigned int));
  if (!clone->C)
    return NULL;

  unsigned int i;
  for (i = 0; i < clone->tamanho; i++)
    clone->C[i] = c->C[i];

  return clone;
  }*/

void conjunto_imprime(conjunto *C)
{
  if (!C) return;

  unsigned int i;
  printf("{");
  for (i = 0; i < C->tamanho-1; i++)
    printf("%u,", C->C[i]);

  if (C->tamanho > 0)
    printf("%u", C->C[C->tamanho-1]);

  printf("}\n");
}
/*------------------------------------------------------------------------------
 --- Grafo. --------------------------------------------------------------------
 -----------------------------------------------------------------------------*/
/*
  Iremos manipular um único grafo e o usaremos em todas as funções, então
  vamos definir o grafo em um contexto global.
*/
conjunto *VERTICES;
double **ARESTAS;

#define CAMINHO_CAPACIDADE_INICIAL 12 /* padding para potência de 2 */
#define INF 1000000.0

int grafo_constroi(unsigned int n)
{
  /* constrói o conjunto de vértices. */
  VERTICES = conjunto_constroi();
  if (!VERTICES)
    return 0;

  unsigned int i;
  for (i = 1; i <= n; i++)
    if (!(VERTICES = conjunto_adiciona(VERTICES, i)))
      return 0;

  /* constrói o conjunto de arestas. */
  ARESTAS = malloc((n+1) * sizeof(double *));
  if (!ARESTAS)
    return 0;

  for (i = 1; i <= n; i++)
    ARESTAS[i] = malloc((n+1) * sizeof(double));

  return 1;
}

void grafo_destroi()
{
  /* destrói o conjunto de vértices */
  unsigned int tam = VERTICES->C[VERTICES->tamanho - 1];
  conjunto_destroi(VERTICES);

  /* destrói o conjunto de arestas */
  unsigned int i;
  for (i = 1; i <= tam; i++)
    free(ARESTAS[i]);

  free(ARESTAS);
}

double peso(unsigned int src, unsigned int dst)
{
  return (double) ARESTAS[src][dst];
}

/*
   Caminho.
*/
caminho *caminho_novo(unsigned int v)
{
  caminho *c = malloc(sizeof(caminho));
  if (!c) 
    return NULL;

  c->capacidade = CAMINHO_CAPACIDADE_INICIAL;
  c->C = malloc(c->capacidade * sizeof(unsigned int));
  if (!c->C)
    return NULL;

  c->C[0] = v;
  c->tamanho = 1;
  c->custo = (double) 1.0;
  
  return c;
}

caminho *caminho_excluir(caminho *c)
{
  if (!c)
    return NULL;

  if (c->C)
    free(c->C);

  return c;
}

/*caminho *caminho_clone(caminho *c)
{
  caminho *clone = malloc(sizeof(caminho));
  if (!clone)
    return NULL;

  clone->capacidade = c->capacidade;
  clone->tamanho = c->tamanho;
  clone->custo = (double) c->custo;
  
  clone->C = malloc(clone->capacidade * sizeof(unsigned int));
  if (!clone->C)
    return NULL;

  unsigned int i;
  for (i = 0; i < clone->tamanho; i++)
    clone->C[i] = c->C[i];

  return clone;
  }*/

/*int
caminho_copia(caminho dst, caminho *src)
{
  dst.capacidade = (*src).capacidade;
  dst.tamanho = (*src).tamanho;
  dst.custo = (*src).custo;
  
  dst.C = malloc(dst.capacidade * sizeof(unsigned int));
  if (!dst.C)
    return 0;

  unsigned int i;
  for (i = 0; i < dst.tamanho; i++)
    dst.C[i] = src->C[i];

  return 1;
  }*/

caminho *caminho_adiciona(caminho *c, unsigned int fim)
{
  if (!c || !c->C)
    return NULL;

  if (c->tamanho == c->capacidade) {
    printf("aumentando um caminho...\n");
    /* dobra a capacidade conservando o padding */
    c->capacidade = 2 * (c->capacidade + 4) - 4;
    c->C = realloc(c->C, c->capacidade * sizeof(unsigned int));
    if (!c->C)
      return NULL;
  }

  c->C[c->tamanho] = fim;
  c->custo = (double) c->custo * peso(c->C[c->tamanho - 1], fim);
  c->tamanho++;

  return c;
}

/*
   Manipulação da tabela de menores caminhos.
*/
int menor_caminho_inicializa(unsigned int n)
{
  if (n+1 > TBL_DIM)
    return 0;

  tbl.dimensao = n+1;
  
  unsigned int i, j;
  for (i = 1; i <= n; i++)
    for (j = 1; j <= n; j++)
      tbl.tabela[i][j] = NULL;
  
  return 1;
}

double custo_global_get(unsigned int src, unsigned int dst)
{
  if (tbl.tabela[src][dst])
    return (double) tbl.tabela[src][dst]->custo;

  return (double) INF;
}

caminho *menor_caminho_get(unsigned int src, unsigned int dst)
{
  return tbl.tabela[src][dst];
}

void imprime_menor_caminho(unsigned int src, unsigned int dst)
{
  printf("src=%u dst=%u [length=%u]: ", src, dst, tbl.tabela[src][dst]->tamanho);
  
  if (tbl.tabela[src][dst]) {
    unsigned int i;
    for (i = 0; i < tbl.tabela[src][dst]->tamanho; i++)
      printf("%u ", tbl.tabela[src][dst]->C[i]);
    for (; i < tbl.dimensao; i++)
      printf("  ");
    printf("\tcost=%lf", tbl.tabela[src][dst]->custo);
  } else
    printf("<sem menor caminho>");

  printf("\n");

  if (custo_global_get(src, dst) > ARESTAS[src][dst])
    printf("caminho caro: [global] %lf > %lf [aresta]\n",
	   custo_global_get(src,dst), ARESTAS[src][dst]);
}

void imprime_tudo()
{
  unsigned int i, j;
#if (IMPR_TBL == 1)
  printf("Adjacency matrix:\n");
  for (i = 1; i <= VERTICES->tamanho; i++) {
    for (j = 1; j <= VERTICES->tamanho; j++)
      if (i != j)
	printf("%.8lf\t", ARESTAS[i][j]);
      else
	printf("   inf    \t");

    printf("\n");
    }
#endif
  
  for (i = 1; i < tbl.dimensao; i++)
    for (j = 1; j < tbl.dimensao; j++)
      if (i != j)
	imprime_menor_caminho(i, j);
}

/*
   Carregra grafo.
*/
int carrega_grafo(const char *arquivo)
{
  FILE *fp = fopen(arquivo, "r");
  if (!fp)
    return 1;

  unsigned int n;
  if (fscanf(fp, "%u", &n) < 0)
    return erro("Não consegui ler a dimensão da matriz");

  /* constrói o grafo montando os conjuntos de vértices e arestas */
  if (!grafo_constroi(n))
    return erro("Não consegui montar o grafo (V, G)");

  /* constrói a tabela de menores caminhos entre cada par de vértices */
  if (!menor_caminho_inicializa(n))
    return erro("Não consegui inicializar atabela de menores caminhos");

  /* lê o arquivo */
  unsigned int i, j;
  for (i = 1; i <= n; i++)
    for (j = 1; j <= n; j++)
      if (i != j) {
	if (fscanf(fp, "%lf", &ARESTAS[i][j]) < 0)
	  return erro("Formato do arquivo inesperado");
      } else
	ARESTAS[i][j] = INF;
  
  fclose(fp);

  return 0;
}
/*------------------------------------------------------------------------------
 --- Busca. --------------------------------------------------------------------
 -----------------------------------------------------------------------------*/
void troca(unsigned int *a, unsigned int *b)
{
  if (!a || !b) return;
  unsigned int tmp = *a;
  *a = *b;
  *b = tmp;
}

/*
  Objetivo do backtracking.
  Devolve: 1, se foi executada corretamente;
           0, se algum erro ocorreu (deve abortar o bactracking).
*/
int objetivo(unsigned int restricao)
{
  if (restricao < 2 || restricao > VERTICES->tamanho)
    return 1;

  double custo = 1;
  unsigned int i;
  for (i = 0; i < restricao-1; i++)
    custo = (double) (custo * peso(VERTICES->C[i], VERTICES->C[i + 1]));

  unsigned int
    src = VERTICES->C[0],
    dst = VERTICES->C[restricao - 1];

  if (custo < custo_global_get(src, dst)) {
    caminho *c = caminho_novo(src);
    unsigned int j;
    for (j = 1; j < restricao; j++)
      c = caminho_adiciona(c, VERTICES->C[j]);

    free(tbl.tabela[src][dst]);
    tbl.tabela[src][dst] = c;
  }

  return 1;
}

/*
  Algoritmo Backtracking.
  
  1.
  2.   Candidatos <- {1, 2, ..., n}
  3.   for i in Candidatos
  4.      Candidatos <- Candidatos \ {i}
  5.      backtrack(Candidatos)
  6.      Candidatos <- Candidatos U {i}
*/
int backtracking(unsigned int inicio)
{
  if (!objetivo(inicio))
    return 0;
  
  unsigned int i;  
  for (i = inicio; i < VERTICES->tamanho; i++)
    {
      troca(&VERTICES->C[i], &VERTICES->C[inicio]);
      
      if (!backtracking(inicio + 1))
	return 0;

      troca(&VERTICES->C[i], &VERTICES->C[inicio]);
    }

  return 1;
}
/*------------------------------------------------------------------------------
 --- Principal. ----------------------------------------------------------------
 -----------------------------------------------------------------------------*/
int
main(int argc, char **argv)
{
  if (argc != 2)
    return erro("Especifique o nome do arquivo");

  if (carrega_grafo(argv[1]) != 0)
    return erro("Erro ao construir o grafo");
  
  if (!backtracking(0))
    return erro("Não consegui fazer backtracking");
  
  imprime_tudo();
  
  return EXIT_SUCCESS;
}
