#!/bin/bash

# Define o nome do arquivo onde os resultados serão salvos
ARQUIVO_SAIDA="resultados_lexer.txt"

# Limpa o arquivo de saída caso ele já exista
> "$ARQUIVO_SAIDA"

echo "Iniciando a execução em lote do analisador léxico..."

# Itera sobre os arquivos .cob especificamente dentro da pasta "Programas Cobol"
for arquivo in "Programas Cobol"/*.cob; do
    if [ -e "$arquivo" ]; then
        echo "Analisando: $arquivo"
        
        # Cabeçalho no arquivo de saída
        echo "============================================================" >> "$ARQUIVO_SAIDA"
        echo "RESULTADOS PARA O ARQUIVO: $arquivo" >> "$ARQUIVO_SAIDA"
        echo "============================================================" >> "$ARQUIVO_SAIDA"
        
        # Executa o lexer passando o caminho relativo do arquivo
        ./lexer_cobol "$arquivo" >> "$ARQUIVO_SAIDA"
        
        # Separação
        echo -e "\n\n" >> "$ARQUIVO_SAIDA"
    fi
done

echo "Processamento concluído! Verifique o arquivo '$ARQUIVO_SAIDA'."