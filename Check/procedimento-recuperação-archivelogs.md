### 1. Script para gerar o comando `restore archivelog`

```sql
SELECT 'restore archivelog from logseq  ' ||To_Char(al.sequence# -1)||  ' until logseq ' ||l.SEQUENCE#|| ' thread ' ||l.THREAD#|| ';'
  FROM v$archived_log al, v$log L
    WHERE 20306425693655 BETWEEN AL.first_change# AND AL.next_change#
      AND L.STATUS = 'CURRENT'
      AND AL.THREAD# = L.THREAD#
        ORDER BY l.thread#
        ;
```

**Explicação:**

* Este script SQL gera o comando `restore archivelog` para o RMAN.
* Ele consulta as views `v$archived_log` e `v$log` para obter informações necessárias para a construção do comando.
* A string `'restore archivelog from logseq  ' ||To_Char(al.sequence# -1)||  ' until logseq ' ||l.SEQUENCE#|| ' thread ' ||l.THREAD#|| ';'` é o comando RMAN sendo montado.
    * `restore archivelog from logseq`: Indica a operação de restauração de archive logs.
    * `To_Char(al.sequence# -1)`: Obtém o número de sequência do archive log relacionado ao SCN do erro e subtrai 1.
    * `until logseq ' ||l.SEQUENCE#`: Define o ponto final da restauração com base no número de sequência do redo log corrente.
    * `thread ' ||l.THREAD#`: Especifica o thread do log corrente.
* A cláusula `WHERE 20306425693655 BETWEEN AL.first_change# AND AL.next_change#` agora contém o SCN diretamente, eliminando a necessidade de substituição manual neste caso específico. Este SCN foi obtido do erro do CDC.
* As demais cláusulas garantem que apenas o redo log corrente do thread correto seja considerado.
* `ORDER BY l.thread#` organiza os resultados por thread.

**Como implementar:**

1.  Conecte-se ao banco de dados Oracle.
2.  Execute o script.
3.  O resultado será o comando `restore archivelog` pronto para ser usado no RMAN.

### 2. Script para estimar o tamanho dos archive logs a serem restaurados

```sql
SELECT SUM_ARCH.DAY,
       ROUND(SUM_ARCH.GENERATED_MB/1024) GENERATED_GB,
       ROUND(SUM_ARCH_DEL.DELETED_MB/1024) DELETED_GB,
       ROUND((SUM_ARCH.GENERATED_MB - SUM_ARCH_DEL.DELETED_MB)/1024) "REMAINING_GB" ,
       MAX#, MIN#, MAX#-MIN# COUNT#
  FROM (  SELECT DISTINCT TO_CHAR (FIRST_TIME, 'DD/MM/YYYY') DAY,
                 SUM (ROUND ( (BLOCKS * BLOCK_SIZE) / (1024 * 1024), 2))
                     GENERATED_MB,
                     MAX (SEQUENCE#) MAX# ,
                     MIN (SEQUENCE#) MIN#
                     FROM V$ARCHIVED_LOG
             WHERE ARCHIVED = 'YES' AND DEST_ID = 1
           GROUP BY TO_CHAR (FIRST_TIME, 'DD/MM/YYYY')) SUM_ARCH,
       (  SELECT DISTINCT TO_CHAR (FIRST_TIME, 'DD/MM/YYYY') DAY,
                 SUM (ROUND ( (BLOCKS * BLOCK_SIZE) / (1024 * 1024), 2))
                     DELETED_MB
               FROM V$ARCHIVED_LOG
             WHERE ARCHIVED = 'YES' AND DELETED = 'YES' AND DEST_ID = 1
           GROUP BY TO_CHAR (FIRST_TIME, 'DD/MM/YYYY')) SUM_ARCH_DEL
         WHERE SUM_ARCH.DAY = SUM_ARCH_DEL.DAY(+)
 ORDER BY TO_DATE (DAY, 'DD/MM/YYYY') DESC ;
```

**Explicação:**

* Este script estima o tamanho dos archive logs gerados e deletados por dia no destino de arquivamento primário.
* As subconsultas `SUM_ARCH` e `SUM_ARCH_DEL` calculam, respectivamente, o total de MB gerados e deletados, além do número máximo e mínimo de sequência para cada dia.
* A junção das subconsultas por dia permite calcular o espaço restante (`"REMAINING_GB"`).
* Os resultados são ordenados pela data em ordem decrescente.
* A informação do dia em que o problema ocorreu, obtida do CDC, pode ser usada para refinar a estimativa do tamanho dos archives a serem restaurados (`GENERATED_GB` para o dia relevante).

**Como implementar:**

1.  Conecte-se ao banco de dados Oracle.
2.  Execute o script.
3.  Analise a coluna `GENERATED_GB` para o dia correspondente ao erro no CDC para estimar o tamanho dos archive logs necessários.

### 3. Script para obter informações sobre um archive log específico

```sql
select * from v$archived_log where sequence# = '16542';
```

**Explicação:**

* Este script SQL consulta a view `v$archived_log` para obter todos os detalhes de um archive log específico, identificado pelo seu número de sequência.
* Neste caso, o número de sequência `'16542'` foi diretamente incluído, indicando que essa informação pode ser obtida do CDC para identificar um log específico para análise ou limpeza.
* **Aviso:** A menção de "limpeza única" sugere que este script pode ser usado para identificar um archive log específico que pode precisar ser removido ou verificado por algum motivo. É importante ter cautela ao realizar qualquer tipo de limpeza em archive logs.

**Como implementar:**

1.  Conecte-se ao banco de dados Oracle.
2.  Substitua `'16542'` pelo número de sequência do archive log que você deseja investigar.
3.  Execute o script para ver todos os detalhes desse archive log.

### 4. Script para validar o espaço livre no diskgroup de archive logs

```sql
SELECT
(SELECT name FROM V$DATABASE) AS "Dbname",
name as "Diskgroup",
ROUND(total_mb / 1024) as "Total_ASM(GB)",
ROUND(free_mb / 1024) as "Free_ASM(GB)",
ROUND(free_mb/total_mb*100, 2) as "Perc_Livre",
ROUND(100 - (free_mb/total_mb*100), 2) as "Perc_Ocup"
FROM v$asm_diskgroup
--WHERE name like '%ARCH%'
```

**Explicação:**

* Este script consulta a view `v$asm_diskgroup` para mostrar informações sobre todos os diskgroups ASM.
* A cláusula `WHERE name like '%ARCH%'` foi removida, o que significa que o script agora mostrará informações sobre todos os diskgroups montados na instância ASM. Isso pode ser útil para ter uma visão geral do espaço em todos os diskgroups.
* As colunas exibidas são o nome do banco de dados, o nome do diskgroup, o tamanho total e livre em GB, e a porcentagem de espaço livre e ocupado.

**Como implementar:**

1.  Conecte-se à instância ASM (como SYSASM).
2.  Execute o script.
3.  Verifique o diskgroup onde os archive logs são armazenados (geralmente um nome contendo "ARCH") e observe as colunas `"Free_ASM(GB)"` e `"Perc_Livre"` para garantir que há espaço suficiente para a restauração.

### 5. Bloco RMAN de exemplo para restauração

```rman
run {
allocate channel ch1 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch1)" ;
allocate channel ch2 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch2)" ;
allocate channel ch3 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch3)" ;
allocate channel ch4 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch4)" ;
allocate channel ch5 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch5)" ;
allocate channel ch6 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch6)" ;
allocate channel ch7 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch7)" ;
allocate channel ch8 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch8)" ;
restore archivelog from logseq  8150 until logseq 8209 thread 1;
}
```

**Explicação:**

* Este bloco de comandos RMAN aloca canais para interagir com o sistema de backup em fita (CommVault) e, em seguida, executa a restauração dos archive logs dentro de um intervalo específico de números de sequência e thread.
* Os parâmetros `SBT_LIBRARY` e `ENV` são específicos para a integração com o CommVault.
* O comando `restore archivelog from logseq 8150 until logseq 8209 thread 1;` especifica o intervalo de archive logs a serem restaurados para o thread 1.

**Como implementar:**

1.  Conecte-se ao RMAN na instância do banco de dados.
2.  Verifique e ajuste o caminho da `SBT_LIBRARY` se necessário.
3.  Ajuste o número de canais alocados conforme a necessidade.
4.  **Importante:** Substitua os valores de `from logseq` e `until logseq` pelos valores corretos obtidos no primeiro script. Verifique também o `thread`.
5.  Execute o bloco de comandos no RMAN.

### 6. Bloco RMAN de exemplo para alterar o destino dos archive logs

```rman
run {
set archivelog destination to '+BICORPH_DATA1';
allocate channel ch1 type 'sbt_tape' PARMS="SBT_LIBRARY=/commvault/hds/Base/libobk.so, BLKSIZE=1048576 ENV=(CV_mmsApiVsn=2,CV_channelPar=ch1)" ;
restore archivelog from logseq  16541 until logseq 17276 thread 1;
}
```

**Explicação:**

* Este bloco RMAN demonstra como alterar o destino dos archive logs para um diskgroup diferente (`+BICORPH_DATA1`) antes de realizar a restauração. Isso é útil quando o diskgroup de archive logs padrão não tem espaço suficiente.
* `set archivelog destination to '+BICORPH_DATA1';`: Este comando altera o destino para onde os archive logs serão restaurados.
* Os comandos `allocate channel` alocam um canal para a restauração a partir da fita.
* `restore archivelog from logseq 16541 until logseq 17276 thread 1;`: Este comando realiza a restauração dos archive logs para o novo destino especificado.

**Como implementar:**

1.  Conecte-se ao RMAN na instância do banco de dados.
2.  Verifique e ajuste o caminho da `SBT_LIBRARY` se necessário.
3.  Certifique-se de que o diskgroup de destino (`+BICORPH_DATA1` neste exemplo) existe e tem espaço suficiente.
4.  Ajuste o número de sequência inicial (`from logseq`) e final (`until logseq`) e o thread conforme necessário.
5.  Execute o bloco de comandos no RMAN.
