# Projeto de Limpeza de Dados SQL (Layoffs Data)

Este projeto foca no tratamento e padronização de dados brutos sobre demissões globais, utilizando SQL para transformar dados desorganizados em uma base pronta para análise.

## 📂 Estrutura de Arquivos

* **`Project 1 - Data Cleaning.sql`**: O projeto. Contém todos os scripts SQL utilizados para a limpeza, padronização e refinamento dos dados.
* **`layoffs.csv`**: A tabela original. Contém os dados brutos sem nenhuma mudança ou tratamento prévio.

## 🛠️ Conclusão e Habilidades Aplicadas

O processo de limpeza seguiu cinco etapas fundamentais:

1.  **Eliminação de Redundâncias:** Remoção de registros duplicados utilizando *Window Function* (`ROW_NUMBER`).
2.  **Padronização de Strings:** Aplicação de *Trimming* e correção de categorias inconsistentes (ex: padronização do termo 'Crypto').
3.  **Conversão de Tipos:** Transformação da coluna de data de texto para o formato `DATE` (YYYY-MM-DD).
4.  **Imputação de Valores:** Preenchimento de valores nulos na coluna `industry` através de um *Self-Join* baseado em registros existentes da mesma empresa.
5.  **Refinamento Final:** Remoção de registros irrelevantes (linhas sem dados essenciais) e exclusão de colunas auxiliares.



---
