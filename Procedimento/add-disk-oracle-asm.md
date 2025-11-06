# 📝 Guia: Adicionando um Novo Disco (LUN) ao Oracle ASM

Este guia detalha o processo passo a passo para adicionar um novo disco (geralmente uma LUN provisionada pelo storage) a um diskgroup existente do Oracle Automatic Storage Management (ASM).

O processo é dividido em duas fases principais:

1.  **Nível do Sistema Operacional (OS):** Preparar o disco para o ASM usando `oracleasm`.
2.  **Nível do ASM (SQL\*Plus):** Adicionar o disco preparado ao diskgroup.

-----

## 1\. Verificação Inicial (Nível OS)

Antes de começar, verifique quais discos o Oracle ASM já reconhece.

```bash
oracleasm listdisks
```

**Saída Esperada (Exemplo):**

```
POPULISH_DATA1_D1
POPULISH_DATA1_D2
POPULISH_DATA1_D3
POPULISH_DATA1_D4
POPULISH_DATA1_D5
```

-----

## 2\. Criação do Novo Disco ASM (Nível OS)

Use o comando `oracleasm createdisk` para "carimbar" o novo dispositivo de bloco (ex: `/dev/sdn1`) com um nome ASM. Este nome é como o ASM irá identificar o disco.

> **Importante:** Certifique-se de que `/dev/sdn1` é o dispositivo correto (a nova LUN) e que ele não contém dados importantes.

```bash
# Sintaxe: oracleasm createdisk <NOME_ASM> <PATH_DO_DISPOSITIVO>
oracleasm createdisk POPULISH_DATA1_D6 /dev/sdn1
```

-----

## 3\. Validação da Criação (Nível OS)

Liste os discos novamente. O novo disco (`POPULISH_DATA1_D6`) deve aparecer na lista.

```bash
oracleasm listdisks
```

**Saída Esperada (Exemplo):**

```
POPULISH_DATA1_D1
POPULISH_DATA1_D2
POPULISH_DATA1_D3
POPULISH_DATA1_D4
POPULISH_DATA1_D5
POPULISH_DATA1_D6
```

-----

## 4\. Adicionando o Disco ao Diskgroup (Nível ASM)

Agora, mude para o usuário proprietário da Grid Infrastructure (normalmente `grid`) para se conectar à instância ASM e adicionar o disco ao diskgroup.

Conecte-se ao ASM usando SQL\*Plus:

```bash
sqlplus / as sysasm
```

Execute o comando `ALTER DISKGROUP` para adicionar o disco. O ASM o encontrará usando o prefixo `ORCL:` (ou o prefixo de scan configurado).

```sql
ALTER DISKGROUP POPULISH_DATA1 ADD DISK
  'ORCL:POPULISH_DATA1_D6' NAME POPULISH_DATA1_D6 REBALANCE Power 2;
```

**Quebra do Comando:**

  * **`ALTER DISKGROUP POPULISH_DATA1`**: Especifica qual diskgroup será modificado.
  * **`ADD DISK 'ORCL:POPULISH_DATA1_D6'`**: Informa o caminho de descoberta do disco (o nome que demos no passo 2).
  * **`NAME POPULISH_DATA1_D6`**: Define um alias (nome) para o disco *dentro* do diskgroup.
  * **`REBALANCE Power 2`**: Inicia a operação de rebalanceamento (distribuição dos dados) com uma potência (velocidade) de 2.

-----

## 5\. Monitorando o Rebalanceamento (Nível ASM)

Após adicionar o disco, o ASM iniciará o rebalanceamento dos dados. Você pode monitorar o progresso dessa operação consultando a view `v$asm_operation` (enquanto ainda estiver no SQL\*Plus).

```sql
-- Configuração de colunas para melhor visualização (opcional)
set lines 200
col OPERATION format a10
col STATE format a10

-- Query de monitoramento
select 
  OPERATION,
  STATE,
  POWER,
  ACTUAL,
  SOFAR,
  EST_WORK,
  EST_RATE,
  EST_MINUTES 
from v$asm_operation;
```

**O que observar na saída:**

  * **`OPERATION`**: Deve mostrar `REBAL` (Rebalance).
  * **`STATE`**: `RUN` (executando), `WAIT` (aguardando) ou `DONE` (concluído).
  * **`EST_MINUTES`**: Estimativa de quantos minutos faltam para a operação terminar.

Quando a query não retornar nenhuma linha, a operação de rebalanceamento estará concluída.
