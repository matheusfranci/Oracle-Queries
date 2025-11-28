## 1\. Identificar o `SQL_ID`

O primeiro passo é descobrir o identificador único da query que está performando mal.

**Cenário:** Você acabou de executar a query lenta na sua sessão atual. Imediatamente após a execução (ou cancelamento), execute o script abaixo para capturar o ID.

```sql
-- Descobre o SQL_ID da última query executada na sessão atual
SELECT 
    sql_id, 
    prev_sql_id 
FROM v$session 
WHERE sid = SYS_CONTEXT('USERENV', 'SID');
```

> **Nota:** O `prev_sql_id` geralmente refere-se à última instrução SQL completa executada antes da consulta atual.

-----

## 2\. Validar o Texto da SQL

Antes de rodar o tuning, é crucial confirmar se o `SQL_ID` capturado refere-se realmente à query desejada. O script abaixo reconstrói o texto completo da SQL, concatenando as partes fragmentadas.

Substitua `'SEU_SQL_ID_AQUI'` pelo ID encontrado no passo anterior.

```sql
SELECT 
    sql_id,
    LISTAGG(sql_text, '') WITHIN GROUP (ORDER BY piece) AS sql_full_text
FROM 
    v$sqltext
WHERE 
    sql_id IN ('SEU_SQL_ID_AQUI') -- Ex: '7brx09vm3hn0y'
GROUP BY 
    sql_id;
```

-----

## 3\. Executar o SQL Tuning Advisor

Este bloco PL/SQL automatiza a criação e execução de uma tarefa de tuning (`Tuning Task`).

**O que este script faz:**

1.  **Limpeza:** Remove tarefas antigas com o mesmo nome para evitar erros.
2.  **Busca Inteligente:** Tenta encontrar o texto da SQL na memória (`GV$SQLAREA`). Se não encontrar (porque o cache foi limpo), busca no histórico do AWR (`DBA_HIST_SQLTEXT`).
3.  **Configuração:** Cria a tarefa com escopo `COMPREHENSIVE` (abrangente) e limite de tempo de 30 minutos (1800 segundos).
4.  **Execução:** Roda a análise.

Ao executar, será solicitado o valor para a variável `&SQLID`.

```sql
DECLARE
    V_SQL_ID    VARCHAR2(128) := '&SQLID'; -- Insira o SQL_ID aqui
    V_TASK_NAME VARCHAR2(30) := UPPER('TSK_' || V_SQL_ID);
    V_SQL_TEXT  CLOB;
    V_USER_NAME VARCHAR2(30);
BEGIN
    -- 1. Tenta apagar a tarefa anterior se existir para evitar conflitos
    BEGIN
        DBMS_SQLTUNE.DROP_TUNING_TASK(TASK_NAME => V_TASK_NAME);
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- Ignora erro se a tarefa não existir
    END;

    -- 2. Busca o texto da SQL e o schema (usuário)
    BEGIN
        -- Tenta buscar na memória ativa (SGA)
        SELECT SQL_FULLTEXT, PARSING_SCHEMA_NAME
        INTO V_SQL_TEXT, V_USER_NAME
        FROM GV$SQLAREA
        WHERE SQL_ID = V_SQL_ID AND ROWNUM <= 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Se não encontrar na memória, busca no histórico (AWR)
            SELECT SQL_TEXT INTO V_SQL_TEXT
            FROM DBA_HIST_SQLTEXT
            WHERE SQL_ID = V_SQL_ID;

            SELECT DISTINCT PARSING_SCHEMA_NAME INTO V_USER_NAME
            FROM DBA_HIST_SQLSTAT
            WHERE SQL_ID = V_SQL_ID AND ROWNUM <= 1;
    END;

    -- 3. Cria a tarefa de otimização
    V_TASK_NAME := DBMS_SQLTUNE.CREATE_TUNING_TASK(
        SQL_TEXT    => V_SQL_TEXT,
        USER_NAME   => V_USER_NAME,
        SCOPE       => 'COMPREHENSIVE',
        TIME_LIMIT  => 1800, -- Limite de 30 minutos
        TASK_NAME   => V_TASK_NAME,
        DESCRIPTION => 'Tuning para SQL_ID: ' || V_SQL_ID
    );

    -- 4. Executa a tarefa
    DBMS_SQLTUNE.EXECUTE_TUNING_TASK(TASK_NAME => V_TASK_NAME);
END;
/
```

-----

## 4\. Gerar e Analisar o Relatório

Após a conclusão do bloco PL/SQL, gere o relatório de recomendações. Ele mostrará sugestões como criação de índices, perfis SQL (SQL Profiles) ou coleta de estatísticas.

```sql
-- Exibe o relatório detalhado
SET LONG 1000000;
SET PAGESIZE 1000;
SET LINESIZE 200;

SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK(UPPER('TSK_&SQLID')) FROM DUAL;
```

### O que procurar no relatório?

  * **SQL Profile:** Se o Oracle sugerir aceitar um *SQL Profile*, verifique a melhoria de performance estimada.
  * **Index Recommendations:** Avalie se a criação do índice sugerido impactará outras rotinas de escrita (INSERT/UPDATE).
  * **Statistics:** Verifique se as estatísticas das tabelas envolvidas estão desatualizadas.
