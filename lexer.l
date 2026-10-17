%{
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"

/* Variável global temporária para testes */
int linha_atual = 1;
%}

/* COBOL é case-insensitive */
%option case-insensitive
%option noyywrap

/* Identificadores: A-Z, 0-9, hífen (até 30 caracteres, não inicia/termina com hífen) */
IDENTIFICADOR   [a-zA-Z0-9]([a-zA-Z0-9\-]{0,28}[a-zA-Z0-9])?

/* Numéricos: opcionalmente precedidos por sinal e com ponto decimal interno */
LIT_NUMERICO    [\+\-]?[0-9]+(\.[0-9]+)?

/* Alfanuméricos: delimitados por aspas simples ou duplas */
LIT_ALFA        \"[^\"]*\"|\'[^\']*\'

/* Espaços padrão */
ESPACO          [ \t\r]+

%%

\n              { linha_atual++; }
{ESPACO}        { /* Ignora espaços em branco na Área B */ }

    /* Regras de Colunas e Formato Fixo */
^.{6}\*.*$      { /* Coluna 7 com '*': Linha de comentário (ignorado) */ }
^.{6}\/.*$      { /* Coluna 7 com '/': Linha de comentário (ignorado) */ }
^.{6}           { /* Colunas 1-6: Indicador de Sequência (ignorado) */ }

    /* Palavras-Chave Reservadas */
"IDENTIFICATION" { return TOK_IDENTIFICATION; }
"ENVIRONMENT"    { return TOK_ENVIRONMENT; }
"DATA"           { return TOK_DATA; }
"PROCEDURE"      { return TOK_PROCEDURE; }
"DIVISION"       { return TOK_DIVISION; }
"SECTION"        { return TOK_SECTION; }
"DISPLAY"        { return TOK_DISPLAY; }
"ACCEPT"         { return TOK_ACCEPT; }
"PERFORM"        { return TOK_PERFORM; }
"STOP"           { return TOK_STOP; }
"RUN"            { return TOK_RUN; }
"IF"             { return TOK_IF; }
"ELSE"           { return TOK_ELSE; }
"MOVE"           { return TOK_MOVE; }

    /* Palavras de Divisões e Declarações de Arquivos/Variáveis */
"PROGRAM-ID"        { return TOK_PROGRAM_ID; }
"CONFIGURATION"     { return TOK_CONFIGURATION; }
"SOURCE-COMPUTER"   { return TOK_SOURCE_COMPUTER; }
"OBJECT-COMPUTER"   { return TOK_OBJECT_COMPUTER; }
"INPUT-OUTPUT"      { return TOK_INPUT_OUTPUT; }
"FILE-CONTROL"      { return TOK_FILE_CONTROL; }
"SELECT"            { return TOK_SELECT; }
"ASSIGN"            { return TOK_ASSIGN; }
"TO"                { return TOK_TO; }
"PICTURE"|"PIC"     { return TOK_PIC; }
"VALUE"             { return TOK_VALUE; }

    /* Suporte à diretiva COPY */
"COPY"              { return TOK_COPY; }

    /* Níveis de Estrutura */
"01"                { return TOK_NIVEL_01; }
"77"                { return TOK_NIVEL_77; }
"88"                { return TOK_NIVEL_88; }
0[2-9]|[1-4][0-9]   { return TOK_NIVEL_02_49; }

    /* Identificadores e Literais */
{LIT_NUMERICO}      { return TOK_LIT_NUM; }
{LIT_ALFA}          { return TOK_LIT_ALPHA; }
{IDENTIFICADOR}     { return TOK_ID; }

    /* Símbolos Especiais e Pontuação */
\.                  { return TOK_PONTO; } 
\,                  { return TOK_VIRGULA; }
\;                  { return TOK_PONTO_VIRGULA; }
\(                  { return TOK_ABRE_PAR; }
\)                  { return TOK_FECHA_PAR; }

    /* Tratamento de Erros de Análise Léxica */
.                   { printf("Erro lexico na linha %d: Token inesperado '%s'\n", linha_atual, yytext); }

%%

/* Função main embutida estritamente para testes imediatos sem o Bison */
int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Erro ao abrir o arquivo COBOL");
            return 1;
        }
    }

    int token;
    while ((token = yylex())) {
        printf("Token Code: %d | Lexema: '%s'\n", token, yytext);
    }

    if (yyin) fclose(yyin);
    return 0;
}