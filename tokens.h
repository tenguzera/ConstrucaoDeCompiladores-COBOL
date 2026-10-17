#ifndef TOKENS_H
#define TOKENS_H

enum yytokentype {
    /* Palavras-chave reservadas básicas[cite: 1] */
    TOK_IDENTIFICATION = 258,
    TOK_ENVIRONMENT,
    TOK_DATA,
    TOK_PROCEDURE,
    TOK_DIVISION,
    TOK_SECTION,
    TOK_DISPLAY,
    TOK_ACCEPT,
    TOK_PERFORM,
    TOK_STOP,
    TOK_RUN,
    TOK_IF,
    TOK_ELSE,
    TOK_MOVE,

    /* Nomes estruturais, seções e verbos adicionais[cite: 2, 3] */
    TOK_PROGRAM_ID,
    TOK_CONFIGURATION,
    TOK_SOURCE_COMPUTER,
    TOK_OBJECT_COMPUTER,
    TOK_INPUT_OUTPUT,
    TOK_FILE_CONTROL,
    TOK_SELECT,
    TOK_ASSIGN,
    TOK_TO,
    TOK_PIC,
    TOK_VALUE,
    
    /* Níveis de Dados[cite: 2, 3] */
    TOK_NIVEL_01,
    TOK_NIVEL_02_49,
    TOK_NIVEL_77,
    TOK_NIVEL_88,

    /* Diretivas do Compilador[cite: 4] */
    TOK_COPY,

    /* Identificadores e Literais[cite: 2] */
    TOK_ID,
    TOK_LIT_NUM,
    TOK_LIT_ALPHA,

    /* Símbolos e Pontuação[cite: 2] */
    TOK_PONTO,
    TOK_VIRGULA,
    TOK_PONTO_VIRGULA,
    TOK_ABRE_PAR,
    TOK_FECHA_PAR
};

#endif