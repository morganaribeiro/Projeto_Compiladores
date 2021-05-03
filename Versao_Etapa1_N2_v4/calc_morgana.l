%option yylineno
%{
    
%}

/*TIPOS DAS VARIAVEIS */
/*TIPO_REAL "real" */
/*TIPO_INT "inteiro"*/
/*TIPO_TEXT "texto"*/

LETRA [a-zA-Z]+
NUM_INT [0-9]+
NUM_REAL [0-9]*"."[0-9]+
STRING \".*\"
RAIZ "raiz"

/* DECLARACAO DA VARIAVEL */
VARIAVEL {LETRA}({LETRA}|{NUM_INT}|"-"|"_")*

/* DECLARACAO DO COMENTARIO */
COMENTARIO "@@".*

/* FORMATO DE ATRIBUIR UMA VARIAVEL OU VALOR */
/* ATRIB "=" */

/* CONDICIONAL E REPETIÇÃO */
IF "IF"
ELSE "ELSE" 
WHILE "WHILE"
FOR "FOR"

/* LEITURA E ESCRITA */
LEITURA "leia"
ESCREVER "escreva"

/* OPERADORES LOGICOS */
/* LOGICO ">"|"<"|">="|"<="|"=="|"!="|"||"|"&&" */

/* INICIO E FIM DO PROGRAMA EXECUTADO */
INICIO "Inicio"
FINAL "Fim do programa"

IGNORAR [\ \t\s]

INVALIDO .
%%

"inteiro" {
    yylval.inteiro = 'i';
    return TIPO_INT;
}
"real" {
    yylval.inteiro = 'r';
    return TIPO_REAL;
}
"texto" {
    yylval.inteiro = 't';
    return TIPO_TEXT;
}
[:;,()] {
    return yytext[0];
}
[-+/|*=^] {
  return *yytext;
}
">" {yylval.fn = 1; return CMP; }
"<" {yylval.fn = 2; return CMP; }
"!=" {yylval.fn = 3; return CMP; }
"==" {yylval.fn = 4; return CMP; }
">=" {yylval.fn = 5; return CMP; }
"<=" {yylval.fn = 6; return CMP; }
"||" {yylval.fn = 7; return CMP; }
"&&" {yylval.fn = 8; return CMP; }

[\n] {
    /* CONTADOR PARA SALTO DE LINHAS */
    yylineno++;
}
{INICIO} {
    return INICIO;
}
{FINAL} {
    return FINAL;
}
{NUM_REAL} {
    yylval.real = atof(yytext);
    return NUM_REAL;
}
{NUM_INT} {
    yylval.inteiro = atoi(yytext);
    return NUM_INT;
}
{RAIZ} {
    return RAIZ;
}
{LEITURA} {
    return LEITURA;
}
{ESCREVER} {
    return ESCREVER;
}
{IF} {
    return IF;
}
{ELSE} {
    return ELSE;
}
{WHILE} {
    return WHILE;
}
{FOR} {
    return FOR;
}
{VARIAVEL} {
    strcpy(yylval.texto, yytext);
    return VARIAVEL;
}
{COMENTARIO} {
    strcpy(yylval.texto, yytext);
    return COMENTARIO;
}
 /* O FOR É PARA PEGAR A STRING DENTRO DAS ASPAS */
{STRING} {
    for(int x=0; x<strlen(yytext); x++){
        yytext[x] = yytext[x+1];
    }
    yytext[strlen(yytext)-1] = '\0';
    strcpy(yylval.texto, yytext);
    return STRING;
}
{IGNORAR} {
    /* ignore */
}
{INVALIDO} {
    /* ignore */
}
%%