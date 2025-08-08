### 🚀 Script PL/SQL para Otimização de SQL

Este é um script PL/SQL que utiliza o **SQL Tuning Advisor** do Oracle para analisar e otimizar uma consulta SQL específica. Ele cria uma tarefa de otimização, executa a análise e, opcionalmente, mostra como visualizar o relatório de recomendações. É uma ferramenta essencial para melhorar o desempenho de queries lentas.

#### 🎯 Objetivo

Criar uma tarefa de otimização de SQL (SQL Tuning Task) para uma consulta com base em seu `SQL_ID`, executá-la e fornecer instruções para ver o relatório de resultados. A análise pode sugerir novos índices, planos de execução, ou perfis de SQL.

#### 📋 Script PL/SQL

```plsql
DECLARE
    V_SQL_ID    VARCHAR2(128) := '&SQLID';
    V_TASK_NAME VARCHAR2(30) := UPPER('TSK_' || V_SQL_ID);
    V_SQL_TEXT  CLOB;
    V_USER_NAME VARCHAR2(30);
BEGIN
    -- 1. Tenta apagar a tarefa anterior se existir
    BEGIN
        DBMS_SQLTUNE.DROP_TUNING_TASK(TASK_NAME => V_TASK_NAME);
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    -- 2. Busca o texto da SQL nas visões de desempenho
    BEGIN
        SELECT SQL_FULLTEXT, PARSING_SCHEMA_NAME
        INTO V_SQL_TEXT, V_USER_NAME
        FROM GV$SQLAREA
        WHERE SQL_ID = V_SQL_ID AND ROWNUM <= 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Se não encontrar na visão atual, busca no histórico
            SELECT SQL_TEXT INTO V_SQL_TEXT
            FROM DBA_HIST_SQLTEXT
            WHERE SQL_ID = V_SQL_ID;

            SELECT DISTINCT PARSING_SCHEMA_NAME INTO V_USER_NAME
            FROM DBA_HIST_SQLSTAT
            WHERE SQL_ID = V_SQL_ID;
    END;

    -- 3. Cria a tarefa de otimização com um escopo abrangente (COMPREHENSIVE)
    V_TASK_NAME := DBMS_SQLTUNE.CREATE_TUNING_TASK(SQL_TEXT  => V_SQL_TEXT,
                                                 USER_NAME   => V_USER_NAME,
                                                 SCOPE       => 'COMPREHENSIVE',
                                                 TIME_LIMIT  => 1800,
                                                 TASK_NAME   => V_TASK_NAME,
                                                 DESCRIPTION => UPPER(V_SQL_ID));

    -- 4. Executa a tarefa de otimização
    DBMS_SQLTUNE.EXECUTE_TUNING_TASK(TASK_NAME => V_TASK_NAME);
END;
/
```

#### 🖥️ Como Usar

1.  **Copie e Cole:** Cole o código acima em sua ferramenta de SQL (SQL Developer, SQL Plus, etc.).
2.  **Forneça o SQL\_ID:** Quando o script solicitar o `&SQLID`, insira o ID da consulta que você quer otimizar.
3.  **Execute:** O script criará e executará a tarefa de otimização em segundo plano.
4.  **Visualize o Relatório:** Após a execução, use o comando abaixo para ver as recomendações do Oracle.

<!-- end list -->

```sql
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK(UPPER('TSK_&SQLID')) FROM DUAL;
```

```sql
execute dbms_sqltune.accept_sql_profile(task_name => 'TSK_1P8YZR0F0V56N', task_owner => 'GEBAP', replace => TRUE);
```
