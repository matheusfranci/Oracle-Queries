## Análise de Sessões Ativas no Banco de Dados Oracle

Esta query SQL tem como objetivo fornecer uma visão detalhada das sessões ativas em um banco de dados Oracle, incluindo informações sobre o status da sessão, tempo desde a última chamada, usuário, SQL em execução e outros detalhes relevantes.

```sql
SELECT
    SE.INST_ID IID, -- ID da instância do banco de dados
    DECODE(EVENT, -- Decodifica o evento de espera
        'jobq slave wait', 'zIJQ', -- Se o evento for 'jobq slave wait', exibe 'zIJQ'
        DECODE(SE.STATUS, -- Decodifica o status da sessão
            'ACTIVE', 'ACT', -- Se o status for 'ACTIVE', exibe 'ACT'
            'INACTIVE', 'INA', -- Se o status for 'INACTIVE', exibe 'INA'
            SE.STATUS -- Caso contrário, exibe o status original
        )
    ) STA, -- Status da sessão (decodificado)
    REPLACE(TO_CHAR(FLOOR(LAST_CALL_ET / 3600), '00') || ':' || -- Formata o tempo desde a última chamada (horas)
            TO_CHAR(FLOOR(MOD(LAST_CALL_ET, 3600) / 60), '00') || ':' || -- Formata o tempo desde a última chamada (minutos)
            TO_CHAR(MOD(MOD(LAST_CALL_ET, 3600), 60), '00'), -- Formata o tempo desde a última chamada (segundos)
            ' ', NULL) L_S, -- Tempo desde a última chamada (HH:MM:SS)
    NVL(SE.USERNAME, PR.PROGRAM) USERNAME, -- Nome do usuário da sessão ou programa
    OSUSER, -- Usuário do sistema operacional
    '''' || SE.SID || ',' || SE.SERIAL# || '''' SID_SERIAL, -- SID e número de série da sessão
    HASH_VALUE SQL_HSH, -- Hash do SQL em execução
    SQ.SQL_ID, -- ID do SQL em execução
    -- SQ.CHILD_NUMBER CN, -- Número filho do SQL (comentado)
    EXECUTIONS SQL_EXE, -- Número de execuções do SQL
    ROUND(((ELAPSED_TIME + CPU_TIME) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) / 1000000), 5) SQL_ELA, -- Tempo de execução do SQL (em segundos)
    SQL_PROFILE, -- Nome do perfil SQL
    -- SQL_PLAN_BASELINE, -- Baseline do plano SQL (comentado)
    PLAN_HASH_VALUE, -- Hash do plano de execução
    SQL_TEXT, -- Texto do SQL
    SE.PREV_SQL_ID, -- ID do SQL anterior
    PR.SPID || ' (' || PR.PROGRAM || ')' SPID_PROGRAM, -- SPID do processo e programa
    (SELECT MAX('(' || LON.OPNAME || ') (' || LON.SOFAR || '->' || LON.TOTALWORK || ') : ' || LON.TARGET) -- Informações de operações de longa duração
     FROM V$SESSION_LONGOPS LON
     WHERE LON.SID = SE.SID
       AND LON.SQL_HASH_VALUE = SE.SQL_HASH_VALUE
       AND SOFAR < TOTALWORK) LO, -- Operações de longa duração
    ' (#W : ' || RPAD(SEQ#, 5) || ' | ST : ' || -- Informações de espera
    DECODE(WAIT_TIME, 0, 'WAIT', -1, 'FAST', -2, 'UNKN', WAIT_TIME) || ') ' || EVENT W, -- Evento de espera
    SE.BLOCKING_SESSION, -- Sessão bloqueadora
    SE.SECONDS_IN_WAIT, -- Segundos em espera
    SE.TERMINAL, -- Terminal
    SE.OSUSER, -- Usuário do sistema operacional
    SE.MACHINE, -- Máquina
    SE.LOGON_TIME, -- Tempo de logon
    SE.PROGRAM, -- Programa
    SE.FAILED_OVER, -- Failover
    SE.SERVER, -- Servidor
    SE.SERVICE_NAME, -- Nome do serviço
    (SELECT SQL_FULLTEXT FROM V$SQLAREA WHERE SQL_ID = SE.SQL_ID) SQL_FULLTEXT -- Texto completo do SQL
    /*
    , (SELECT OWNER || '.' || OBJECT_NAME || '(' || OBJECT_TYPE || ') - ' || SQ.PROGRAM_ID || '(' || SQ.PROGRAM_LINE# || ')' -- Informações de objeto do programa (comentado)
       FROM DBA_OBJECTS OB, V$SQL SQ
       WHERE HASH_VALUE = SE.SQL_HASH_VALUE
         AND INST_ID = SE.INST_ID
         AND CHILD_NUMBER = SE.SQL_CHILD_NUMBER
         AND OB.OBJECT_ID = SQ.PROGRAM_ID) PRG_O
    */
FROM
    GV$SESSION SE, -- Visão de sessões globais
    GV$PROCESS PR, -- Visão de processos globais
    GV$SQLAREA SQ -- Visão de área SQL global
WHERE
    SE.INST_ID = PR.INST_ID -- Junta sessões e processos pela instância
    AND SE.INST_ID = SQ.INST_ID (+) -- Junta sessões e SQL pela instância (outer join)
    AND SE.PADDR = PR.ADDR(+) -- Junta sessões e processos pelo endereço do processo (outer join)
    AND SE.SQL_ID = SQ.SQL_ID(+) -- Junta sessões e SQL pelo ID do SQL (outer join)
    AND SE.TYPE = 'USER' -- Filtra por sessões de usuário
    AND SE.STATUS IN ('ACTIVE', 'KILLED', 'PSEUDO') -- Filtra por sessões ativas, mortas ou pseudo
    -- AND SE.SID NOT IN (SELECT SID FROM V$MYSTAT) -- Exclui a própria sessão (comentado)
    -- AND SE.USERNAME IN ('ZLEMENDASP1') -- Filtra por um usuário específico (comentado)
    -- AND SE.MACHINE = 'moros' -- Filtra por uma máquina específica (comentado)
ORDER BY
    STA, -- Ordena por status
    L_S, -- Ordena por tempo desde a última chamada
    SE.USERNAME, -- Ordena por nome de usuário
    SID_SERIAL; -- Ordena por SID e número de série
```

**Explicação Detalhada:**

* **`SELECT` Clause:**
    * Seleciona várias colunas de `GV$SESSION`, `GV$PROCESS` e `GV$SQLAREA`, fornecendo informações detalhadas sobre as sessões.
    * Utiliza `DECODE` para transformar valores de status e eventos em representações mais curtas.
    * Formata o tempo desde a última chamada em `HH:MM:SS`.
    * Calcula o tempo de execução do SQL.
    * Retrieves long operation information from `V$SESSION_LONGOPS`.
    * Retrieves the full sql text from `V$SQLAREA`.
* **`FROM` Clause:**
    * Combina as visões `GV$SESSION`, `GV$PROCESS` e `GV$SQLAREA` para obter informações abrangentes.
* **`WHERE` Clause:**
    * Filtra as sessões para incluir apenas sessões de usuário e sessões ativas, mortas ou pseudo.
    * Comments out filtering by current session, username and machine.
* **`ORDER BY` Clause:**
    * Ordena os resultados por status, tempo desde a última chamada, nome de usuário e SID/serial.

**Uso:**

Esta query é útil para administradores de banco de dados (DBAs) monitorarem as sessões ativas, identificarem problemas de desempenho e diagnosticarem bloqueios.

**Observações:**

* As visões `GV$` são usadas para obter informações de todas as instâncias em um ambiente RAC (Real Application Clusters).
* The commented out sections can be used to further filter the results as needed.
* The long operation subquery provides insight into long running processes.
