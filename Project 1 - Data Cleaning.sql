-- SQL - Projeto de Limpeza de Dados
-- Objetivos: Limpar e padronizar dados brutos de demissões globais (layoffs) para futuras análises.
-- O processo inclui remoção de duplicatas, tratamento de valores nulos e padronização de tipos de dados.

SELECT *
FROM world_layoffs.layoffs; 

-- Criar uma nova tabela de ensaio com os dados da original (layoffs) para melhores práticas.
CREATE TABLE layoffs_staging 
LIKE layoffs; 

SELECT *
FROM layoffs_staging; 

INSERT layoffs_staging 
SELECT * 
FROM layoffs; 

-- Passos:
-- 1. Remoção de Duplicatas
-- 2. Padronização de Texto
-- 3. Conversão de Tipos 
-- 4. Imputação de Dados
-- 5. Refinamento Final

-- Passo 1:
-- Identificação e Remoção de Duplicatas
-- Como o dataset não possui uma Primary key única, uma Window Function (ROW_NUMBER() foi utilizada com PARTITION BY para identifcar linhas idênticas.

SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num  
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1; 

-- Existe duas linhas repetidas 'Casper', da coluna 'company' e é necessário remover uma.

SELECT *
FROM layoffs_staging
WHERE company = 'Casper'; 

-- Não é possível atualizar(deletar) um CTE, então a coluna 'row_num' será adicionada em uma nova tabela chamada 'layoffs_staging2'.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Passo 2:
-- Padronização de Strings: Removendo espaços em branco utilizando (trimming) e pontos desnecessários.

SELECT * 
FROM layoffs_staging2;

SELECT DISTINCT company, TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Ocorrerá o agrupamento de todas as linhas 'Crypto' que possuem nomes diferentes.

SELECT DISTINCT industry 
FROM layoffs_staging2
; 

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Deve ocorrer a remoção de pontos na coluna 'United States'.

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Passo 3:
-- Conversão de Tipos: 
-- Transforma a coluna 'date' de TEXTO para o formato DATA (YYYY-MM-DD).

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE (`date`, '%m/%d/%Y');   

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

-- Passo 4:
-- Tratamento de valores nulos e strings vazias.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Primeiro, convertemos strings vazias em NULLS.

UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry = ''; 

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Há registros da linha Airbnb com valores ausentes na coluna 'industry' antes da imputação.

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Passo 4:
-- Imputação de Dados: Preencher valores nulos ou espaços através de um Self-Join.
-- Com os dados convertidos para NULL, o SQL consegue agora identificar e substituir os campos vazios pelos valores correspondentes da mesma empresa.

SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Na coluna 'industry' é possível ver que na 't1' a linha 'travel' foi populada.

SELECT *
FROM layoffs_staging2;

-- Passo 5: 
-- Refinamento Final:
-- Não tem como saber quantas pessoas foram demitidas nem a porcentagem, por isso esses registros são inúteis para a maioria das análises.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE         
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- CONCLUSÃO DA LIMPEZA:

-- 1. Eliminação de Redundâncias: Remoção de registros duplicados via Window Function (ROW_NUMBER).
-- 2. Padronização de Strings: Aplicação de Trimming e padronização de categorias inconsistentes (ex: Crypto).
-- 3. Conversão de Tipos: Transformação da coluna 'date' de TEXTO para o formato DATE (YYYY-MM-DD).
-- 4. Imputação de Valores: Preenchimento de nulos na coluna 'industry' via Self-Join baseado em registros existentes.
-- 5. Refinamento Final: Remoção de registros irrelevantes (linhas com dados nulos) e exclusão da coluna auxiliar (row_num) utilizada no processo de limpeza.








