### 📈 Relatório de Análise de Custo de Consultas SQL

Esta consulta SQL é um relatório de **custo e impacto** das consultas que estão sendo executadas no banco de dados. Ela ajuda a identificar quais queries estão consumindo a maior parte dos recursos, como tempo de execução e tempo de CPU.

#### 🎯 Objetivo

Identificar as consultas SQL que são os maiores "vilões" de desempenho no banco de dados. A consulta calcula o tempo total de execução e CPU de todas as consultas e, em seguida, mostra a porcentagem que cada consulta individual representa, facilitando a priorização de otimizações.

#### 📋 Consulta SQL

```sql
WITH
TOT AS (
    SELECT SUM(ELAPSED_TIME) ELAPSED_TIME_TOTAL,
           SUM(CPU_TIME) CPU_TIME_TOTAL
    FROM GV$SQL
),
SQ AS (
    SELECT SQL_ID,
           SUM(ELAPSED_TIME) ELAPSED_TIME,
           SUM(CPU_TIME) CPU_TIME,
           SUM(ROWS_PROCESSED) ROWS_PROCESSED,
           SUM(DISK_READS) DISK_READS,
           SUM(BUFFER_GETS) BUFFER_GETS,
           MAX(LAST_ACTIVE_TIME) LAST_ACTIVE_TIME,
           SUM(EXECUTIONS) EXECUTIONS,
           SUM(CONCURRENCY_WAIT_TIME) CONCURRENCY_WAIT_TIME,
           SUM(CLUSTER_WAIT_TIME) CLUSTER_WAIT_TIME
    FROM GV$SQLAREA
    GROUP BY SQL_ID
),
SQA AS (
    SELECT DISTINCT SQL_ID,
           PARSING_SCHEMA_NAME,
           SQL_TEXT
    FROM GV$SQLAREA
)
SELECT SQ.SQL_ID,
       (100 * ELAPSED_TIME) / (SELECT TOT.ELAPSED_TIME_TOTAL FROM TOT) PERC_ELAPSED_TIME,
       (100 * CPU_TIME) / (SELECT TOT.CPU_TIME_TOTAL FROM TOT) PERC_CPU_TIME,
       PARSING_SCHEMA_NAME,
       EXECUTIONS,
       SQL_TEXT,
       TRIM(TO_CHAR(((ELAPSED_TIME + CPU_TIME) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) / 1000000), '99,990.0000')) PER_EXEC_ELA_TIME,
       TRIM(TO_CHAR(((CPU_TIME) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) / 1000000), '99,990.0000')) PER_EXEC_CPU_TIME,
       TRIM(TO_CHAR(((CLUSTER_WAIT_TIME) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) / 1000000), '99,990.0000')) PER_EXEC_CLUSTER_WAIT_TIME,
       TRIM(TO_CHAR(((CONCURRENCY_WAIT_TIME) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) / 1000000), '99,990.0000')) PER_EXEC_CONCURRENCY_WAIT_TIME,
       ELAPSED_TIME,
       ROWS_PROCESSED,
       DISK_READS,
       BUFFER_GETS,
       CPU_TIME,
       LAST_ACTIVE_TIME
FROM SQ, SQA
WHERE SQ.SQL_ID = SQA.SQL_ID
ORDER BY PERC_ELAPSED_TIME DESC;
```
