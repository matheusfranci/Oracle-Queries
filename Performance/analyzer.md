## Explicação do Procedimento para Utilização do SQL Tuning Advisor

Este procedimento demonstra como utilizar o SQL Tuning Advisor no Oracle Database para obter recomendações de otimização para uma consulta SQL específica. Ele envolve identificar a consulta, executar o advisor, visualizar o relatório e, opcionalmente, implementar as recomendações através da criação de um SQL Profile.

**Passo 1: Identificar a Query**

A primeira etapa é identificar a `SQL_ID` da consulta que você deseja otimizar. A seguinte consulta busca essa informação na visão `gv$session` (visão global de sessões ativas):

```sql
select sql_id, status, last_call_et
from gv$session
where osuser = 'C088954' ;
```

* **`sql_id`**: Identificador único da consulta SQL que está sendo executada pela sessão.
* **`status`**: Status atual da sessão (e.g., `ACTIVE`, `INACTIVE`).
* **`last_call_et`**: Tempo decorrido (em segundos) desde a última chamada feita pela sessão.
* **`where osuser = 'C088954'`**: Filtra as sessões para encontrar aquelas associadas ao usuário do sistema operacional 'C088954'. Você deve substituir este valor pelo `osuser` da sessão que está executando a consulta de interesse.

**Objetivo:** Executar esta consulta para encontrar o `sql_id` da consulta que você deseja otimizar.

**Passo 2: Executar o SQL Tuning Advisor**

O bloco PL/SQL a seguir cria e executa uma tarefa do SQL Tuning Advisor para a `SQL_ID` especificada.

```sql
DECLARE
    V_SQL_ID        VARCHAR2(128) := 'dazmk9kh5g5hm'; -- Substitua pela SQL_ID identificada no Passo 1
    V_TASK_NAME     VARCHAR2(30) := UPPER('TSK_' || V_SQL_ID);
    V_SQL_TEXT      CLOB;
    V_USER_NAME     VARCHAR2(30);
BEGIN
    -- Tenta remover uma tarefa de tuning existente com o mesmo nome
    BEGIN
        DBMS_SQLTUNE.DROP_TUNING_TASK(TASK_NAME => V_TASK_NAME);
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- Ignora erros se a tarefa não existir
    END;

    -- Obtém o texto SQL e o nome do schema de parsing da GV$SQLAREA (memória)
    BEGIN
        SELECT SQL_FULLTEXT
             ,PARSING_SCHEMA_NAME
        INTO V_SQL_TEXT
             ,V_USER_NAME
        FROM GV$SQLAREA
       WHERE SQL_ID = V_SQL_ID
         AND ROWNUM <= 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Se não encontrar na memória, tenta buscar no AWR
            -- Obtém o texto SQL do DBA_HIST_SQLTEXT (AWR)
            SELECT SQL_TEXT
              INTO V_SQL_TEXT
              FROM DBA_HIST_SQLTEXT
             WHERE SQL_ID = V_SQL_ID;
            -- Obtém o nome do schema de parsing do DBA_HIST_SQLSTAT (AWR)
            SELECT DISTINCT PARSING_SCHEMA_NAME
              INTO V_USER_NAME
              FROM DBA_HIST_SQLSTAT
             WHERE SQL_ID = V_SQL_ID;
             --AND PARSING_SCHEMA_NAME='DTGBACKOFFP1'; -- Linha comentada para possível filtro de schema
    END;

    -- Cria a tarefa de tuning
    V_TASK_NAME := DBMS_SQLTUNE.CREATE_TUNING_TASK(SQL_TEXT => V_SQL_TEXT
                                                 -- ,BIND_LIST => -- Para especificar valores de bind variables (opcional)
                                                 ,USER_NAME  => V_USER_NAME
                                                 ,SCOPE      => 'COMPREHENSIVE' -- Nível de análise (BASIC, TYPICAL, COMPREHENSIVE)
                                                 ,TIME_LIMIT => 3600     -- Tempo máximo de execução da tarefa (em segundos)
                                                 ,TASK_NAME  => V_TASK_NAME
                                                 ,DESCRIPTION => UPPER(V_SQL_ID));

    -- Executa a tarefa de tuning
    DBMS_SQLTUNE.EXECUTE_TUNING_TASK(TASK_NAME => V_TASK_NAME);
END;
/
```

* **`V_SQL_ID`**: Uma variável para armazenar a `SQL_ID` da consulta a ser analisada. **Você deve substituir o valor `'dazmk9kh5g5hm'` pela `SQL_ID` que você identificou no Passo 1.**
* **`V_TASK_NAME`**: Uma variável para gerar um nome único para a tarefa de tuning.
* **`V_SQL_TEXT`**: Uma variável para armazenar o texto completo da consulta SQL. O script tenta obtê-lo primeiro da memória (`GV$SQLAREA`) e, se não encontrar, do AWR (`DBA_HIST_SQLTEXT`).
* **`V_USER_NAME`**: Uma variável para armazenar o nome do schema de parsing da consulta. O script tenta obtê-lo da memória (`GV$SQLAREA`) e, se não encontrar, do AWR (`DBA_HIST_SQLSTAT`).
* **`DBMS_SQLTUNE.DROP_TUNING_TASK`**: Tenta remover qualquer tarefa de tuning existente com o mesmo nome para evitar conflitos.
* **`DBMS_SQLTUNE.CREATE_TUNING_TASK`**: Cria uma nova tarefa de tuning com as seguintes opções:
    * **`SQL_TEXT`**: O texto da consulta SQL a ser analisada.
    * **`USER_NAME`**: O schema sob o qual a consulta é executada.
    * **`SCOPE`**: O nível de análise que o advisor deve realizar (`COMPREHENSIVE` realiza uma análise mais completa).
    * **`TIME_LIMIT`**: O tempo máximo (em segundos) que o advisor pode levar para analisar a consulta.
    * **`TASK_NAME`**: O nome da tarefa de tuning.
    * **`DESCRIPTION`**: Uma descrição para a tarefa.
* **`DBMS_SQLTUNE.EXECUTE_TUNING_TASK`**: Inicia a execução da tarefa de tuning criada.

**Objetivo:** Executar este bloco PL/SQL para iniciar a análise da sua consulta pelo SQL Tuning Advisor.

**Passo 3: Visualizar o Relatório do Advisor**

Após a conclusão da tarefa de tuning, você pode visualizar o relatório gerado pelo advisor com a seguinte consulta:

```sql
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK(UPPER('TSK_dazmk9kh5g5hm')) FROM DUAL;
```

* **`DBMS_SQLTUNE.REPORT_TUNING_TASK`**: Função que gera um relatório detalhado com as descobertas e recomendações do SQL Tuning Advisor para a tarefa especificada.
* **`UPPER('TSK_dazmk9kh5g5hm')`**: O nome da tarefa de tuning que você criou no Passo 2. **Certifique-se de substituir `'TSK_dazmk9kh5g5hm'` pelo nome real da tarefa que foi criada (que será `TSK_` seguido da `SQL_ID` em maiúsculo).**

**Objetivo:** Executar esta consulta para visualizar as recomendações do SQL Tuning Advisor para a sua consulta. O relatório pode incluir sugestões como criação de índices, reescrita da consulta ou criação de SQL Profiles.

**Passo 4: Implementar as Recomendações (Exemplo: Aceitar um SQL Profile)**

Se o SQL Tuning Advisor recomendar a criação de um SQL Profile, você pode implementá-lo utilizando um bloco PL/SQL semelhante ao seguinte (o nome da tarefa e do perfil serão diferentes no seu caso):

```sql
BEGIN
    DBMS_SQLTUNE.ACCEPT_SQL_PROFILE(TASK_NAME => 'TSK_7azfbzankbt62', -- Substitua pelo nome da sua tarefa
                                     REPLACE   => TRUE,        -- Permite substituir um perfil existente com o mesmo nome
                                     CATEGORY  => 'DEFAULT',
                                     NAME      => 'SQLPFL_7AZFBZANKBT62', -- Substitua pelo nome sugerido no relatório
                                     FORCE_MATCH => TRUE);      -- Controla como o perfil é aplicado a consultas semelhantes
END;
/
```

* **`DBMS_SQLTUNE.ACCEPT_SQL_PROFILE`**: Procedimento para implementar uma recomendação de SQL Profile gerada pelo advisor.
* **`TASK_NAME`**: O nome da tarefa de tuning da qual a recomendação foi gerada. **Substitua `'TSK_7azfbzankbt62'` pelo nome da sua tarefa.**
* **`REPLACE`**: Se definido como `TRUE`, um perfil existente com o mesmo nome será substituído.
* **`CATEGORY`**: A categoria do SQL Profile.
* **`NAME`**: O nome que será dado ao SQL Profile. **Substitua `'SQLPFL_7AZFBZANKBT62'` pelo nome sugerido no relatório do advisor.**
* **`FORCE_MATCH`**: Se definido como `TRUE`, o SQL Profile pode ser aplicado a consultas semelhantes mesmo que tenham literais diferentes.

**Objetivo:** Executar este bloco PL/SQL (após revisar o relatório do advisor e substituir os nomes adequados) para criar um SQL Profile que influencia o otimizador a escolher um plano de execução mais eficiente para a sua consulta.

**Observações:**

* A utilização do SQL Tuning Advisor e a criação de SQL Profiles requer a licença do Oracle Tuning Pack.
* É importante revisar cuidadosamente o relatório do SQL Tuning Advisor antes de aceitar qualquer recomendação.
* Os nomes das tarefas (`TASK_NAME`) e dos SQL Profiles (`NAME`) gerados pelo advisor podem variar. Consulte o relatório para obter os valores corretos para o seu caso.
* O parâmetro `FORCE_MATCH` no `ACCEPT_SQL_PROFILE` deve ser usado com cautela, pois pode afetar outras consultas semelhantes.

Este procedimento fornece um guia passo a passo para utilizar o SQL Tuning Advisor para analisar e potencialmente otimizar consultas SQL no Oracle Database. Lembre-se de adaptar os valores de `SQL_ID` e os nomes das tarefas e perfis de acordo com o seu ambiente e as recomendações do advisor.
