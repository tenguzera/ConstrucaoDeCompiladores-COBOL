# Relatório de Implementação: Analisador Léxico para COBOL

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

---

## 2.2 Implementação

### Estratégia de Desenvolvimento

A arquitetura do analisador léxico foi desenvolvida em **C** utilizando a ferramenta **Flex (Fast Lexical Analyzer Generator)**. A estratégia adotada visa estruturar o *lexer* como um gerador de tokens independente e modular, totalmente preparado para integração com o analisador sintático **Bison/Yacc**.

1. **Mapeamento de Tokens (`tokens.h`):** Foi criado um arquivo de cabeçalho temporário contendo um `enum` numérico para todos os tokens da linguagem (palavras reservadas, níveis de estrutura, identificadores, literais e operadores). Este arquivo será substituído pelo `parser.tab.h` gerado pelo Bison na próxima etapa do projeto.
2. **Expressões Regulares e Regras Léxicas (`lexer.l`):**
   * A opção `%option case-insensitive` foi ativada para garantir o tratamento homogêneo da linguagem.
   * Regras ancoradas no início da linha (`^.{6}`) foram aplicadas para descartar automaticamente a Área de Sequência (colunas 1 a 6) e identificar linhas de comentário na coluna 7.
   * Definiu-se a macro de identificador permitindo letras, números, hifens e *underlines*, além de regras específicas para literais alfanuméricos (`"..."` ou `'...'`) e numéricos.
   * Foram mapeados todos os operadores aritméticos (`+`, `-`, `*`, `/`, `**`) e lógicos (`=`, `>`, `<`, `>=`, `<=`).
3. **Saída Amigável e Testes Automáticos:** Uma função tradutora (`obter_nome_token`) foi implementada em C dentro da seção de código do Flex para exibir o nome textual do token (ex: `TOK_IDENTIFICATION`) ao invés do código numérico puro, facilitando a depuração.
4. **Automação (`rodar_testes.sh`):** Foi criado um *script* em Shell para executar o *lexer* em lote contra todos os programas `.cob` da pasta de testes e consolidar a saída formatada em um arquivo de resultados.

### Uso de Ferramentas de Inteligência Artificial

Durante o desenvolvimento, a ferramenta de IA (Gemini) foi utilizada como um assistente técnico iterativo (*thought partner* / *coding collaborator*). As atividades realizadas com auxílio da IA incluiram:

* **Ajuste das Expressões Regulares do Flex:** Resolução de ambiguidades entre o operador de subtração `-` e a presença de hifens em nomes de variáveis COBOL.
* **Depuração de Sintaxe do Flex:** Correção do erro de formatação em que comentários C colocados na primeira coluna da seção de regras eram interpretados como regras inválidas pelo Flex.
* **Expansão da Tabela de Tokens:** Identificação de operadores e símbolos não previstos na especificação inicial (ex: `=`, `>=`, `**`, `_`) ao analisar os arquivos de teste reais.
* **Criação de Scripts de Suporte:** Desenvolvimento do *script* Bash para automação de testes em lote e estruturação dos cabeçalhos de resultados.

### Repositório do Projeto

O código-fonte completo, scripts e arquivos de configuração estão disponíveis no repositório público:

* **Link do Repositório GitHub:** `https://github.com/seu-usuario/seu-repositorio-cobol` *(substitua pelo seu link público real)*

---

## 2.3 Resultados dos Testes

Os testes automatizados foram executados em todos os programas disponibilizados na pasta `Programas Cobol/` (`prog001_divisoes.cob` até `prog007_loja.cob`). O fluxo de tokens resultante foi capturado e armazenado no arquivo `resultados_lexer.txt`, demonstrando o reconhecimento adequado de palavras-chave, pontuações, identificadores, literais e operadores em formato tabular.

---

## 2.4 Resultados de Erros

Para demonstrar como o analisador léxico trata entradas inválidas ou inesperadas e como ele prepara essas ocorrências para o analisador sintático, foram inseridos **10 erros distintos** nos programas de teste COBOL. 

A regra padrão no Flex (`.`) captura qualquer caractere que não corresponda às expressões regulares definidas e emite uma mensagem de erro léxico com o número da linha correspondente:

```c
. { printf("Erro lexico na linha %d: Token inesperado '%s'\n", linha_atual, yytext); }
```

Abaixo estão os 10 cenários de erro testados, acompanhados do trecho de código modificado, do resultado gerado pelo *lexer* e da explicação de seu tratamento.

---

### Erro 1: Caractere Inválido `@` no Nome de uma Variável
* **Código COBOL Inserido:**
  ```cobol
  MOVE @WS-VALOR1 TO WS-VALOR2.
  ```
* **Saída do Lexer:**
  ```text
  Erro lexico na linha 18: Token inesperado '@'
  TOK_ID                 | 'WS-VALOR1'
  TOK_TO                 | 'TO'
  TOK_ID                 | 'WS-VALOR2'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** O símbolo `@` não pertence ao conjunto alfanumérico aceito para identificadores. A regra de captura de erros intercepta o símbolo inválido, reporta a linha e o *lexer* continua o escaneamento dos tokens subsequentes sem interromper o processo.

---

### Erro 2: Símbolo Específico `&` em uma Instrução de Comando
* **Código COBOL Inserido:**
  ```cobol
  DISP&AY "MENSAGEM DE ERRO".
  ```
* **Saída do Lexer:**
  ```text
  TOK_ID                 | 'DISP'
  Erro lexico na linha 22: Token inesperado '&'
  TOK_ID                 | 'AY'
  TOK_LIT_ALPHA          | '"MENSAGEM DE ERRO"'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** O caractere `&` quebra a palavra reservada `DISPLAY`. O lexer reconhece `DISP` como um identificador, reporta o erro do caractere `&` e lê `AY` como outro identificador. Essa sequência quebrada causará um erro sintático no Bison.

---

### Erro 3: Identificador Iniciando com Hífen Inválido
* **Código COBOL Inserido:**
  ```cobol
  MOVE 10 TO -WS-CONTADOR.
  ```
* **Saída do Lexer:**
  ```text
  TOK_MOVE               | 'MOVE'
  TOK_LIT_NUM            | '10'
  TOK_TO                 | 'TO'
  TOK_MENOS              | '-'
  TOK_ID                 | 'WS-CONTADOR'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** Como a regra de identificador exige que a palavra comece com caractere alfanumérico (`[a-zA-Z0-9]`), o hífen inicial é emitido como o operador `TOK_MENOS`, seguido do identificador `WS-CONTADOR`. Caberá ao analisador sintático rejeitar um operador imediatamente antes de um destino de atribuição.

---

### Erro 4: Identificador Terminando com Underline
* **Código COBOL Inserido:**
  ```cobol
  01 WS_VAR_ PIC 9(02).
  ```
* **Saída do Lexer:**
  ```text
  TOK_NIVEL_01           | '01'
  TOK_ID                 | 'WS_VAR'
  Erro lexico na linha 14: Token inesperado '_'
  TOK_PIC                | 'PIC'
  TOK_LIT_NUM            | '9'
  TOK_ABRE_PAR           | '('
  TOK_NIVEL_02_49        | '02'
  TOK_FECHA_PAR          | ')'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** A expressão regular limita a terminação de identificadores a alfanuméricos. O sufixo `_` é capturado como um caractere inesperado na linha 14, e o lexer prossegue lendo a cláusula `PIC`.

---

### Erro 5: Caractere Especial Não Mapeado `$` em Valor Monetário
* **Código COBOL Inserido:**
  ```cobol
  MOVE $50.00 TO WS-SALARIO.
  ```
* **Saída do Lexer:**
  ```text
  TOK_MOVE               | 'MOVE'
  Erro lexico na linha 31: Token inesperado '$'
  TOK_LIT_NUM            | '50.00'
  TOK_TO                 | 'TO'
  TOK_ID                 | 'WS-SALARIO'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** O símbolo `$` é rejeitado pela regra genérica de erros léxicos, enquanto a constante numérica decimal `50.00` é corretamente reconhecida logo em seguida como `TOK_LIT_NUM`.

---

### Erro 6: Caractere Inválido `#` Dentro da Cláusula PICTURE
* **Código COBOL Inserido:**
  ```cobol
  05 WS-CODIGO PIC X#5.
  ```
* **Saída do Lexer:**
  ```text
  TOK_NIVEL_02_49        | '05'
  TOK_ID                 | 'WS-CODIGO'
  TOK_PIC                | 'PIC'
  TOK_ID                 | 'X'
  Erro lexico na linha 12: Token inesperado '#'
  TOK_LIT_NUM            | '5'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** O lexer identifica `PIC` e a máscara `X`, reporta a presença do caractere especial `#` não reconhecido e emite o número `5`. A estrutura resultante quebrada será apontada pelo analisador sintático.

---

### Erro 7: Presença do Símbolo `?` em Condicional IF
* **Código COBOL Inserido:**
  ```cobol
  IF WS-CONTADOR ? 5
  ```
* **Saída do Lexer:**
  ```text
  TOK_IF                 | 'IF'
  TOK_ID                 | 'WS-CONTADOR'
  Erro lexico na linha 40: Token inesperado '?'
  TOK_LIT_NUM            | '5'
  ```
* **Tratamento:** O ponto de interrogação `?` não é um operador relacional válido em COBOL. O erro léxico é reportado imediatamente na linha 40 e o token numérico `5` é retornado na sequência.

---

### Erro 8: Operador Bitwise `~` (Inexistente em COBOL)
* **Código COBOL Inserido:**
  ```cobol
  COMPUTE WS-RESULT = ~WS-VALOR.
  ```
* **Saída do Lexer:**
  ```text
  TOK_ID                 | 'COMPUTE'
  TOK_ID                 | 'WS-RESULT'
  TOK_IGUAL              | '='
  Erro lexico na linha 52: Token inesperado '~'
  TOK_ID                 | 'WS-VALOR'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** O til `~` não é reconhecido por nenhuma regra de operador. O erro léxico é exibido e os demais elementos válidos da expressão (`COMPUTE`, `WS-RESULT`, `=`, `WS-VALOR`) continuam sendo agrupados normalmente.

---

### Erro 9: Comentário Mal Formado (Asterisco fora da Coluna 7)
* **Código COBOL Inserido:**
  ```cobol
         * ESTE COMENTARIO ESTA NA COLUNA 8
  ```
* **Saída do Lexer:**
  ```text
  TOK_ASTERISCO          | '*'
  TOK_ID                 | 'ESTE'
  TOK_ID                 | 'COMENTARIO'
  TOK_ID                 | 'ESTA'
  TOK_ID                 | 'NA'
  TOK_ID                 | 'COLUNA'
  TOK_ID                 | '8'
  ```
* **Tratamento:** No formato fixo do COBOL, um comentário só é válido se o `*` estiver estritamente na coluna 7 (`^.{6}\*.*$`). Como o asterisco foi inserido na coluna 8 (Área A), o lexer o trata como o operador de multiplicação `TOK_ASTERISCO` e os textos subsequentes como tokens de identificadores, evidenciando o tratamento correto do layout de colunas.

---

### Erro 10: Aspas Não Fechadas em Literal Alfanumérico
* **Código COBOL Inserido:**
  ```cobol
  DISPLAY "MENSAGEM SEM FECHAR ASPAS.
  ```
* **Saída do Lexer:**
  ```text
  TOK_DISPLAY            | 'DISPLAY'
  Erro lexico na linha 25: Token inesperado '"'
  TOK_ID                 | 'MENSAGEM'
  TOK_ID                 | 'SEM'
  TOK_ID                 | 'FECHAR'
  TOK_ID                 | 'ASPAS'
  TOK_PONTO              | '.'
  ```
* **Tratamento:** A regra `LIT_ALFA` exige o fechamento correspondente das aspas (`\"[^\"]*\"`). Como as aspas de fechamento foram omitidas antes da quebra de linha, a regra de literal falha. A aspa inicial é capturada como token inesperado e o texto interno é processado como uma série de identificadores separados, demonstrando o rigor na validação de literais.