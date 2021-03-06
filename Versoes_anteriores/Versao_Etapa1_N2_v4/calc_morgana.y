%{
    //Codigo C
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <math.h>
    #include <ctype.h>
    #include<stdbool.h>
    extern int yylineno;
    
    int yylex();
    void yyerror(const char *str)
    {
        fprintf(stderr,"Error: %s\n Linha: %d\n", str, yylineno);
    }

    #define name_size 50
    #define string_size 1000

    // Construção de uma struct para receber o nome e o valor para cada variavel do tipo real
    typedef struct vars {
        int nodetype;
		char name[name_size];
		float v;
        double *vet; /* variavel para vetor */
		struct vars * prox;
	} VARS;

    // Adicionar nova variavel do tipo real na lista
    VARS * ins(VARS *l, char n[]){
		VARS *new =(VARS*)malloc(sizeof(VARS));
		strcpy(new->name, n);
		new->prox = l;
		return new;
	}

    // Insercao do tipo REAL dentro do Array
    VARS *ins_a(VARS*l,char n[], int tamanho){
		VARS*new =(VARS*)malloc(sizeof(VARS));
		strcpy(new->name,n);
		new->vet = (double*)malloc(tamanho * sizeof(double));
		new->prox = l;
		new->nodetype = 3; 
		return new;
	}

    // Insercao da variavel do tipo STRING dentro do Array
    // Insercao da variavel do tipo INT dentro do Array
    
    // Busca uma variável do tipo real na lista de variáveis
	VARS *srch(VARS *l, char n[]){
		VARS *aux = l;
		while(aux != NULL){
			if(strcmp(n, aux->name)==0){
				return aux;
			}
			aux = aux->prox;
		}
		return aux;
	}
    
    // Verificar se o valor dado é real
    bool is_real(char test[]){
        int i = 0;
        int ponto = 0;
        do{
            if(isdigit(test[i])!=0 || test[i] == '.'){
                if(test[i]=='.')
                    ponto = ponto + 1;
                if(ponto>1)
                    return false;
                i=i+1;
            }
            else
                return false;
        }while(test[i]!='\0');
        
        return true;
    }

    // Construção de uma struct para receber o nome e o valor para cada variavel do tipo string
    typedef struct VARST {
		char name[name_size];
		char v[string_size];
		struct VARST * prox;
	} VARST;

    // Adicionar nova variável do tipo string na lista 
    VARST * inst(VARST *l, char n[]){
		VARST *new =(VARST*)malloc(sizeof(VARST));
		strcpy(new->name, n);
        strcpy(new->v, "");
		new->prox = l;
		return new;
	}

    // Busca uma nova variável do tipo string na lista de variáveis
    VARST *srcht(VARST *l, char n[]){
		VARST *aux = l;
		while(aux != NULL){
			if(strcmp(n,aux->name)==0){
				return aux;
			}
			aux = aux->prox;
		}
		return aux;
	}

    // Construção de uma struct para receber o nome e o valor para cada variavel do tipo inteiro
    typedef struct varsi {
		char name[name_size];
		int v;
		struct varsi * prox;
	} VARSI;

    // Adicionar nova variavel inteiro na lista de variáveis inteiro
    VARSI * insi(VARSI *l, char n[]){
		VARSI *new =(VARSI*)malloc(sizeof(VARSI));
		strcpy(new->name, n);
		new->prox = l;
		return new;
	}

    // Busca uma variável inteiro na lista de variáveis inteiro
	VARSI *srchi(VARSI *l, char n[]){
		VARSI *aux = l;
		while(aux != NULL){
			if(strcmp(n, aux->name)==0){
				return aux;
			}
			aux = aux->prox;
		}
		return aux;
	}

    // Verificar se o valor dado é inteiro
    bool is_int(char test[]){
        int i = 0;
        int ponto = 0;
        do{
            if(isdigit(test[i])!=0){
                i=i+1;
            }
            else
                return false;
        }while(test[i]!='\0');
        
        return true;
    }

	VARS *rvar = NULL; 
    VARSI *ivar = NULL;
    VARST *tvar = NULL;

    /* O nodetype serve para indicar o tipo de nó que está na árvore. Isso serve para a função eval entender o que realizar naquele no */
    typedef struct ast { /*Estrutura de um nó*/
        int nodetype;
        struct ast *l; /*Esquerda*/
        struct ast *r; /*Direita*/
    }Ast; 

    typedef struct intval { /*Estrutura de um número*/
        int nodetype;
        int v;
    }Intval;

    typedef struct realval { /* Estrutura de um número */
        int nodetype;
        double v;
    }Realval;

    typedef struct textoval { /*Estrutura de um número*/
        int nodetype;
        char v[string_size];
    }Textoval;

    typedef struct varval { /*Estrutura de um nome de variável, nesse exemplo uma variável é um número no vetor var[26]*/
        int nodetype;
        char var[name_size];
        int size;
        Ast *length;
    }Varval;

    typedef struct flow { /*Estrutura de um desvio (if/else/while)*/
	    int nodetype;
	    Ast *cond;		/*condição*/
	    Ast *tl;		/*then, ou seja, verdade*/
	    Ast *el;		/*else*/
    }Flow;

    /*Estrutura para um nó de atribuição. Para atrubuir o valor de v em s*/
    typedef struct symasgn { 
        int nodetype;
        char s[name_size];
        Ast *v;
        Ast *n;
        int pos;
        Ast *indice; /* ponteiro para referenciar o indice(posicao) no Array */
    }Symasgn;

    /*Função para criar um nó*/
    Ast * newast(int nodetype, Ast *l, Ast *r){ 

	    Ast *a = (Ast*) malloc(sizeof(Ast));
	    if(!a) {
		    printf("out of space");
		    exit(0);
	}
	    a->nodetype = nodetype;
	    a->l = l;
	    a->r = r;
	    return a;
    }

    /*Função para criar um nó para operador iterator*/
    Ast * newastiterate(int nodetype, Ast *l, Ast *r){ 
         Ast *a = (Ast*) malloc(sizeof(Ast));
	    if(!a) {
		    printf("out of space");
		    exit(0);
	}
	    a->nodetype = nodetype;
	    a->l = l;
	    a->r = r;
	    return a;
    }

    /*Estrutura de um fluxo para o FOR*/
    typedef struct flowfor{ 
        int nodetype;
        Ast* v1;
        Ast* v2;
        Ast* v3;
    }Flowfor;

    /*Função que cria um nó de FOR*/
    Ast * newflowfor(int nodetype, Ast *b1, Ast *b2, Ast *b3, Ast *tl, Ast *el){ 
        Flow *a = (Flow*)malloc(sizeof(Flow));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        Flowfor *b = (Flowfor*)malloc(sizeof(Flowfor));
        if(!b) {
            printf("out of space");
            exit(0);
        }
        b->nodetype = 'F';
        b->v1 = b1;
        b->v2 = b2;
        b->v3 = b3;
        a->nodetype = nodetype;
        a->cond = (Ast*)b;
        a->tl = tl;
        a->el = el;
        return (Ast *)a;
    }

    /* Função de que cria um número inteiro (folha)*/
    Ast * newint(int d) {	
        Intval *a = (Intval*) malloc(sizeof(Intval));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        a->nodetype = 'k';
        a->v = d;
        return (Ast*)a;
    }


    /*Função de que cria um número real (folha)*/
    Ast * newreal(double d) {		
        Realval *a = (Realval*) malloc(sizeof(Realval));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        a->nodetype = 'K';
        a->v = d;
        return (Ast*)a;
    }

    /*Função de que cria um novo texto (folha)*/
    Ast * newtexto(char d[]) {			
        Textoval *a = (Textoval*) malloc(sizeof(Textoval));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        a->nodetype = 'm';
        strcpy(a->v, d);
        return (Ast*)a;
    }

    /*Função que cria um nó de if/else/while*/
    Ast * newflow(int nodetype, Ast *cond, Ast *tl, Ast *el){ 
        Flow *a = (Flow*)malloc(sizeof(Flow));
        if(!a) {
            printf("out of space");
        exit(0);
        }
        a->nodetype = nodetype;
        a->cond = cond;
        a->tl = tl;
        a->el = el;
        return (Ast *)a;
    }

    /*Função que cria um nó para testes lógicos*/
    Ast * newcmp(int cmptype, Ast *l, Ast *r){
        Ast *a = (Ast*)malloc(sizeof(Ast));
        if(!a) {
            printf("out of space");
        exit(0);
        }
        a->nodetype = '0' + cmptype; /*Para pegar o tipe de teste, definido no arquivo.l e utilizar na função eval()*/
        a->l = l;
        a->r = r;
        return a;
    }

    /* Funcão que cria um nó para a variavel do tipo inteiro ou real ou texto e atribui o valor */
    Ast * newvar(int t, char s[], Ast *v, Ast *n){
        Symasgn *a = (Symasgn*)malloc(sizeof(Symasgn));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        a->nodetype = t; /*tipo i, r ou t, conforme arquivo .l*/
        strcpy(a->s, s); /*Símbolo/variável*/
        a->v = v; /*Valor*/
        a->n = n; /*proxima declaração*/
        return (Ast *)a;
    }

    /* Funcão que cria um nó para a variavel do tipo Array */
    Ast * newarray(int nodetype, char nome[50], int tam) {			
        Varval *a = (Varval*) malloc(sizeof(Varval));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        a->nodetype = nodetype;
        strcpy(a->var,nome);
        a->size = tam;
        return (Ast*)a;
        // a->length = tam;
    }

    /*Função para um nó de atribuição*/
    Ast * newasgn(char s[], Ast *v) { 
        Symasgn *a = (Symasgn*)malloc(sizeof(Symasgn));
        if(!a) {
            printf("out of space");
        exit(0);
        }
        a->nodetype = '=';
        strcpy(a->s, s); /*Símbolo/variável*/
        a->v = v; /*Valor*/
        return (Ast *)a;
    }

    /*Função para um nó de atribuição de um numero a uma posicao do Array*/
    /*Ex: vet[2] = 10*/
    Ast * newasgn_a(char s[50], Ast *v, int indice) { 
	    Symasgn *a = (Symasgn*)malloc(sizeof(Symasgn));
        if(!a) {
            printf("out of space");
        exit(0);
        }
        a->nodetype = '=';
        strcpy(a->s,s);
        a->v = v; /*Valor*/
        a->pos = indice; /* recebe o indice para atribuir o valor a esta posicao */
        return (Ast *)a;
    }

    /*Função que recupera o nome/referência de uma variável, neste caso o número*/
    Ast * newValorVal(char s[]) { 
        Varval *a = (Varval*) malloc(sizeof(Varval));
        if(!a) {
            printf("out of space");
            exit(0);
        }
        a->nodetype = 'N';
        strcpy(a->var, s);
        return (Ast*)a;
        
    }

    /*Função que recupera a variavel vet[indice===tam] do Array*/
    Ast *newValorVal_a(char s[], int indice)
    {
        Varval *a = (Varval *)malloc(sizeof(Varval));
        if (!a)
        {
            printf("out of space");
            exit(0);
        }
        a->nodetype = 'a';
        strcpy(a->var, s);
        a->size = indice;

        return (Ast *)a;
    }

    /* Verificar se a variavel existe na lista de variaveis */
    bool varexiste(char v[]) {
        VARS* xr = srch(rvar, v);
        VARSI* xi = srchi(ivar, v);
        VARST* xt = srcht(tvar, v);

    if(!xr && !xi && !xt) 
        return false; // se tudo NULL, var nao existe
    else
        return true;  // se tudo for TRUE, var existe
    }

    /*Função que executa operações a partir de um nó*/
    double eval(Ast *a) { 
        double v;
        char v1[50];
        double value;
        /*VARS *aux;*/

        if(!a) {
            printf("internal error, null eval\n");
            return 0.0;
        }
        //printf("nodetype: %c\n", a->nodetype);
        switch(a->nodetype) {
            case 'k': v = ((Intval *)a)->v; break; 	/*Recupera um número inteiro*/
            case 'K': v = ((Realval *)a)->v; break; 	/*Recupera um número real*/
            case 'm': v = atof(((Textoval *)a)->v); break; 	/*Recupera um número real dentro de string*/
            case 'N':; /*  Verificar se foi realizado a declaracao da variavel corretamente */
                VARS * aux = (VARS*)malloc(sizeof(VARS));
                aux = srch(rvar, ((Varval*)a)->var);
                if (!aux){
                    VARSI * aux2 = (VARSI*)malloc(sizeof(VARSI));
                    aux2 = srchi(ivar, ((Varval*)a)->var);
                    if (!aux2){
                        VARST * aux3 = (VARST*)malloc(sizeof(VARST));
                        if(!aux3){
                                printf("out of space");
                                exit(0);
                            }
                        aux3 = srcht(tvar, ((Varval*)a)->var);
                        if (!aux3){
                            printf ("Erro 'sem valor'. Variavel '%s' nao foi declarada.\n", ((Varval*)a)->var);
                            v = 0.0;
                        }
                        else{
                            v = atof(aux3->v);
                        }
                    }
                    else{
                        v = (double)aux2->v;
                    }
                }
                else{
                    v = aux->v;
                }
                break;
            case 'a':; /* vet [10] = 20 */
                VARST * xct = (VARST*)malloc(sizeof(VARST));
                xct = srcht(tvar, ((Varval *)a->l)->var);
                v = aux->vet[((Varval *)a)->size];

                aux1 = srch(l1, ((Varval *)a)->var);
                v = aux1->vet[(Varval *a)->size];
                break;
            // ----------------------------------------------------------------- // 
            case 'p':
                value = eval(a->l); /*Recupera um valor STRING*/
                printf("%.2lf", value);
                break;    

            case 'v':; /* buscar a variavel STRING no Array */
                aux = srch(rvar, ((Varval*)a)->var);
                value = eval(((Varval *)a)->length);
                v = aux->vet[(int)value];
                break;
    
            case 'V':; /* vetor */
                rvar = ins(rvar,((Varval*)a)->var);
				break;

            case 'A':;	/* vetor */
                VARST * xct = (VARST*)malloc(sizeof(VARST));
                xct = srcht(tvar, ((Varval*)a)->var);
				// rvar = ins_a(rvar,((Varval*)a)->var,((Varval*)a)->size);
                if (aux == NULL)
                {
                    // value = eval(((Varval *)a)->length);
                    tvar = ins_a(tvar, ((Varval *)a)->var, ((Varval*)a)->size);
                }
                else
                {
                    printf("Redeclaração de variável: %s\n", ((Varval *)a)->var);
                    exit(0);
                }
                break;
            // ----------------------------------------------------------------- //
            case '+': v = eval(a->l) + eval(a->r); break;	/*Operações "árv esq   +   árv dir"*/
            case '-': v = eval(a->l) - eval(a->r); break;	/*Operações de subtração */
            case '*': v = eval(a->l) * eval(a->r); break;	/*Operações de multiplicação */
            case '/': v = eval(a->l) / eval(a->r); break; /*Operação de divisão */
            case 'R': v = sqrt(eval(a->l)); break;				/*Operações RAIZ*/
            case 'M': v = -eval(a->l); break;				/*Operações, número negativo*/
            case '|': v = fabs(eval(a->l)); break;          /*Operações de módulo*/

            case '1': v = (eval(a->l) > eval(a->r))? 1 : 0; break;	/* Operações lógicas. "árv esq   >   árv dir"  Se verdade 1, falso 0 */
            case '2': v = (eval(a->l) < eval(a->r))? 1 : 0; break;
            case '3': v = (eval(a->l) != eval(a->r))? 1 : 0; break;
            case '4': v = (eval(a->l) == eval(a->r))? 1 : 0; break;
            case '5': v = (eval(a->l) >= eval(a->r))? 1 : 0; break;
            case '6': v = (eval(a->l) <= eval(a->r))? 1 : 0; break;
            case '7': v = (eval(a->l) || eval(a->r))? 1 : 0; break;
            case '8': v = (eval(a->l) && eval(a->r))? 1 : 0; break;
            case '?': (eval(((Flow *)a)->cond)) != 0 ? eval(((Flow *)a)->tl) : eval(((Flow *)a)->el); break; /* Case para operador iterator */
            
            /* Atribuicao */
            case '=':; 
                v = eval(((Symasgn *)a)->v); /*Recupera o valor*/
                
                VARS * x = (VARS*)malloc(sizeof(VARS));
                if(!x) {
                    printf("out of space");
                    exit(0);
                }
                x = srch(rvar, ((Symasgn *)a)->s);
                if(!x){
                    VARSI * xi = (VARSI*)malloc(sizeof(VARSI));
                    if(!xi) {
                        printf("out of space");
                        exit(0);
                    }
                    xi = srchi(ivar, ((Symasgn *)a)->s);
                    if(!xi){
                        printf("Erro 'atribuir valor'. Var '%s' nao declarada.\n", ((Symasgn *)a)->s);
                    } else
                        xi->v = (int)v; /*Atribui à variável do tipo */
                } else {
                        x->v = v; /*Atribui à variável*/
                    }
                }
                break;

            /* caso if ou if/else */
            case 'I': 
                if (eval(((Flow *)a)->cond) != 0) {	/*executa a condição / teste*/
                    if (((Flow *)a)->tl)		/*Se existir árvore*/
                        v = eval(((Flow *)a)->tl); /*Verdade*/
                    else
                        v = 0.0;
                } else {
                    if( ((Flow *)a)->el) {
                        v = eval(((Flow *)a)->el); /*Falso*/
                    } else
                        v = 0.0;
                    }
                break;

            /* caso while */
            case 'W':
                v = 0.0;
                if( ((Flow *)a)->tl) {
                    while( eval(((Flow *)a)->cond) != 0){
                        v = eval(((Flow *)a)->tl);
                        }
                }
            break;

            // leitura das variaveis: int, real e texto
            case 'c':; 
                //v = eval(((Symasgn *)a)->v); /*Recupera o valor*/
                VARS * xcr = (VARS*)malloc(sizeof(VARS));
                if(!xcr) {
                    printf("out of space");
                    exit(0);
                }
                xcr = srch(rvar, ((Varval *)a->l)->var);
                if(xcr){
                    scanf("%f", &xcr->v);
                } else {
                    VARSI * xci = (VARSI*)malloc(sizeof(VARSI));
                    if(!xci) {
                        printf("out of space");
                        exit(0);
                    }
                    xci = srchi(ivar, ((Varval *)a->l)->var);
                    if(xci){
                        scanf("%d", &xci->v);
                    } else {
                        VARST * xct = (VARST*)malloc(sizeof(VARST));
                        if(!xct) {
                            printf("out of space");
                            exit(0);
                        }
                        xct = srcht(tvar, ((Varval *)a->l)->var);
                        if(xct){
                            scanf("%s", &xct->v);
                        } else {
                            printf("Variavel inválida!\n");
                        }
                    }
                }
                break;
            
            case 'L': eval(a->l); v = eval(a->r); break; /*Lista de operções em um bloco IF/ELSE/WHILE. Assim o analisador não se perde entre os blocos*/
            case 'n': 
            { /* printar os tipos de variaveis corretamente na saída */
                VARS * auxn = (VARS*)malloc(sizeof(VARS));
                auxn = srch(rvar, ((Varval*)a)->var);
                if (!auxn){
                    VARSI * auxn2 = srchi(ivar, ((Varval*)a)->var);
                    if (!auxn2){
                        VARST * auxn3 = srcht(tvar, ((Varval*)a)->var);
                        if (!auxn3){
                            printf ("359 - Variavel '%s' nao foi declarada.\n", ((Varval*)a)->var);
                            v = 0.0;
                        }
                        else{
                            Ast * auxnt = (Ast*)malloc(sizeof(Ast));
                            if(!auxnt){
                                printf("out of space");
                                exit(0);
                            }
                            printf("%s", auxn3->v);
                            /*
                            auxnt->nodetype = 'P';
                            auxnt->l = newtexto(auxn3->v);
                            auxnt->r = newast('P', NULL, NULL); // nova alteracao do escreva
                            eval(auxnt);
                            */
                            v = atof(auxn3->v);
                        }
                    }
                    else{
                        Ast * auxni = (Ast*)malloc(sizeof(Ast));
                        if(!auxni){
                            printf("out of space");
                            exit(0);
                        }
                        printf("%d", auxn2->v);
                        /*
                        auxni->nodetype = 'P';
                        auxni->l = newint(auxn2->v);
                        auxni->r = newast('P', NULL, NULL); // nova alteracao do escreva
                        eval(auxni);
                        */
                        v = (double)auxn2->v;
                    }
                }
                else{
                    Ast * auxnr = (Ast*)malloc(sizeof(Ast));
                    if(!auxnr){
                        printf("out of space");
                        exit(0);
                    }
                    printf("%.2f", auxn->v);
                    /*
                    auxnr->nodetype = 'P';
                    auxnr->l = newreal(auxn->v);
                    auxnr->r = newast('P', NULL, NULL); // nova alteracao do escreva
                    eval(auxnr);
                    */
                    v = auxn->v;
                }
                break;
            }
            case 'P': 
                //printf("P1: %c\nP2: %c\n", a->nodetype, a->l->nodetype);
                if(a->l==NULL)
                    break;
                else
                    printf("", a->l->nodetype);
                if(a->l->nodetype == 'N'){
                    a->l->nodetype = 'n';
                    v = eval(a->l);
                    //printf("\nnodetype 'N'\n");
                } else {
                    v = eval(a->l);
                    if(a->l->nodetype != 'n' && a->l->nodetype != 'k' && a->l->nodetype != 'K' && a->l->nodetype != 'm')
                        printf("%.2f", v);
                }
                if(((Intval*)a->l)->nodetype == 'k')
                    printf ("%d", ((Intval*)a->l)->v);		/*Recupera um valor inteiro*/
                else if(((Realval*)a->l)->nodetype == 'K')
                    printf ("%.2f", ((Realval*)a->l)->v);		/*Recupera um valor real*/
                else if(((Textoval*)a->l)->nodetype == 'm')
                    printf ("%s", ((Textoval*)a->l)->v);		/*Recupera um valor texto*/
                if(a->r==NULL){
                    //printf("a->r null\n");
                    printf("\n");
                }else{
                    //printf("a->r ok\n");
                    v = eval(a->r);
                }
                break;  
            /* caso para a opcao FOR */
            case 'F':
                v = 0.0;
                if( ((Flow *)a)->tl ) {
                    for(eval(((Flowfor*)((Flow *)a)->cond)->v1); 
                        eval(((Flowfor*)((Flow *)a)->cond)->v2); 
                        eval(((Flowfor*)((Flow *)a)->cond)->v3)
                        ){
                            v =  eval(((Flow *)a)->tl);
                    }
                }
                break;
            // declaracao da variavel inteira
            case 'i':;
                if(((Symasgn *)a)->n)
                    eval(((Symasgn *)a)->n);

                if(!varexiste(((Symasgn *)a)->s)){
                    ivar = insi(ivar, ((Symasgn *)a)->s);
                    VARSI * xi = (VARSI*)malloc(sizeof(VARSI));
                    if(!xi) {
                        printf("out of space");
                        exit(0);
                    }
                    xi = srchi(ivar, ((Symasgn *)a)->s);
                    if(((Symasgn *)a)->v)
                        xi->v = (int)eval(((Symasgn *)a)->v); /*Atribui à variável*/
                }else{
                    printf("Erro de redeclaracao: variavel '%s' ja existe.\n",((Symasgn *)a)->s);
                }
                break;
            // declaracao da variavel real
            case 'r':;
                if(((Symasgn *)a)->n)
                    eval(((Symasgn *)a)->n);

                if(!varexiste(((Symasgn *)a)->s)){
                    rvar = ins(rvar, ((Symasgn *)a)->s);
                    VARS * xr = (VARS*)malloc(sizeof(VARS));
                    if(!xr) {
                        printf("out of space");
                        exit(0);
                    }
                    xr = srch(rvar, ((Symasgn *)a)->s);
                    if(((Symasgn *)a)->v)
                        xr->v = eval(((Symasgn *)a)->v);
                }else
                    printf("Erro de redeclaracao: variavel '%s' ja existe.\n",((Symasgn *)a)->s);
                break;
            // declara a variavel texto
            case 't':;
                if(((Symasgn *)a)->n)
                    eval(((Symasgn *)a)->n);

                if(!varexiste(((Symasgn *)a)->s)){
                    tvar = inst(tvar, ((Symasgn *)a)->s);
                    VARST * xt = (VARST*)malloc(sizeof(VARST));
                    if(!xt) {
                        printf("out of space");
                        exit(0);
                    }
                    xt = srcht(tvar, ((Symasgn *)a)->s);
                    if((((Symasgn *)a)->v))
                        strcpy(xt->v, ((Textoval*)((Symasgn*)a)->v)->v);
                }else
                    printf("Erro de redeclaracao: variavel '%s' ja existe.\n",((Symasgn *)a)->s);
                break;
            case 'y':; 
                if(a->l) eval(a->l)
                printf('Entrou no case Y');
                break;
            case 'z':;
                printf("Fim do programa\n");
                free(ivar);
                ivar = NULL;
                free(rvar);
                rvar = NULL;
                free(tvar);
                tvar = NULL;
                exit(0);
                break;

            default: printf("internal error: bad node %c\n", a->nodetype);
        }
        return v;
    }

%}

%union {
    char texto[50];
    double real;
    int inteiro;
    int fn; /* operadores lógicos */
    Ast *ast;
}

// Declaração dos tokens - Nos terminais 
%token <real> NUM_REAL 
%token <inteiro> NUM_INT
%token <texto> VARIAVEL
%token <texto> STRING FUNC
%token <texto> PLUS LESS
%token <inteiro> TIPO_REAL TIPO_INT TIPO_TEXT 
%token IF ELSE WHILE FOR 
%token INICIO FINAL 
%token RAIZ
%token LEITURA
%token ESCREVER
%token <texto> COMENTARIO
%token <fn> CMP /* operadores lógicos */

// Declaração dos nos não-terminais
%type <ast> list begin expre valor prog stm stm1 escrever var declmult declmult2

// Declaração de precedência dos operadores
%left CMP
%left '+' '-'
%left '*' '/' 
%right '^'
%right PLUS LESS
%left ')'
%right '('


// O '|' e 'UNIMUS' não tem associatividade, ou seja, left ou right e estão na mais alta precedência
// O %nonassoc define a ordem de precedência do mais BAIXO para o mais ALTO
%nonassoc IFX VARPREC DECLPREC NEG VET


//%Iniciando as regras do analisador sintático
%%
// inicio do programa
begin: INICIO prog FINAL {eval(newast('z', NULL, NULL));} 
     ;

// inicia e execucao da arvore de derivacao
prog: stm {eval($1);}  
	| prog stm {eval($2);} 
	;

// variacoes dos codigos dessa linguagem
stm:  IF '(' expre ')' '{' list '}' %prec IFX {$$ = newflow('I', $3, $6, NULL);}
    | IF '(' expre ')' '{' list '}' ELSE '{' list '}' {$$ = newflow('I', $3, $6, $10);} 
    | WHILE '(' expre ')' '{' list '}' {$$ = newflow('W', $3, $6, NULL);}
    | VARIAVEL '=' expre %prec VARPREC {$$ = newasgn($1, $3);} // declaração e atribuição de variavel
    | VARIAVEL '=' STRING {$$ = newasgn($1, newtexto($3));} // declaração e atribuição de variavel
    | declmult { $$ = $1 ;} // derivacao para declaracao de multiplas variaveis - numero
    | declmult2 { $$ = $1 ;} // derivacao para declaracao de multiplas variaveis - texto
    | ESCREVER '(' escrever ')' {$$ = $3;} // derivacao para escrever
    | LEITURA '(' VARIAVEL ')' {$$ = newast('c', newValorVal($3), NULL);} // variacoes da leitura
    | FOR var ';' expre ';' var '{' list '}' { $$ = newflowfor('F', $2, $4, $6, $8, NULL);}
    | expre '?' stm1 ':' stm1 ';' {$$ = newflow('?', $1, $3, $5);} // operador ternario
    | VARIAVEL PLUS %prec PLUS {$$ = newasgn($1, newast('+',newValorVal($1),newint(1)));} // incremento
    | VARIAVEL LESS %prec LESS {$$ = newasgn($1, newast('-',newValorVal($1),newint(1)));} // decremento		
    | COMENTARIO {$$ = newast('P', NULL, NULL);}
    ;
//| TIPO_INT FUNC VARIAVEL '(' ')' { expre } { $$ = newast('y', $6, NULL); }
//| TIPO_REAL FUNC VARIAVEL '(' ')' { expre } { $$ = newast('y', $6, NULL); }
//| TIPO_REAL VARIAVEL '[' expre ']'{ $$ = newarray('a',$2,$4);} /* Array */
//| VARIAVEL '['NUM_REAL']' '=' expre {$$ = newasgn_a($1,$6,$3);}

// no nao-terminal exclusivo para stm2
stm1: ESCREVER '(' STRING ')' {$$ = newast('P', newtexto($3), NULL);} 
    | ESCREVER '(' expre ')' {$$ = newast('P', $3, NULL);}
    | VARIAVEL PLUS %prec PLUS {$$ = newasgn($1, newast('+',newValorVal($1),newint(1)));} // incremento
    | VARIAVEL LESS %prec LESS {$$ = newasgn($1, newast('-',newValorVal($1),newint(1)));} // decremento		
    ;

// declaracao de multiplas variaveis do tipo numero inteiro ou float
declmult:  declmult ',' VARIAVEL {$$ = newvar($1->nodetype, $3, NULL, $1);} 
    | declmult ',' VARIAVEL '=' expre {$$ = newvar($1->nodetype, $3, $5, $1);} 
    | TIPO_INT VARIAVEL {$$ = newvar($1, $2, NULL, NULL);} // declaracao de int
    | TIPO_INT VARIAVEL '=' expre {$$ = newvar($1, $2, $4, NULL);} // declaracao de int e atrib
    | TIPO_REAL VARIAVEL {$$ = newvar($1, $2, NULL, NULL);} // declaracao do real
    | TIPO_REAL VARIAVEL '=' expre {$$ = newvar($1, $2, $4, NULL);} // declaracao do real e atrib
    ;

// declaracao de multiplas variaveis do tipo texto
declmult2: declmult2 ',' VARIAVEL {$$ = newvar($1->nodetype, $3, NULL, $1);} 
    | declmult2 ',' VARIAVEL '=' STRING {$$ = newvar($1->nodetype, $3, newtexto($5), $1);} 
    | TIPO_TEXT VARIAVEL {$$ = newvar($1, $2, NULL, NULL);} 
    | TIPO_TEXT VARIAVEL '=' STRING {$$ = newvar($1, $2, newtexto($4), NULL);} // declaracao de String e a atribuicao
    ;

// nó nao-terminal para escrever variaveis de tipos distintos
escrever: expre {$$ = newast('P', $1, NULL);}
    | expre ',' escrever {$$ = newast('P', $1, $3);}
    | STRING {$$ = newast('P', newtexto($1), NULL);} 
    | STRING ',' escrever {$$ = newast('P', newtexto($1), $3);}
    ;

// estrutura para multiplas linhas de codigo para estruturas de decisão/loop
list: stm {$$ = $1;}
    | list stm { $$ = newast('L', $1, $2);}
    ;

// usado no FOR - 1º - Valor inicial e 3º - Valor incremento ou decrementado
var:  VARIAVEL '=' expre {$$ = newasgn($1, $3);}
    ;

// expreções matematicas e comparação
expre:
    RAIZ '(' expre ')' { 
        {$$ = newast('R',$3,NULL);}
    }
    | expre '+' expre {
        $$ = newast('+', $1, $3);
    }
    | expre '-' expre {
        $$ = newast('-',$1,$3);
    }
    | expre '*' expre {
        $$ = newast('*',$1,$3);
    }
    | expre '/' expre {
        $$ = newast('/',$1,$3);
    }
    | '(' expre ')' {
        $$ = $2;
    } 
    | expre '^' expre {
        $$ = newast('^',$1,$3);
    } 
    | '-' expre %prec NEG {
        $$ = newast('M',$2,NULL); 
    }
    | expre CMP expre { /* Testes condicionais */
        $$ = newcmp($2,$1,$3);
    }
    | VARIAVEL '[' expre ']' {
        $$ = newValorVal_a($1, $3);
    } 
    | valor { 
        $$ = $1; 
    }
    ; 

// valores básicos
valor: NUM_INT { $$ = newint($1);} 
    | NUM_REAL { $$ = newreal($1);} 
    | VARIAVEL {           
        $$ = newValorVal($1);  /* Funcao da chamada newValorVal retorna um tipo Ast que dps e usado em eval */
    }
    ;

%%

#include "lex.yy.c"

int main(){
    yyin=fopen("entrada_morg.txt", "r");
    
    yyparse();
    yylex();
    fclose(yyin);
    return 0;

}

int yywrap(){
    return 0;
}