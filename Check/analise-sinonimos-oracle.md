```markdown
## Explicação das Queries SQL de Sinônimos

Este documento detalha duas queries SQL utilizadas para verificar e analisar sinônimos no banco de dados Oracle.

### Query 1: Validação da Existência de um Sinônimo para uma Tabela

```sql
SELECT *
FROM all_synonyms
WHERE table_name = 'TABELA_ALVO';
```

**Propósito:**

Esta query verifica se existe um sinônimo para a tabela `TABELA_ALVO`.

**Explicação:**

-   `all_synonyms`: Esta é uma view do dicionário de dados que contém informações sobre todos os sinônimos acessíveis ao usuário atual.
-   `table_name`: Coluna que especifica o nome da tabela base do sinônimo.
-   `WHERE table_name = 'TABELA_ALVO'`: Filtra os resultados para mostrar apenas os sinônimos que apontam para a tabela `TABELA_ALVO`.

**Resultado Esperado:**

A query retorna todas as informações sobre o sinônimo (se existir) que aponta para a tabela `TABELA_ALVO`. Isso inclui o nome do sinônimo, o owner do sinônimo, o owner da tabela base e o nome da tabela base.

### Query 2: Validação do Owner e Tabela Base do Sinônimo

```sql
SELECT
    synonym_name AS Sinonimo,
    owner AS "Owner do sinonimo",
    table_owner,
    table_name
FROM dba_synonyms
WHERE owner = 'OWNER_SINONIMO'
AND synonym_name = 'NOME_SINONIMO';
```

**Propósito:**

Esta query verifica o owner e a tabela base do sinônimo `NOME_SINONIMO` pertencente ao owner `OWNER_SINONIMO`.

**Explicação:**

-   `dba_synonyms`: Esta é uma view do dicionário de dados que contém informações sobre todos os sinônimos no banco de dados.
-   `synonym_name`: Coluna que especifica o nome do sinônimo.
-   `owner`: Coluna que especifica o owner do sinônimo.
-   `table_owner`: Coluna que especifica o owner da tabela base do sinônimo.
-   `table_name`: Coluna que especifica o nome da tabela base do sinônimo.
-   `WHERE owner = 'OWNER_SINONIMO'`: Filtra os resultados para mostrar apenas os sinônimos pertencentes ao owner `OWNER_SINONIMO`.
-   `AND synonym_name = 'NOME_SINONIMO'`: Filtra os resultados para mostrar apenas o sinônimo com o nome `NOME_SINONIMO`.

**Resultado Esperado:**

A query retorna o nome do sinônimo, o owner do sinônimo, o owner da tabela base e o nome da tabela base do sinônimo especificado.

**Uso:**

Estas queries são úteis para verificar a existência e a configuração de sinônimos, que são importantes para simplificar o acesso a objetos de banco de dados e para abstrair a localização desses objetos.
```
