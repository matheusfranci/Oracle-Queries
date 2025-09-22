# Análise de Latência de Leitura de Bloco Único no Oracle (AWR)

Esta query foi desenvolvida para monitorar a performance de I/O de um banco de dados Oracle 19c, focando especificamente na métrica **"Average Synchronous Single-Block Read Latency"**. Ela extrai dados do AWR (Automatic Workload Repository) dos últimos três dias para ajudar a identificar possíveis gargalos no subsistema de armazenamento. 💾

## A Métrica: Average Synchronous Single-Block Read Latency

Essa métrica é crucial para a saúde do banco de dados. Ela mede, em média, quanto tempo o Oracle leva para ler um único bloco de dados do disco de forma síncrona. Em outras palavras, é o tempo de espera por uma operação de I/O física.

  * **O que significa?** É o tempo que uma sessão de usuário aguarda ativamente pela chegada de um bloco de dados do disco para a memória.
  * **Por que é importante?** Valores altos nesta métrica são um forte indicativo de problemas no subsistema de I/O (discos lentos, problemas na rede de armazenamento, etc.) e frequentemente causam lentidão geral no banco de dados.
  * **Valores de referência:** Geralmente, uma latência **abaixo de 10-20 milissegundos** é considerada aceitável, mas o valor ideal pode variar dependendo do hardware de armazenamento (SSD, SAN, etc.).

-----

## A Query SQL

```sql
SELECT
    metric_id,
    Metric_Name,
    Metric_Unit,
    TO_CHAR(begin_time, 'DD/MM/YYYY HH24:MI:SS') AS begin_time_formatted,
    TO_CHAR(end_time, 'DD/MM/YYYY HH24:MI:SS') AS end_time_formatted,
    average,
    MAXVAL
FROM
    DBA_HIST_SYSMETRIC_SUMMARY
WHERE
    metric_id = 2144
    AND TRUNC(begin_time) > TRUNC(SYSDATE - 4)
ORDER BY
    begin_time DESC;
```

-----

## Detalhamento da Query

### `SELECT`

A cláusula `SELECT` especifica as colunas que serão retornadas:

  * `metric_id`, `Metric_Name`, `Metric_Unit`: Identificadores da métrica para confirmação.
  * `TO_CHAR(...) AS ..._formatted`: Converte as colunas de data `begin_time` e `end_time` para um formato de texto legível (`DD/MM/YYYY HH24:MI:SS`), facilitando a análise.
  * `average`: O valor médio da latência no intervalo de tempo (`begin_time` a `end_time`).
  * `MAXVAL`: O valor máximo (pico) de latência registrado no mesmo intervalo.

### `FROM`

  * `DBA_HIST_SYSMETRIC_SUMMARY`: Esta é uma visão do dicionário de dados que armazena o histórico de métricas de sistema coletadas pelo AWR. Ela provê um resumo das métricas em intervalos de tempo específicos.

### `WHERE`

Esta cláusula filtra os dados para obter apenas a informação relevante:

  * `metric_id = 2144`: Filtra especificamente pela métrica **"Average Synchronous Single-Block Read Latency"**. Este ID é o identificador interno da métrica no Oracle.
  * `TRUNC(begin_time) > TRUNC(SYSDATE - 4)`: Esta condição filtra os registros para retornar dados **dos últimos 3 dias completos mais o dia corrente**.
      * `SYSDATE`: Retorna a data e hora atuais do servidor.
      * `SYSDATE - 4`: Subtrai 4 dias da data atual.
      * `TRUNC()`: Remove a parte de "horas/minutos/segundos" da data, deixando apenas o dia. A comparação `> TRUNC(SYSDATE - 4)` efetivamente busca dados a partir de três dias atrás.

### `ORDER BY`

  * `ORDER BY begin_time DESC`: Organiza os resultados em ordem decrescente pela data de início do intervalo. Isso garante que os dados **mais recentes apareçam primeiro**, facilitando a visualização da tendência de performance mais atual.

-----

## Como Utilizar e Interpretar os Resultados

Execute esta query em um ambiente com acesso de leitura às views do dicionário de dados (como `DBA`). O resultado mostrará uma série de registros, cada um representando um intervalo de tempo (geralmente de 1 hora, dependendo da configuração do AWR) com a latência média (`average`) e máxima (`MAXVAL`) para a leitura de bloco.

**Fique atento a:**

  * **Valores altos e consistentes:** Se a coluna `average` estiver consistentemente acima do seu baseline (ex: \> 20ms), isso indica um problema crônico de I/O.
  * **Picos esporádicos:** Se a coluna `MAXVAL` mostrar picos muito altos, isso pode indicar operações específicas (backups, queries pesadas) que estão sobrecarregando o sistema de armazenamento em momentos específicos.
  * **Tendência de aumento:** Se os valores de `average` estão crescendo ao longo do tempo, pode ser um sinal de que o seu subsistema de I/O está se aproximando do limite de sua capacidade.
