# ConstrucaoDeCompiladores-COBOL

Projeto para criação de um analisar léxico (e eventualmente um analisador sintático) de COBOL para a disciplina de Construção de Compiladores.

## Forma de Uso

É necessário ter o Flex instalado e um compilador C.

```
flex lexer.l

gcc lex.yy.c -o lexer_cobol

./lexer_cobol SEU_PROGRAMA_COBOL.col
```

## Testes e Relatório

Também é fornecido um script bash `rodar_testes.sh` para rodar o lexer nos programas COBOL dentro da pasta `Programas COBOL`. Uma série de programas COBOL de exemplo fornecidos pelo professor estão disponíveis lá.

Um relatório do projeto pode ser visto em `RELATORIO.md`.
