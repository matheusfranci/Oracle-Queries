## Consulta para Identificar Sessões Bloqueadas no Oracle

A seguinte consulta SQL pode ser utilizada em um banco de dados Oracle para identificar e exibir informações sobre sessões que estão sendo bloqueadas por outras sessões. Essas informações podem ser úteis para diagnosticar problemas de desempenho relacionados a bloqueios no banco de dados.

```sql
SELECT DISTINCT '''' || S.SID || ',' || S.SERIAL# || ',@'||S.INST_ID|| '''' BLOCKED_SESSION,
    LPAD(' ', (LEVEL - 1) * 4, ' ') || NVL(S.USERNAME, '(ORACLE)') AS BLOCKED_USER,
    '''' || S.BLOCKING_SESSION|| ',@'||S.BLOCKING_INSTANCE|| '''' BLOCKING_SESSION,
    W.EVENT BLOCKED_EVENT,
    P.SPID BLOCKED_SPID,
    S.STATUS BLOCKED_STATUS,
    S.MODULE BLOCKED_MODULE,
    TO_CHAR(S.SQL_EXEC_START, 'DD-MON-YYYY HH24:MI:SS') AS BLOKED_SINCE
FROM GV$SESSION S, GV$SESSION_WAIT W, GV$PROCESS P
WHERE
    S.SID = W.SID
    AND S.PADDR = P.ADDR
    AND W.INST_ID = P.INST_ID
    AND S.EVENT = W.EVENT
    AND S.BLOCKING_SESSION IS NOT NULL
CONNECT BY PRIOR S.SID = S.BLOCKING_SESSION
START WITH S.BLOCKING_SESSION IS NULL ;
```

**Descrição das Colunas:**

* **`BLOCKED_SESSION`**: Identificador único da sessão bloqueada, composto por SID, SERIAL# e INST_ID.
* **`BLOCKED_USER`**: Nome de usuário da sessão bloqueada. Exibe '(ORACLE)' se o nome de usuário for nulo. A indentação indica o nível de bloqueio.
* **`BLOCKING_SESSION`**: Identificador único da sessão que está bloqueando a sessão atual.
* **`BLOCKED_EVENT`**: Evento que a sessão bloqueada está esperando.
* **`BLOCKED_SPID`**: ID do processo do sistema operacional associado à sessão bloqueada.
* **`BLOCKED_STATUS`**: Status atual da sessão bloqueada (e.g., ACTIVE, INACTIVE).
* **`BLOCKED_MODULE`**: Módulo que a sessão bloqueada está executando.
* **`BLOKED_SINCE`**: Timestamp de quando a execução da instrução SQL atual da sessão bloqueada começou.
