# Relatório - Analisador Léxico COBOL
## Introdução

O COBOL (*Common Business-Oriented Language*), criado no final da década de 1950, permanece como uma das linguagens de programação mais críticas da infraestrutura de TI global. Sua persistência em sistemas legados — principalmente no setor bancário, financeiro, de seguros e governamental — deve-se à alta eficiência no processamento em lote (*batch*), suporte nativo a aritmética decimal de alta precisão (evitando erros de arredondamento de ponto flutuante em transações monetárias) e robustez na manipulação de grandes volumes de dados em *mainframes*.

Do ponto de vista da **Análise Léxica**, o COBOL apresenta desafios específicos e incomuns quando comparado a linguagens modernas como C, Java ou Python:

* **Layout Fixo de Colunas (*Fixed Format*):** Historicamente projetado para cartões perfurados, o código COBOL tradicional depende estritamente da posição das colunas na linha:
  * *Colunas 1-6:* Área de sequência (deve ser ignorada pelo lexer).
  * *Coluna 7:* Área de indicadores (onde `*` ou `/` indicam comentário, e `-` indica continuação de linha).
  * *Colunas 8-11:* Área A (início de divisões, seções, parágrafos e níveis lógicos superiores como `01` e `77`).
  * *Colunas 12-72:* Área B (comandos, frases, cláusulas e níveis de dados).
  * *Colunas 73-80:* Área de identificação do programa (desprezada pelo compilador).
* **Case-Insensitivity:** A linguagem é insensível a maiúsculas e minúsculas, exigindo que o analisador trate palavras reservadas e identificadores de forma unificada (`DISPLAY`, `display` e `Display` geram o mesmo token).
* **Identificadores com Hífen e Underline:** Nomes de variáveis e parágrafos podem conter hifens (`-`) e *underlines* (`_`) internamente (ex: `WS-VALOR-TOTAL`), exigindo diferenciação entre o operador de subtração/sinal negativo e a composição do nome do identificador.
* **Símbolos Críticos de Pontuação:** O ponto final (`.`) não é um simples delimitador óptico; ele é o token responsável por encerrar sentenças, parágrafos e cláusulas de dados no COBOL, sendo indispensável para a análise sintática posterior.

## 2.2 Implementação

### Estratégia de Desenvolvimento

A arquitetura do analisador léxico foi desenvolvida em **C** utilizando a ferramenta **Flex (Fast Lexical Analyzer Generator)**. A estratégia adotada visa estruturar o *lexer* como um gerador de tokens independente e modular,  preparado para integração com o analisador sintático a ser usado na próxima etapa do projeto. (Provavelmente Bison/Yacc).

1. **Mapeamento de Tokens (`tokens.h`):** Foi criado um arquivo de cabeçalho temporário contendo um `enum` numérico para todos os tokens da linguagem (palavras reservadas, níveis de estrutura, identificadores, literais e operadores).
2. **Expressões Regulares e Regras Léxicas (`lexer.l`):**
   * A opção `%option case-insensitive` foi ativada para garantir o tratamento homogêneo da linguagem.
   * Regras ancoradas no início da linha (`^.{6}`) foram aplicadas para descartar automaticamente a Área de Sequência (colunas 1 a 6) e identificar linhas de comentário na coluna 7.
   * Definiu-se a macro de identificador permitindo letras, números, hifens e *underlines*, além de regras específicas para literais alfanuméricos (`"..."` ou `'...'`) e numéricos.
   * Foram mapeados todos os operadores aritméticos (`+`, `-`, `*`, `/`, `**`) e lógicos (`=`, `>`, `<`, `>=`, `<=`).
3. **Saída do Programa:** Uma função tradutora (`obter_nome_token`) foi implementada em C dentro da seção de código do Flex para exibir o nome textual do token (ex: `TOK_IDENTIFICATION`) ao invés do código numérico puro, facilitando a depuração.
4. **Automação (`rodar_testes.sh`):** Foi criado um *script* em Shell para executar o *lexer* em lote contra todos os programas `.cob` da pasta de testes e consolidar a saída formatada em um arquivo de resultados.

### Uso de Ferramentas de Inteligência Artificial

Durante o desenvolvimento do projeto foi utilizado a IA do Gemini para auxiliar a pesquisa sobre o funcionamento do COBOL e entender como utilizar o Flex para a criação de um analisador léxico, diminuindo o atrito envolvido na hora de programar o projeto. A IA também auxiliou na correção de bugs e na escrita do relatório.

### Repositório do Projeto

O código-fonte completo, scripts e arquivos de configuração estão disponíveis no repositório público:

* **Link do Repositório GitHub:** `https://github.com/tenguzera/ConstrucaoDeCompiladores-COBOL`

## 2.3 Resultados dos Testes

Os testes automatizados foram executados em todos os programas disponibilizados. O fluxo de tokens resultante foi capturado e pode ser visualizado no arquivo `resultados_lexer.txt`.

## 2.4 Resultados de Erros

Para atender aos requisitos de entrega e validar o analisador léxico, foram inseridos dez erros propositais  distribuídos entre os códigos-fonte fornecidos. A regra de contingência do *lexer* captura os caracteres que não se encaixam nas expressões regulares mapeadas, emite um alerta com o número da linha e permite que a análise dos próximos *tokens* continue para que o futuro analisador sintático possa tratar a estrutura quebrada.

Alguns cenários de erros aplicados e os respectivos comportamentos do *lexer*:

### 1. Caractere Inválido `@` na Declaração do Autor
* **Arquivo modificado:** `prog001_divisoes.cob`.
* **Código alterado:** 
  ```cobol
  AUTHOR. @Enio Basso.
  ```
* **Saída do Lexer:**
  ```text
  TOK_ID                 | 'AUTHOR'
  TOK_PONTO              | '.'
  Erro lexico na linha 16: Token inesperado '@'
  TOK_ID                 | 'Enio'
  TOK_ID                 | 'Basso'
  TOK_PONTO              | '.'
  ```
* **Comportamento:** O símbolo `@` não faz parte dos caracteres permitidos em identificadores. O *lexer* captura e reporta o caractere isoladamente, prosseguindo com a tokenização do nome em seguida, que no arquivo original era apenas `AUTHOR. Enio Basso.`.

### 2. Símbolo `&` Quebrando a Palavra Reservada DISPLAY
* **Arquivo modificado:** `prog002_operacoes.cob`.
* **Código alterado:** 
  ```cobol
  DISP&AY "===== start =======".
  ```
* **Saída do Lexer:**
  ```text
  TOK_ID                 | 'DISP'
  Erro lexico na linha 23: Token inesperado '&'
  TOK_ID                 | 'AY'
  TOK_LIT_ALPHA          | '"===== start ======="'
  TOK_PONTO              | '.'
  ```
* **Comportamento:** A inserção do `&` interrompe a leitura da instrução original `DISPLAY "===== start =======".`. Como resultado, o *lexer* lê `DISP` como um identificador, reporta o erro e lê `AY` como um segundo identificador.

### 3. Caractere Monetário `$` Inesperado na Máscara PICTURE
* **Arquivo modificado:** `prog003_calculadora.cob`.
* **Código alterado:** 
  ```cobol
  77 WKS-RESULT-FORMAT   PIC -ZZZZZZZZZ9.99$.
  ```
* **Saída do Lexer:**
  ```text
  TOK_NIVEL_77           | '77'
  TOK_ID                 | 'WKS-RESULT-FORMAT'
  TOK_PIC                | 'PIC'
  TOK_MENOS              | '-'
  TOK_ID                 | 'ZZZZZZZZZ9'
  TOK_PONTO              | '.'
  TOK_LIT_NUM            | '99'
  Erro lexico na linha 21: Token inesperado '$'
  TOK_PONTO              | '.'
  ```
* **Comportamento:** O símbolo `$` não possui mapeamento no analisador COBOL atual, sendo prontamente classificado como *token* inesperado ao final da estrutura da cláusula PICTURE, que originalmente terminava apenas em `.99.`.

### 4. Símbolo Exclamação `!` Colado a um Identificador
* **Arquivo modificado:** `prog004_folha_pgto.cob`.
* **Código alterado:** 
  ```cobol
  77 IDX! PIC 9(1).
  ```
* **Saída do Lexer:**
  ```text
  TOK_NIVEL_77           | '77'
  TOK_ID                 | 'IDX'
  Erro lexico na linha 22: Token inesperado '!'
  TOK_PIC                | 'PIC'
  TOK_LIT_NUM            | '9'
  ```
* **Comportamento:** O analisador interrompe a formação da variável original `IDX` ao encontrar a exclamação `!`, reportando o erro antes de ler a palavra-chave `PIC`.

### 5. Aspas Não Fechadas no Literal Alfanumérico
* **Arquivo modificado:** `prog005_strings.cob`.
* **Código alterado:** 
  ```cobol
  MOVE "HELLO WORLD 123!! TO SAUX.
  ```
* **Saída do Lexer:**
  ```text
  TOK_MOVE               | 'MOVE'
  Erro lexico na linha 23: Token inesperado '"'
  TOK_ID                 | 'HELLO'
  TOK_ID                 | 'WORLD'
  TOK_LIT_NUM            | '123'
  Erro lexico na linha 23: Token inesperado '!'
  Erro lexico na linha 23: Token inesperado '!'
  TOK_TO                 | 'TO'
  TOK_ID                 | 'SAUX'
  TOK_PONTO              | '.'
  ```
* **Comportamento:** Como o literal perdeu as aspas de fechamento da declaração original `"HELLO WORLD 123!!"` antes da quebra de linha, a regra `LIT_ALFA` falha. O *lexer* descarta a primeira aspa e tenta interpretar o texto interno como código COBOL padrão, gerando vários erros léxicos no meio.

### 6. Operador Til `~` Inexistente em Declaração de Arquivo
* **Arquivo modificado:** `prog006_files.cob`.
* **Código alterado:** 
  ```cobol
  FD MY-FILE~.
  ```
* **Saída do Lexer:**
  ```text
  TOK_ID                 | 'FD'
  TOK_ID                 | 'MY-FILE'
  Erro lexico na linha 19: Token inesperado '~'
  TOK_PONTO              | '.'
  ```
* **Comportamento:** O til não possui função no COBOL tradicional. O *lexer* captura o descritor de arquivo original `FD MY-FILE.`, aponta o símbolo inesperado `~` e encerra com o `TOK_PONTO` sem causar falhas.

### 7. Operador Interrogação `?` Substituindo Operador Relacional
* **Arquivo modificado:** `prog007_loja.cob`.
* **Código alterado:** 
  ```cobol
  IF WS-EXIT ? 0
  ```
* **Saída do Lexer:**
  ```text
  TOK_IF                 | 'IF'
  TOK_ID                 | 'WS-EXIT'
  Erro lexico na linha 89: Token inesperado '?'
  TOK_LIT_NUM            | '0'
  ```
* **Comportamento:** Ao trocar a igualdade da condição original `IF WS-EXIT = 0` por `?`, o identificador relacional se torna um erro lexical direto, entregando uma sentença sintática inválida ao Bison.

### 8. Asterisco de Comentário Fora da Coluna 7
* **Arquivo modificado:** `prog002_operacoes.cob`.
* **Código alterado:** 
  ```cobol
         ******* Tive que tirar o ponto.
  ```
* **Saída do Lexer:**
  ```text
  TOK_ASTERISCO          | '*'
  TOK_ASTERISCO          | '*'
  TOK_ASTERISCO          | '*'
  TOK_ASTERISCO          | '*'
  TOK_ASTERISCO          | '*'
  TOK_ASTERISCO          | '*'
  TOK_ASTERISCO          | '*'
  TOK_ID                 | 'Tive'
  ```
* **Comportamento:** Em COBOL *Fixed Format*, os comentários devem ter o `*` obrigatoriamente na coluna 7. Ao deslocar o comentário original `****** Tive que tirar o ponto.` para a coluna 8, a regra de exclusão não é ativada e o *lexer* interpreta os caracteres como múltiplos operadores de multiplicação seguidos de identificadores.

### 9. Símbolo de Módulo `%` Não Suportado
* **Arquivo modificado:** `prog003_calculadora.cob`.
* **Código alterado:** 
  ```cobol
  COMPUTE WKS-RESULTADO = WKS-NUM-1 % WKS-NUM-2
  ```
* **Saída do Lexer:**
  ```text
  TOK_ID                 | 'COMPUTE'
  TOK_ID                 | 'WKS-RESULTADO'
  TOK_IGUAL              | '='
  TOK_ID                 | 'WKS-NUM-1'
  Erro lexico na linha 69: Token inesperado '%'
  TOK_ID                 | 'WKS-NUM-2'
  ```
* **Comportamento:** A exponenciação da linha original `COMPUTE WKS-RESULTADO = WKS-NUM-1 ** WKS-NUM-2` foi trocada pelo caractere `%`. Como o operador matemático `%` não está listado na gramática desenvolvida, ele acusa erro no terminal.

### 10. Barra Invertida `\` Inválida em Identificador
* **Arquivo modificado:** `prog007_loja.cob`.
* **Código alterado:** 
  ```cobol
  01 WS-\PRODUTO.
  ```
* **Saída do Lexer:**
  ```text
  TOK_NIVEL_01           | '01'
  TOK_ID                 | 'WS-'
  Erro lexico na linha 73: Token inesperado '\'
  TOK_ID                 | 'PRODUTO'
  TOK_PONTO              | '.'
  ```
* **Comportamento:** A inserção de `\` fragmenta o identificador original `WS-PRODUTO`. O *lexer* aceita `WS-` devido à flexibilização que permite hifens, reporta a contrabarra e separa o termo posterior, descaracterizando a variável.
