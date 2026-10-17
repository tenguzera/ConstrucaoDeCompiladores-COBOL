%{
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"

int linha_atual = 1;

const char* obter_nome_token(int token) {
    switch(token) {
        case TOK_IDENTIFICATION: return "TOK_IDENTIFICATION";
        case TOK_ENVIRONMENT: return "TOK_ENVIRONMENT";
        case TOK_DATA: return "TOK_DATA";
        case TOK_PROCEDURE: return "TOK_PROCEDURE";
        case TOK_DIVISION: return "TOK_DIVISION";
        case TOK_SECTION: return "TOK_SECTION";
        case TOK_DISPLAY: return "TOK_DISPLAY";
        case TOK_ACCEPT: return "TOK_ACCEPT";
        case TOK_PERFORM: return "TOK_PERFORM";
        case TOK_STOP: return "TOK_STOP";
        case TOK_RUN: return "TOK_RUN";
        case TOK_IF: return "TOK_IF";
        case TOK_ELSE: return "TOK_ELSE";
        case TOK_MOVE: return "TOK_MOVE";
        case TOK_PROGRAM_ID: return "TOK_PROGRAM_ID";
        case TOK_CONFIGURATION: return "TOK_CONFIGURATION";
        case TOK_SOURCE_COMPUTER: return "TOK_SOURCE_COMPUTER";
        case TOK_OBJECT_COMPUTER: return "TOK_OBJECT_COMPUTER";
        case TOK_INPUT_OUTPUT: return "TOK_INPUT_OUTPUT";
        case TOK_FILE_CONTROL: return "TOK_FILE_CONTROL";
        case TOK_SELECT: return "TOK_SELECT";
        case TOK_ASSIGN: return "TOK_ASSIGN";
        case TOK_TO: return "TOK_TO";
        case TOK_PIC: return "TOK_PIC";
        case TOK_VALUE: return "TOK_VALUE";
        case TOK_NIVEL_01: return "TOK_NIVEL_01";
        case TOK_NIVEL_02_49: return "TOK_NIVEL_02_49";
        case TOK_NIVEL_77: return "TOK_NIVEL_77";
        case TOK_NIVEL_88: return "TOK_NIVEL_88";
        case TOK_COPY: return "TOK_COPY";
        case TOK_ID: return "TOK_ID";
        case TOK_LIT_NUM: return "TOK_LIT_NUM";
        case TOK_LIT_ALPHA: return "TOK_LIT_ALPHA";
        case TOK_PONTO: return "TOK_PONTO";
        case TOK_VIRGULA: return "TOK_VIRGULA";
        case TOK_PONTO_VIRGULA: return "TOK_PONTO_VIRGULA";
        case TOK_ABRE_PAR: return "TOK_ABRE_PAR";
        case TOK_FECHA_PAR: return "TOK_FECHA_PAR";
        
        /* Novos retornos em String para Operadores */
        case TOK_IGUAL: return "TOK_IGUAL";
        case TOK_MAIOR: return "TOK_MAIOR";
        case TOK_MENOR: return "TOK_MENOR";
        case TOK_MAIOR_IGUAL: return "TOK_MAIOR_IGUAL";
        case TOK_MENOR_IGUAL: return "TOK_MENOR_IGUAL";
        case TOK_MAIS: return "TOK_MAIS";
        case TOK_MENOS: return "TOK_MENOS";
        case TOK_ASTERISCO: return "TOK_ASTERISCO";
        case TOK_BARRA: return "TOK_BARRA";
        case TOK_EXP: return "TOK_EXP";
        
        default: return "TOKEN_DESCONHECIDO";
    }
}
%}

%option case-insensitive
%option noyywrap

/* Identificadores */
IDENTIFICADOR   [a-zA-Z0-9]([a-zA-Z0-9\-_]{0,28}[a-zA-Z0-9])?
LIT_NUMERICO    [\+\-]?[0-9]+(\.[0-9]+)?
LIT_ALFA        \"[^\"]*\"|\'[^\']*\'
ESPACO          [ \t\r]+

%%

\n              { linha_atual++; }
{ESPACO}        { /* Ignora espaços em branco na Área B */ }

    /* Regras de Colunas e Formato Fixo */
^.{6}\*.*$      { /* Coluna 7 com '*': Linha de comentário */ }
^.{6}\/.*$      { /* Coluna 7 com '/': Linha de comentário */ }
^.{6}           { /* Colunas 1-6: Indicador de Sequência */ }

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

    /* Palavras de Divisões e Declarações */
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

    /* Operadores Matemáticos e Lógicos */
"**"                { return TOK_EXP; }
">="                { return TOK_MAIOR_IGUAL; }
"<="                { return TOK_MENOR_IGUAL; }
"="                 { return TOK_IGUAL; }
">"                 { return TOK_MAIOR; }
"<"                 { return TOK_MENOR; }
"+"                 { return TOK_MAIS; }
"-"                 { return TOK_MENOS; }
"*"                 { return TOK_ASTERISCO; }
"/"                 { return TOK_BARRA; }

    /* Símbolos Especiais e Pontuação */
\.                  { return TOK_PONTO; } 
\,                  { return TOK_VIRGULA; }
\;                  { return TOK_PONTO_VIRGULA; }
\(                  { return TOK_ABRE_PAR; }
\)                  { return TOK_FECHA_PAR; }

    /* Tratamento de Erros */
.                   { printf("Erro lexico na linha %d: Token inesperado '%s'\n", linha_atual, yytext); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Erro ao abrir o arquivo COBOL");
            return 1;
        }
    }

    int token;
    printf("%-22s | %s\n", "TIPO DO TOKEN", "LEXEMA");
    printf("-----------------------+------------------------\n");
    
    while ((token = yylex())) {
        printf("%-22s | '%s'\n", obter_nome_token(token), yytext);
    }

    if (yyin) fclose(yyin);
    return 0;
}