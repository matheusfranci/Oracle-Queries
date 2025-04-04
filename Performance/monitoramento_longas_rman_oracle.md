# Monitoramento de Sessões de Longa Duração e Sessões RMAN no Oracle

Este documento descreve dois scripts SQL úteis para monitorar o progresso de operações de longa duração e identificar sessões relacionadas ao RMAN (Recovery Manager) em um banco de dados Oracle.

## 1. Monitorando Operações de Longa Duração

Este script consulta a视图 dinâmica `gv$Session_longops` para exibir informações sobre operações que levam um tempo considerável para serem concluídas.

```sql
SELECT INST_ID, SID, serial#,
decode(totalwork, 0, 0, round(100 * sofar / totalwork, 2)) "Percent",
message "Message",
start_time,
round(elapsed_seconds / 60, 2) "Em execucao(Min)",
round(time_remaining / 60, 2) "Tempo restante(Min)",
round(((elapsed_seconds + time_remaining) / 60), 2) "Tempo Total"
from gv$Session_longops
where decode(totalwork, 0, 0, round(100 * sofar / totalwork, 2)) <> 100
ORDER BY "Percent", SID
;
```

### Explicação das Colunas:

* **INST\_ID**: Identificador da instância (útil em ambientes RAC - Real Application Clusters).
* **SID**: ID da sessão.
* **serial#**: Número de série da sessão.
* **Percent**: Percentual de conclusão da operação (calculado como `(sofar / totalwork) * 100`).
* **Message**: Descrição da operação de longa duração em andamento.
* **start\_time**: Hora de início da operação.
* **Em execucao(Min)**: Tempo decorrido em minutos desde o início da operação.
* **Tempo restante(Min)**: Tempo estimado restante em minutos para a conclusão da operação.
* **Tempo Total**: Tempo total estimado em minutos para a conclusão da operação.

### Funcionalidade:

* A função `decode(totalwork, 0, 0, round(100 * sofar / totalwork, 2))` lida com casos onde `totalwork` é zero, evitando divisão por zero e exibindo 0% nesses casos. Caso contrário, calcula o percentual de conclusão e o arredonda para duas casas decimais.
* A cláusula `WHERE decode(totalwork, 0, 0, round(100 * sofar / totalwork, 2)) <> 100` filtra as operações que ainda não foram concluídas (ou seja, com um percentual inferior a 100%).
* A cláusula `ORDER BY "Percent", SID` ordena os resultados primeiro pelo percentual de conclusão (em ordem crescente) e, em seguida, pelo ID da sessão.

### Utilização:

Execute este script em uma ferramenta SQL conectada ao seu banco de dados Oracle para visualizar o progresso de operações como backups, restaurações, criação de índices, etc.

## 2. Identificando Sessões RMAN

Este script consulta a视图 `v$session` para listar sessões onde o módulo (geralmente definido pela aplicação) contém a string 'rman%', indicando sessões relacionadas ao Oracle Recovery Manager.

```sql
col username format a10
col wait_class format a30
col event format a80
col sql_id format a30
col module format a50
col Message format a100
set lines 400
set pagesize 40

select username, sid, sql_id, module, wait_class, event from v$session where module like 'rman%' ;
```

### Explicação das Colunas e Comandos de Formatação:

* **`col username format a10`**: Define a largura da coluna `username` para 10 caracteres.
* **`col wait_class format a30`**: Define a largura da coluna `wait_class` para 30 caracteres.
* **`col event format a80`**: Define a largura da coluna `event` para 80 caracteres.
* **`col sql_id format a30`**: Define a largura da coluna `sql_id` para 30 caracteres.
* **`col module format a50`**: Define a largura da coluna `module` para 50 caracteres.
* **`col Message format a100`**: Define a largura da coluna `Message` para 100 caracteres.
* **`set lines 400`**: Define o número de caracteres por linha na saída para 400.
* **`set pagesize 40`**: Define o número de linhas por página na saída para 40.
* **username**: Nome do usuário da sessão.
* **sid**: ID da sessão.
* **sql\_id**: Identificador da instrução SQL atualmente em execução (se houver).
* **module**: Módulo da aplicação que iniciou a sessão (geralmente indica 'RMAN' para sessões de backup/restore).
* **wait\_class**: Classe do evento de espera atual da sessão.
* **event**: Nome do evento de espera atual da sessão.

### Funcionalidade:

* A cláusula `WHERE module like 'rman%'` filtra as sessões onde a coluna `module` começa com 'rman', identificando processos de backup, restore ou outras operações gerenciadas pelo RMAN.

### Utilização:

Execute este script para obter uma visão rápida das sessões RMAN ativas no seu banco de dados, permitindo monitorar o status e identificar possíveis gargalos. As informações sobre `wait_class` e `event` podem ser cruciais para diagnosticar problemas de performance relacionados ao RMAN.

Este documento fornece uma visão geral dos scripts e suas funcionalidades. Utilize-os para monitorar a saúde e o progresso de tarefas importantes no seu ambiente Oracle.
