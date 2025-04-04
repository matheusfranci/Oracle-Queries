## Consulta SQL para Análise de Desempenho por Snapshot (com Código)

Esta consulta SQL tem como objetivo analisar o desempenho de uma consulta específica (identificada pelo `SQL_ID`) ao longo do tempo, utilizando dados históricos do Automatic Workload Repository (AWR) do Oracle Database. Ela agrega métricas de desempenho por snapshot, instância (node em um ambiente RAC), e plano de execução.

```sql
select node,snap_id,sql_id, plan_hash_value,
sum(execs) execs,
-- sum(etime) etime,
round(sum(etime)/sum(execs),5) avg_etime,
round(sum(cpu_time)/sum(execs),5) avg_cpu_time,
round(sum(lio)/sum(execs),5) avg_lio,
round(sum(pio)/sum(execs),5) avg_pio,
begin_interval_time,
end_interval_time
from (
select ss.snap_id, ss.instance_number node, begin_interval_time, end_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
elapsed_time_delta/1000000 etime,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
buffer_gets_delta lio,
disk_reads_delta pio,
cpu_time_delta/1000000 cpu_time,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio,
(cpu_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta)) avg_cpu_time
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where ---PARSING_SCHEMA_NAME = 'ZLCONECTIVIDADEP1'
sql_id = 'cufp4d16nyrmc'
--plan_hash_value = 3522518265
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and  executions_delta > 0
--and elapsed_time_delta > 0
)
group by  node, snap_id,sql_id, plan_hash_value, begin_interval_time, end_interval_time
order by begin_interval_time  DESC
/
```

**Objetivo Principal:**

Monitorar como o desempenho de uma determinada consulta varia entre diferentes snapshots do AWR, permitindo identificar tendências, regressões ou melhorias de performance.

**Componentes da Consulta:**

1.  **Subconsulta (Inner Query):**
    * Seleciona dados das visões `DBA_HIST_SQLSTAT` (estatísticas de SQL por snapshot) e `DBA_HIST_SNAPSHOT` (informações dos snapshots).
    * Filtra os dados para um `SQL_ID` específico (`'cufp4d16nyrmc'` neste caso). A linha comentada `--plan_hash_value = 3522518265` indica que também seria possível filtrar por um plano de execução específico.
    * Realiza o join entre as duas visões pelas colunas `snap_id` e `instance_number` para associar as estatísticas SQL ao snapshot correto e à instância correta.
    * Calcula as métricas de desempenho *delta* (a diferença entre o snapshot atual e o anterior) para:
        * `execs`: Número de execuções (`executions_delta`).
        * `etime`: Tempo decorrido total em segundos (`elapsed_time_delta / 1000000`).
        * `avg_etime`: Tempo médio de execução em segundos. A divisão por `decode(nvl(executions_delta,0),0,1,executions_delta)` evita divisão por zero caso não haja execuções no delta.
        * `lio`: Número de blocos lógicos lidos (`buffer_gets_delta`).
        * `pio`: Número de blocos físicos lidos (`disk_reads_delta`).
        * `cpu_time`: Tempo de CPU utilizado em segundos (`cpu_time_delta / 1000000`).
        * `avg_lio`: Número médio de blocos lógicos lidos por execução.
        * `avg_cpu_time`: Tempo médio de CPU por execução.
    * Filtra para incluir apenas snapshots onde houve um aumento no número de execuções (`executions_delta > 0`). A linha comentada `--and elapsed_time_delta > 0` sugere que também seria possível filtrar por snapshots com variação positiva no tempo decorrido.
    * Seleciona também as colunas `begin_interval_time` e `end_interval_time` da tabela de snapshots para indicar o período coberto por cada snapshot.
    * Renomeia `ss.instance_number` para `node` para representar a instância do banco de dados.

3.  **Consulta Principal (Outer Query):**
    * Agrupa os resultados da subconsulta por `node`, `snap_id`, `sql_id`, `plan_hash_value`, `begin_interval_time` e `end_interval_time`. Isso agrega as métricas delta para cada combinação única dessas colunas dentro de um snapshot.
    * Calcula as seguintes métricas agregadas:
        * `sum(execs)`: Número total de execuções para a combinação de agrupamento.
        * `round(sum(etime)/sum(execs),5) avg_etime`: Tempo médio de execução para a combinação de agrupamento (total de tempo decorrido dividido pelo total de execuções, arredondado para 5 casas decimais).
        * `round(sum(cpu_time)/sum(execs),5) avg_cpu_time`: Tempo médio de CPU por execução.
        * `round(sum(lio)/sum(execs),5) avg_lio`: Número médio de blocos lógicos lidos por execução.
        * `round(sum(pio)/sum(execs),5) avg_pio`: Número médio de blocos físicos lidos por execução.
    * Seleciona as colunas de agrupamento `node`, `snap_id`, `sql_id`, `plan_hash_value`, `begin_interval_time` e `end_interval_time`.
    * Ordena os resultados por `begin_interval_time` em ordem decrescente, mostrando os snapshots mais recentes primeiro.

**Interpretação dos Resultados:**

Cada linha do resultado representa um snapshot específico (e uma instância, em ambientes RAC) e mostra:

* **`node`**: A instância do banco de dados.
* **`snap_id`**: O identificador do snapshot do AWR.
* **`sql_id`**: O identificador da consulta SQL analisada.
* **`plan_hash_value`**: O valor hash do plano de execução que estava ativo durante esse snapshot.
* **`execs`**: O número de vezes que a consulta foi executada durante o intervalo do snapshot.
* **`avg_etime`**: O tempo médio de execução da consulta em segundos durante o intervalo do snapshot.
* **`avg_cpu_time`**: O tempo médio de CPU utilizado pela consulta em segundos por execução.
* **`avg_lio`**: O número médio de blocos lógicos lidos por execução. Um valor alto pode indicar ineficiência no acesso aos dados na memória (buffer cache).
* **`avg_pio`**: O número médio de blocos físicos lidos do disco por execução. Um valor alto pode indicar que os dados necessários não estão presentes na memória e estão causando leituras de disco, o que é geralmente mais lento.
* **`begin_interval_time`**: O timestamp de início do intervalo do snapshot.
* **`end_interval_time`**: O timestamp de fim do intervalo do snapshot.

**Utilização:**

Ao executar esta consulta, você pode observar como as métricas de desempenho da consulta `'cufp4d16nyrmc'` (ou outra que você especificar) variam ao longo do tempo. Isso pode ajudar a:

* Identificar se o desempenho da consulta piorou ou melhorou em snapshots recentes.
* Correlacionar mudanças de desempenho com eventos no sistema (implantações de código, alterações de configuração, etc.) observando os timestamps dos snapshots.
* Analisar se diferentes planos de execução (indicados pelo `plan_hash_value`) estão associados a diferentes níveis de desempenho.
* Obter uma visão histórica do consumo de recursos (tempo de execução, CPU, I/O) pela consulta.

Para analisar o desempenho de outra consulta, basta substituir o valor `'cufp4d16nyrmc'` na cláusula `WHERE` da subconsulta pelo `SQL_ID` desejado. Para analisar um plano específico, descomente e ajuste a linha com a condição de `plan_hash_value`.
