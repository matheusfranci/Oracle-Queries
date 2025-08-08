### 🔎 Consulta para Monitoramento de Sessões Ativas

Esta consulta SQL é uma ferramenta poderosa para **monitorar e diagnosticar o desempenho** do banco de dados Oracle. Ela fornece um panorama completo das sessões ativas, ajudando a identificar gargalos, bloqueios e consultas de alto consumo de recursos.

#### 🎯 Objetivo

Obter uma visão detalhada das sessões de usuário no banco de dados, incluindo seu status, tempo de execução, SQL associada e eventos de espera. Ideal para DBAs e desenvolvedores que precisam de uma ferramenta rápida de diagnóstico.

#### 📋 Consulta SQL

```sql
SELECT
    SE.INST_ID IID,
    DECODE(EVENT,
           'jobq slave wait', 'zIJQ',
           DECODE(SE.STATUS,
                  'ACTIVE', 'ACT',
                  'INACTIVE', 'INA',
                  SE.STATUS)) STA,
    REPLACE(TO_CHAR(FLOOR(LAST_CALL_ET / 3600), '00') || ':' ||
            TO_CHAR(FLOOR(MOD(LAST_CALL_ET, 3600) / 60), '00') || ':' ||
            TO_CHAR(MOD(MOD(LAST_CALL_ET, 3600), 60), '00'), ' ', NULL) L_S,
    NVL(SE.USERNAME, PR.PROGRAM) USERNAME,
    OSUSER,
    '''' || SE.SID || ',' || SE.SERIAL# || '''' SID_SERIAL,
    HASH_VALUE SQL_HSH,
    SQ.SQL_ID,
    EXECUTIONS SQL_EXE,
    ROUND(((ELAPSED_TIME + CPU_TIME) /
           DECODE(EXECUTIONS, 0, 1, EXECUTIONS) / 1000000), 5) SQL_ELA,
    SQL_PROFILE,
    PLAN_HASH_VALUE,
    SQL_TEXT,
    SE.PREV_SQL_ID,
    PR.SPID || ' (' || PR.PROGRAM || ')' SPID_PROGRAM,
    (
        SELECT MAX('(' || LON.OPNAME || ') (' || LON.SOFAR || '->' ||
                   LON.TOTALWORK || ') : ' || LON.TARGET)
        FROM V$SESSION_LONGOPS LON
        WHERE LON.SID = SE.SID
          AND LON.SQL_HASH_VALUE = SE.SQL_HASH_VALUE
          AND SOFAR < TOTALWORK
    ) LO,
    ' (#W : ' || RPAD(SEQ#, 5) || ' | ST : ' ||
    DECODE(WAIT_TIME,
           0, 'WAIT',
           -1, 'FAST',
           -2, 'UNKN',
           WAIT_TIME) || ') ' || EVENT W,
    SE.BLOCKING_SESSION,
    SE.SECONDS_IN_WAIT,
    SE.TERMINAL,
    SE.OSUSER,
    SE.MACHINE,
    SE.LOGON_TIME,
    SE.PROGRAM,
    SE.FAILED_OVER,
    SE.SERVER,
    SE.SERVICE_NAME,
    (
        SELECT SQL_FULLTEXT
        FROM V$SQLAREA
        WHERE SQL_ID = SE.SQL_ID
    ) SQL_FULLTEXT
FROM
    GV$SESSION SE,
    GV$PROCESS PR,
    GV$SQLAREA SQ
WHERE
    SE.INST_ID = PR.INST_ID
    AND SE.INST_ID = SQ.INST_ID (+)
    AND SE.PADDR = PR.ADDR(+)
    AND SE.SQL_ID = SQ.SQL_ID(+)
    AND SE.TYPE = 'USER'
    AND SE.STATUS IN ('ACTIVE', 'KILLED', 'PSEUDO')
ORDER BY
    STA,
    L_S,
    SE.USERNAME,
    SID_SERIAL;
```
