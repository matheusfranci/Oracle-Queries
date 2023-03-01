#! /bin/ksh

dmy=`date +%d%m%y_%H%M`
dat=`date +%d%m%y`

if [ "$1" != "" ]; then
   LISTASID=$1
else
   LISTASID=`ps -ef | grep ^"$USER " | grep _smon | grep -v grep | rev | cut -d_ -f1 | rev | grep -v ASM`
   if [ "$LISTASID" = "" ]; then
      LISTASID=`ps -ef | grep "$USER " | grep _smon | grep -v grep | rev | cut -d_ -f1 | rev | grep -v ASM`
   fi
fi


for sid in $LISTASID
do

export ORACLE_SID=$sid

(
echo
echo ------------------------------------------------------------------
echo
echo ----     RELATORIO DE ANALISE E DOCUMENTACAO DE AMBIENTE      ----
echo
echo ------------------------------------------------------------------
echo

echo ------------------------------------------------------------------
echo ----                     SISTEMA OPERACIONAL                  ----
echo ------------------------------------------------------------------
echo

echo DISTRIBUICAO
echo
UNAME=`uname -s`
stty -echo
if [ -f /etc/redhat-release ]; then
    dist=redhat
elif [ -f /etc/SuSE-release ]; then
    dist=suse
elif [ -f /etc/gentoo-release ]; then
    dist=gentool
elif [ -f /etc/lsb-release ]; then
    dist=ubuntu
elif [ "${UNAME}" = "AIX" ]; then
    dist=`uname -s`
else
    dist=${UNAME}
fi

if [ "$dist" = "HP-UX" ]; then
   plat=`if [ "\`uname -m\`" = "ia64" ]; then echo 64-bit; else uname -m ; fi`
elif [ "$dist" = "AIX" ]; then
   plat=v`uname -v`
else
   plat=`if [ "\`uname -i\`" = "x86" ]; then echo x86_32; else uname -i ; fi`
fi
stty echo
echo
echo $dist - $plat
echo
uname -a
echo
echo ------------------------------------------------------------------
echo
echo "UTILIZACAO DE DISCO"
echo
if [ "$dist" = "HP-UX" ]; then
   df -P
elif [ "$dist" = "AIX" ]; then
   df -g
   echo
   echo "SEGMENTOS DE MEMORIA ALOCADOS"
   echo "Deve haver so um segmento alocado por instancia ativa, para o usuario oracle."
   echo "Se houver mais de um segmento alocado por instancia, o parametro de kernel "
   echo "SHMMAX(max total shared memory) deve ser aumentado."
   echo
   ipcs -m | egrep "($USER|status)"
   echo
else
   df -h
   echo
   echo ------------------------------------------------------------------
   echo
   echo "SEGMENTOS DE MEMORIA ALOCADOS"
   echo "Deve haver so um segmento alocado por instancia ativa, para o usuario oracle."
   echo "Se houver mais de um segmento alocado por instancia, o parametro de kernel "
   echo "SHMMAX(max total shared memory) deve ser aumentado."
   echo
   ipcs -m | egrep "($USER|status)"
   echo
   echo
   echo '----------'
   echo
   echo "IPCS limites"
   ipcs -l
   echo ------------------------------------------------------------------
   echo
   echo "MEMORIA E SWAP"
   echo "Verificar o uso de swap. Este valor deve ser baixo.(ideal=0)"
   echo "Se o valor estiver alto, em algum momento houve falta de memoria para o S.O."
   echo "(Adicionar memoria fisica ou diminuir a memoria do banco que deve ser proximo a 60% da fisica)"
   echo
   free -m
fi
echo
echo ------------------------------------------------------------------
echo
echo "UTILIZACAO DE MEMORIA - VMSTAT"
echo "A coluna PROC - 'r'  deve ter com valor menor ou igual a qtd de processadores. Se for"
echo "maior, esta ocorrendo overhead e a carga deve ser analisada."
echo "As colunas SWAP - 'si' e 'so' ('swap in' e 'swap out') devem estar com valor baixo(ideal=0). Se mostrar"
echo "valor > 0 esta ocorrendo swap e a causa dever ser investigada"
echo
vmstat 2 10
echo
echo
echo
echo ------------------------------------------------------------------
echo
echo ----  SESSAO 2 - BANCO DE DADOS  ----
echo
echo ------------------------------------------------------------------
echo
echo
echo PATCHES INSTALADOS
echo
echo ------------------------------------------------------------------
cmd="`find $ORACLE_HOME -name opatch -exec file {} \; | grep -v old | grep -v bkp | grep \"Bourne shell script\" | cut -d: -f1` lsinventory"
echo $cmd
echo
     $cmd
echo
echo
echo "##################################################################"
echo
echo                 VERIFICACAO INSTANCIA: $ORACLE_SID
echo
echo "##################################################################"
echo


sqlplus  -s "/ as sysdba"<<!EOF_SQL1

set sqlprompt '' linesize 138 sqln off trim on feed off pages 4000 trimspool on head off timing off colsep ''
prompt
select '------------------------------------------------------------------' from dual;
prompt

select 'INSTANCE' from dual;
set head on
col host_name format a40
spool /tmp/v_dbname.lst
select INST_ID, INSTANCE_NAME, HOST_NAME,STARTUP_TIME STARTUP from gv\$instance order by 1;
spool off
spool /tmp/v_instname.lst
select INSTANCE_NAME from v\$instance;
spool off
set head off
select 'BACKGROUND DUMP' from dual;
spool /tmp/v_dump_dir.lst
select trim(value) from v\$parameter where value like '%bdump%';
spool off
prompt


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'VERSION' from dual;
col comp_name format a40
set head on newp 1
select * from gv\$version where banner like 'Oracle%' order by INST_ID;


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'REGISTRY' from dual;
col comp_name format a40
set head on newp 1
select comp_name, version, status from dba_registry;


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'OPTIONS' from dual;
break on inst_id skip 1
col value format a10
set head on newp 1
SELECT inst_id, parameter, value
FROM gv\$option
order by 2 asc, 1 desc;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'RESOURCE LIMITS' from dual;
set head on newp 1
select INST_ID, RESOURCE_NAME,
       trim(INITIAL_ALLOCATION) INITIAL_ALLOCATION,
       MAX_UTILIZATION,
       CURRENT_UTILIZATION,
 round((100*MAX_UTILIZATION)/to_number(trim(INITIAL_ALLOCATION))) "% MAX_UTIL"
 from gv\$resource_limit
where trim(INITIAL_ALLOCATION) not in('UNLIMITED','0')
order by 1,6 desc
/



CLEAR COLUMN

SET SERVEROUTPUT OFF

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'I/O POR DATAFILE' from dual;
set head on newp 1
prompt

column name format a50
column phyrds format 99,999,999,999
column phywrts format 999,999,999
column read_pct head "%READS" format 999.99
column write_pct head "%WRITES"format 999.99

select df.inst_id, name,
  phyrds,
  phyrds * 100 / trw.phys_reads read_pct,
  phywrts, phywrts * 100 / trw.phys_wrts write_pct
from (select Sum(phyrds) phys_reads,
      Sum(phywrts) phys_wrts
      from gv\$filestat) trw,
  gv\$datafile df,
  gv\$filestat fs
where df.file# = fs.file#
   and df.inst_id=fs.inst_id
order by phyrds desc, inst_id;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt MEMORY SETTINGS
prompt
set head on newp 1
clear breaks
col name for a30
col "size (MB)" for a20
select p.inst_id, p.name, to_number(p.value)/1024/1024 "size(MB)"
from gv\$parameter p, gv\$instance i
where (p.name like 'sga%'
       or    p.name like 'memory%'
       or    p.name = 'memory_target'
       or    p.name = 'pga_aggregate_target'
       or    p.name = 'large_pool_size')
and i.version > '10'
and p.inst_id=i.inst_id
and trim(p.value) not in ('FALSE','TRUE')
order by 2,1
/


prompt
prompt Se PGA_AGGREGATE_TARGET for maior que 0. WORKAREA_SIZE_POLICY deve ser AUTO.
prompt
col name format a30
col value format a30
select name,value from  v\$parameter where name in ('workarea_size_policy','pga_aggregate_target') order by 1
/
prompt

prompt
prompt PGA OVER ALLOCATION
prompt Se o valor for maior que zero o tamanho da PGA pode ser aumentado conforme a view gv\$PGA_TARGET_ADVICE
prompt
col name for a35
col value for 999,999,999
select inst_id,name,value
from
gv\$pgastat
where name='over allocation count'
order by 3 desc, 1 asc
/

prompt
prompt PGA ADVICE
prompt Tamanho de PGA aconselhavel para eliminar OVERALLOCATION
prompt
set pages 999
select * from (
SELECT inst_id, min(round(PGA_TARGET_FOR_ESTIMATE/1024/1024)) "PGA_TARGET(MB)",
       max(ESTD_PGA_CACHE_HIT_PERCENTAGE) "CACHE_HIT(%)",
       min(ESTD_OVERALLOC_COUNT) "OVERALLOC(COUNT)"
FROM   gv\$pga_target_advice
where ESTD_OVERALLOC_COUNT=0
group by inst_id
order by 1
) where rownum<=(select max(inst_id) from gv\$instance)
/



set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
PROMPT TOTAL DE SESSOES
PROMPT
Prompt Totalizacao de sessoes por instancia
prompt
select inst_id, count(1) "QTDE SESSOES" from gv\$session group by inst_id;



set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
PROMPT SESSOES BLOQUEADORAS
PROMPT
Prompt Totalizacao de sessoes bloqueadoras no momento da coleta
set head on newp 1 feed on
col machine for a20
col program for a40
SELECT /*+ rule ordered */
        l.inst_id, nvl(s.username,'SYSTEM') username,
        sum(block) BLOCKERS,
        sum(request) WAITINGS
    FROM gv\$lock l, gv\$session s, sys.obj\$ c
   WHERE (l.request > 0 OR l.block > 0)
     and l.sid = s.sid
     and l.inst_id=s.inst_id
     and l.id1 = c.OBJ# (+)
   GROUP BY l.inst_id, s.username
   ORDER BY 4 desc, 2, 1;

col GETS_CONSISTENTES format 99999999999999
col comp_name format a20
col REQUEST format 9999999999999
col %WAIT format 999


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'SORT AREA' from dual;
prompt
select 'Verifica a relacao de sort em disco e memoria' from dual;
select 'Valor de %SORT deve ficar abaixo de 5%.' from dual;
select '(Aumentar o valor de SORT_AREA_SIZE.)' from dual;
prompt

set head on newp 1
col disc head "Sorts In disc"
col psort head "%Sorts In Disk" format 99
col memory head "Sorts In Memory"
select inst_id, disc, memory, psort, Decode( Sign( psort - 5 ), -1, ' ', '*' ) "OverAllocation"
  from ( select d.inst_id, d.value disc, m.value memory, d.value / m.value * 100 psort
           from gv\$sysstat d, gv\$sysstat m
          where d.name = 'sorts (disk)'
            and d.inst_id=m.inst_id
            and m.name = 'sorts (memory)' )
 order by 1;


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'ROLLBACK SEGMENTS' from dual;
prompt
select 'Verifica o header de segmento de rollback em espera' from dual;
select 'Valor de %WAIT deve ficar abaixo de 5%.' from dual;
select '(Aumentar a quantidade de segmentos de rollback.)' from dual;
prompt
set head on newp 1

select inst_id, waits, gets, pwait "%WAIT", Decode( Sign( pwait - 5 ), -1, ' ', '*' ) warn
  from ( select inst_id, Sum( waits ) waits, Sum( gets ) gets, Sum( waits ) * 100 / Sum( gets ) pwait
          from gv\$rollstat group by inst_id order by 1);


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
select 'RELOADS' from dual;
select 'Verifica o nr. de reloads na Library Cache - Shared Poll' from dual;
select 'Valor de %RELOADS deve ficar abaixo de 1%.' from dual;
--select '(Aumentar o tamanho de SHARED_POOL_SIZE.)' from dual;
set head on newp 1

select inst_id, namespace, reloads, pins, preloads "%RELOADS", Decode( Sign( preloads - 1 ), -1, ' ', '*' ) over
  from ( select inst_id, namespace, reloads, pins, reloads / decode( pins, 0, 0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001, pins ) * 100 preloads
           from gv\$librarycache )
order by 2, 1;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
select 'Verifica o nr. de reloads na Data Dictionary Cache' from dual;
select 'Valor de %GETMISSES deve ficar abaixo de 15%.' from dual;
select '(Aumentar o tamanho de SHARED_POOL_SIZE.)' from dual;
set head on newp 1

select inst_id, parameter, getmisses, gets, pgetmisses "%GETMISSES", decode( sign( pgetmisses - 15 ), -1, ' ', '*' ) over
  from ( select inst_id, parameter, getmisses, gets, getmisses / decode( gets, 0, 0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001, gets ) * 100 pgetmisses
           from gv\$rowcache )
order by 2, 1;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'BUFFER CACHE HITS' from dual;
prompt
select 'Verifica o nr. de Cache Hits' from dual;
select 'Valor de %CACHE_HITS deve ser maior que 90%.' from dual;
select '(Aumentar o tamanho de DB_BLOCK_BUFFERS.)' from dual;
prompt
set head on newp 1

select inst_id, leit_fisicas, blocos, gets_consistentes, cache_hits "%CACHE_HITS",
       decode( sign( cache_hits - 90 ), 1, ' ', '*' ) over
  from ( select f.inst_id, f.value leit_fisicas, b.value blocos, c.value gets_consistentes,
                ( 1 - ( f.value / ( b.value + c.value ) ) ) * 100 cache_hits
           from gv\$sysstat f, gv\$sysstat b, gv\$sysstat c
          where f.name = 'physical reads'
            and b.name = 'db block gets'
            and c.name = 'consistent gets'
            and f.inst_id = b.inst_id
            and b.inst_id = c.inst_id
 )
order by 1;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'LOG SPACE REQUESTS' from dual;
prompt
select 'Verifica as log space requests' from dual;
select 'Valor de %REQUESTS deve ser no maximo 1%' from dual;
select '(Aumentar o tamanho de LOG_BUFFERS.)' from dual;
prompt
set head on newp 1

select inst_id, requests, entries, prequests "%REQUESTS", decode( sign( prequests - 1 ), -1, ' ', '*' ) warn
  from ( select r.inst_id, r.value requests, e.value entries, r.value / e.value * 100 prequests
           from gv\$sysstat r, gv\$sysstat e
          where r.name = 'redo log space requests'
            and e.name = 'redo entries' )
order by 1, 4 desc;

prompt
prompt BLOCK PARAMETER
col name format a40
col value format a11
select inst_id, name, value from gv\$parameter where upper(name)='DB_FILE_MULTIBLOCK_READ_COUNT'
order by 1;
prompt


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'CONTAGEM DE TODOS OBJETOS' from dual;
prompt
select 'Conta todos objetos do banco por OWNER' from dual;
prompt
set head on newp 1 feed on
SET LINESIZE  145
SET PAGESIZE  9999

clear columns
clear breaks
clear computes

column owner           format a25         heading 'OWNER'

break on owner  on report
compute sum label "Count "         of object_name on owner
compute sum label "Grand Total: "  of qtd on report

SELECT owner, count(1) qtd
FROM dba_objects
GROUP BY owner
order by 1
/

set head off newp none feed off
clear columns
clear breaks
clear computes
prompt


select 'Conta todos objetos do banco por TIPO' from dual;
prompt

set head on newp 1
SET LINESIZE  145
SET PAGESIZE  9999

select object_type, count(1) qtd
from dba_objects
group by object_type
order by 1
/



set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'OBJETOS INVALIDOS' from dual;
prompt
select 'Verifica total de objetos invalidos. Devem ser recompilados' from dual;
prompt
column OWNER           format a25         heading 'OWNER'
set head on newp 1
SET LINESIZE  145
SET PAGESIZE  9999

clear columns
clear breaks
clear computes

column owner           format a25         heading 'OWNER'

break on owner  on report
compute sum label "Count"          of object_name on owner
compute sum label "Grand Total: "  of invalids on report

set head on
SELECT owner, count(1) invalids
FROM dba_objects
WHERE status <> 'VALID'
GROUP BY owner;
prompt
prompt

prompt
prompt (Script para compilacao de objetos invalidos: @?/rdbms/admin/utlrp.sql)
prompt

set head off feed on
prompt Em modo DEBUG: Causam perda de performance. Devem ser recompilados.
prompt
set head on
select owner, object_type, debuginfo, status, sum(1) "TOT INVALIDOS"
from all_PROBE_OBJECTS
where debuginfo in 'T'
and owner not in ('SYS','SYSTEM','ODM','ORDSYS')
group by owner, object_type, debuginfo,status
order by owner, object_type, status;
prompt

prompt
prompt SCRIPT PARA COMPILAR OBJETOS EM MODO DEBUG
prompt ----------------------;
prompt set pages 40000
prompt select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE','SYNONYM', 'PUBLIC SYNONYM', 'TYPE BODY','TYPE', object_type)
prompt         ||' '||decode(object_type, 'SYNONYM', '', owner||'.')||object_name||' compile '||
prompt         decode(object_type,'PACKAGE BODY','BODY;','TYPE BODY', 'BODY;', ';')
prompt from all_PROBE_OBJECTS
prompt where debuginfo in 'T'
prompt and owner not in ('SYS','SYSTEM','ODM','ORDSYS')
prompt order by object_type desc;;
prompt
prompt @?/rdbms/admin/utlrp.sql
prompt
prompt ----------------------;
prompt
prompt (Deve ser rodado o script @?/rdbms/admin/utlrp.sql, apos a compilacao dos objetos em DEBUG)
prompt




set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt Objetos de usuarios na tablespace SYSTEM. Devem ser movidos para tablespaces corretas
set head on
select owner, count(1)
 from sys.dba_segments
where owner not in ('PUBLIC', 'SYS', 'SYSTEM', 'OUTLN')
  and tablespace_name = 'SYSTEM'
group by owner;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt TOP 10 PROCEDURES

set head on newp none
SET VERIFY   off
COLUMN ptyp      FORMAT a13                  HEADING 'Object Type'
COLUMN obj       FORMAT a42                  HEADING 'Object Name'
COLUMN noe       FORMAT 999,999,999,999,999  HEADING 'Number of Executions'

SELECT ptyp, obj, 0 - exem noe
FROM ( select distinct exem, ptyp, obj
       from ( select o.type ptyp, o.owner || '.' || o.name obj, o.executions exem
              from  gv\$db_object_cache O
              where o.type in ('FUNCTION','PACKAGE','PACKAGE BODY','PROCEDURE','TRIGGER')
           )
) WHERE rownum <= 10;


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt TOP 10 SQL BY BUFFER GETS PER EXECUTION

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN username        FORMAT a18                  HEADING 'Username'
COLUMN disk_reads      FORMAT 999999999  HEADING 'Disk Reads'
COLUMN executions      FORMAT 999999999  HEADING 'Executions'
COLUMN reads_per_exec  FORMAT 999999999  HEADING 'Reads / Executions'
COLUMN sql             FORMAT a50          HEADING 'SQL Statement'

set head on newp none
select * from
(select
    UPPER(b.username)                                        username
  , a.buffer_gets                                            buffer_gets
  , a.executions                                             executions
  , a.buffer_gets / decode(a.executions, 0, 1, a.executions) gets_per_exec
  , sql_text || chr(10) || chr(10)                           sql
FROM
    sys.v_\$sqlarea a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id
  AND a.buffer_gets > 1000
  and b.default_tablespace not in ('SYSTEM', 'SYSAUX')
ORDER BY 4 desc)
where rownum <= 10;

set head off newp none feed off
select '------------------------------------------------------------------' from dual;
prompt
prompt TOP 10 SQL BY DISK READS PER EXECUTION

set head on newp none
SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN username        FORMAT a18                  HEADING 'Username'
COLUMN disk_reads      FORMAT 999999999  HEADING 'Disk Reads'
COLUMN executions      FORMAT 999999999  HEADING 'Executions'
COLUMN reads_per_exec  FORMAT 999999999  HEADING 'Reads / Executions'
COLUMN sql             FORMAT a50          HEADING 'SQL Statement'

select * from
(SELECT
    UPPER(b.username)                                       username
  , a.disk_reads                                            disk_reads
  , a.executions                                            executions
  , a.disk_reads / decode(a.executions, 0, 1, a.executions) reads_per_exec
  , sql_text || chr(10) || chr(10)                          sql
FROM
    sys.v_\$sqlarea a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id
  AND a.disk_reads > 1000
  and b.default_tablespace not in ('SYSTEM', 'SYSAUX')
--  AND b.username IN ('MASTER')
ORDER BY 4 desc)
where rownum<=10;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt TOP WAIT EVENTS
set head on
col event  for a60
select COUNT(*) tot_events,
sum(seconds_in_wait) tot_seconds,
CASE WHEN state != 'WAITING' THEN 'WORKING'
ELSE 'WAITING'
END AS state,
CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
ELSE event
END AS sw_event
FROM gv\$session_wait
GROUP BY CASE WHEN state != 'WAITING' THEN 'WORKING'
         ELSE 'WAITING'
         END,
    CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
    ELSE event
    END
 ORDER BY 1 DESC, 2 DESC;



set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'DATABASE SIZE' from dual;
set head on newp 1
col "Allocated Size" format a20
col "Free space" format a20
col "Used space" format a20
select round(sum(used.bytes) / 1024 / 1024 / 1024 ) || ' GB' "Allocated Size"
, round(sum(used.bytes) / 1024 / 1024 / 1024 ) -
 round(free.p / 1024 / 1024 / 1024) || ' GB' "Used space"
, round(free.p / 1024 / 1024 / 1024) || ' GB' "Free space"
from    (select bytes
 from v\$datafile
 union all
 select bytes
 from  v\$tempfile
 union  all
 select  bytes
 from  v\$log) used
, (select sum(bytes) as p
 from dba_free_space) free
group by free.p;


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt USO DE TABLESPACE E DATAFILES
prompt
prompt MANAGEMENT
prompt ----------;
prompt
prompt Em versoes 9i e superiores, eh aconselhavel que a tablespace tenha:  EXTENT_MANAGEMENT=LOCAL SEGMENT_SPACE_MANAGEMENT=AUTO
prompt (Para alterar, a tablespace deve ser recriada com as clausulas "EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO")
set head on newp 1
set head on feed on pages 4000 lines 150 verify off
prompt
prompt
prompt TABLESPACE INFO
prompt ---------------;
prompt

col type  head "Type"             for a9
col tbsn  head "Tablespace"       for a25
col ext   head "Ext|Mng"          for a3 trunc
col seg   head "Seg|Mng"          for a3 trunc
col maxs  head "MaxSize|(MB)"     for 99999999999
col size  head "Size|(MB)"        for 9999999
col used  head "Used|(MB)"        for 9999999
col free  head "Free|(MB)"        for 9999999
col freem head "Free|Of Max|(MB)" for 9999999999
col usedp head "%Used"            for 999
col usedm head "%Used|Of Max"     for 999
col warn1  head "!"               for a1
col warn2  head "!"               for a1
BREAK ON Type skip 1 on report
COLUMN DUMMY NOPRINT;
COMPUTE SUM OF size  ON type
COMPUTE SUM OF used  ON type
COMPUTE SUM OF free  ON type
COMPUTE SUM OF freem ON type
COMPUTE SUM OF size  ON Report
COMPUTE SUM OF used  ON Report
COMPUTE SUM OF free  ON Report
COMPUTE SUM OF freem ON Report
COMPUTE SUM label "TOTAL" OF maxs ON type
COMPUTE SUM label "TOTAL GERAL" OF maxs ON Report


select    tbs.tipo                                                                                 "type"
          ,nvl(data.tablespace_name,nvl(mbfree.tablespace_name,'UNKOWN'))                          "tbsn"
          ,tbs.ext_management                                                                      "ext"
          ,tbs.seg_management                                                                      "seg"
          ,round(MaxMBytes)                                                                        "maxs"
          ,round(MBytes)                                                                           "size"
          ,round(MBytes-MBytes_Livre)                                                              "used"
          ,round(MBytes)-round(MBytes-MBytes_Livre)                                                "free"
          ,round(MaxMBytes)-round(MBytes-MBytes_Livre)                                             "freem"
          ,ceil(100*round(MBytes-MBytes_Livre)/ceil(MBytes))                                       "usedp"
          ,decode(least(ceil(100*round(MBytes-MBytes_Livre)/ceil(MBytes)),90),90,'*', ' ')         "warn1"
          ,ceil(100*round(MBytes-MBytes_Livre)/ceil(MaxMBytes))                                    "usedm"
          ,decode(least(ceil(100*round(MBytes-MBytes_Livre)/ceil(MaxMBytes)),90),90,'*', ' ')      "warn2"
from
( select nvl(sum(bytes)/1024/1024,0) MBytes_Livre,
       tablespace_name
       from sys.dba_free_space
       group by tablespace_name ) mbfree,
(  select tablespace_name,
        (sum(decode(nvl(MaxBytes,0),0,Bytes,MaxBytes)/1024/1024) - sum(Bytes)/1024/1024) MaxBytes_Livre,
        (sum(Bytes)/1024/1024) - sum(Bytes)/1024/1024 MaxMBytes_Livre
       from sys.dba_data_files
       group by tablespace_name ) maxmbfree,
     ( select sum(decode(nvl(MaxBytes,0),0,Bytes,MaxBytes))/1024/1024 MaxMBytes, sum(Bytes)/1024/1024 MBytes, tablespace_name
       from sys.dba_data_files
       group by tablespace_name ) data,
     ( select tablespace_name, contents tipo, extent_management ext_management, segment_space_management seg_management from dba_tablespaces) tbs
where mbfree.tablespace_name (+) = data.tablespace_name
  and maxmbfree.tablespace_name (+) = data.tablespace_name
  and tbs.tablespace_name=mbfree.tablespace_name
union
SELECT
   'TEMPORARY'                                            "type"
  , tbs2.tablespace_name                                  "tbsn"
  , tbs2.extent_management                                "ext"
  , tbs2.segment_space_management                         "seg"
  , round(NVL(tempf.MaxMBytes, 0))                        "maxs"
  , round(NVL(tempf.MBytes, 0))                           "size"
  , round(NVL(used.MBytes, 0))                            "used"
  , round((NVL(tempf.MBytes, 0)-NVL(used.MBytes, 0)))     "free"
  , round((NVL(tempf.MaxMBytes, 0)-NVL(used.MBytes, 0)))  "freem"
  , TRUNC(NVL(used.MBytes / tempf.MBytes * 100, 0))       "used"
  ,' '                                                    "warn1"
  , TRUNC(NVL(used.MBytes / tempf.MaxMBytes * 100, 0))    "usedm"
  ,' '                                                    "warn2"
FROM sys.dba_tablespaces tbs2
  , ( select tablespace_name, sum(decode(MaxBytes,0,Bytes,MaxBytes))/1024/1024 MaxMBytes, sum(Bytes)/1024/1024 MBytes
      from dba_temp_files
      group by tablespace_name
    ) tempf
  , ( select ss.tablespace_name,sum(ss.used_blocks*ts.blocksize)/1024/1024 MBytes
           from gv\$sort_segment ss, sys.ts\$ ts
           where ss.tablespace_name = ts.name
           group by ss.tablespace_name
    ) used
  , v\$sort_segment  sort
WHERE
      tbs2.tablespace_name = tempf.tablespace_name(+)
  AND tbs2.tablespace_name = used.tablespace_name(+)
  AND tbs2.tablespace_name = sort.tablespace_name(+)
  AND tbs2.contents like 'TEMPORARY'
order by 1,2
/

prompt
prompt
prompt DATAFILE INFO
prompt -------------;
prompt
--accept tablespace prompt "INFORME O NOME DA TABLESPACE PARA LISTAR OS DATAFILES (<ENTER>=TODOS) :  "
prompt
set linesize 150
col "Tablespace" for a20
col "Status" for a9
col "FileName(FileID)" for a50
col "Max(MB)" for 99999999999
col "Size(MB)" for 9999999
col "Used(MB)" for 999999
col "Free(MB)" for 9999999999
col "UsedOfMax(%)" for 999
BREAK on "Tablespace" skip 1 on report skip 1
--COLUMN DUMMY NOPRINT;
COMPUTE SUM label "TOTAL GERAL"      OF "Max(MB)" ON report
COMPUTE SUM OF "Size(MB)" ON report
COMPUTE SUM OF "Used(MB)" ON report
COMPUTE SUM  OF "FreeOfMax(MB)" ON report


SELECT /*+ ordered */ d.tablespace_name "Tablespace"
     , d.file_name||'('||d.file_id||')' "FileName(FileID)"
     , v.status "Status"
     , d.maxbytes/1024/1024 "Max(MB)"
     , d.bytes/1024/1024 "Size(MB)"
     , trunc(NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2) "Used(MB)"
     , trunc((d.maxbytes/1024/1024) - NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2) "FreeOfMax(MB)"
     , round(((trunc(NVL((d.bytes - s.bytes),d.bytes),2))*100)/d.maxbytes) "UsedOfMax(%)"
     --, round((d.bytes*100)/d.maxbytes) "UsedOfMax(%)"
     , d.autoextensible "Aut"
 FROM sys.dba_data_files d
     , v\$datafile v
     , (SELECT file_id, SUM(bytes) bytes
         FROM sys.dba_free_space
         GROUP BY file_id) s
WHERE (s.file_id (+)= d.file_id)
      AND (d.file_name = v.name)
      AND d.autoextensible='YES'
UNION
SELECT /*+ ordered */ d.tablespace_name "Tablespace"
     , d.file_name||'('||d.file_id||')' "FileName(FileID)"
     , v.status "Status"
     , d.bytes/1024/1024 "Max(MB)"
     , d.bytes/1024/1024 "Size(MB)"
     , trunc(NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2) "Used(MB)"
     , trunc((d.bytes/1024/1024) - NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2) "FreeOfMax(MB)"
     , round((NVL((d.bytes - s.bytes),d.bytes)*100)/d.bytes) "UsedOfMax(%)"
     , autoextensible "Aut"
 FROM sys.dba_data_files d
     , v\$datafile v
     , (SELECT file_id, SUM(bytes) bytes
         FROM sys.dba_free_space
         GROUP BY file_id) s
WHERE (s.file_id (+)= d.file_id)
      AND (d.file_name = v.name)
      AND d.autoextensible='NO'
UNION
SELECT /*+ ordered */ d.tablespace_name
     , d.file_name||'('||d.file_id||')' "FileName(FileID)"
     , d.status "Status"
     , d.maxbytes/1024/1024 "Max(MB)"
     , d.bytes/1024/1024 "Size(MB)"
     , NULL "Used(MB)"
     , NULL "FreeOfMax(MB)"
     , NULL "UsedOfMax(%)"
     , autoextensible "Aut"
 FROM sys.dba_temp_files d
    WHERE  autoextensible='YES'
UNION
SELECT /*+ ordered */ d.tablespace_name
     , d.file_name||'('||d.file_id||')' "FileName(FileID)"
     , d.status "Status"
     , d.bytes/1024/1024 "Max(MB)"
     , d.bytes/1024/1024 "Size(MB)"
     , NULL "Used(MB)"
     , NULL "FreeOfMax(MB)"
     , NULL "UsedOfMax(%)"
     , autoextensible "Aut"
 FROM sys.dba_temp_files d
    WHERE autoextensible='NO'
ORDER BY 1,2
/


prompt
prompt DATAFILE COM MAXSIZE QUE PRECISAM SER AJUSTADOS (maxbytes<bytes)
set head off
select 'alter database datafile '''||file_name||''' autoextend on maxsize '||bytes||';'
from dba_data_files where maxbytes<bytes
 and autoextensible='YES'
/
prompt


prompt
prompt TABLESPACES > 89% OCUPADO
prompt
set feed on head off
select 'A tablespace '||data.tablespace_name||' deve ser aumentada de '||round(MBytes)
       ||'m para '||round(((MBytes)*(100*round(MBytes-MBytes_Livre)/ceil(MBytes)))/89)
       ||'m (diferenca='||round((((MBytes)*(100*round(MBytes-MBytes_Livre)/ceil(MBytes)))/89)-(MBytes))
       ||') para ficar com espaco utilizado = 89%' "Tablespaces > 89%"
from
( select nvl(sum(bytes)/1024/1024,0) MBytes_Livre, tablespace_name
       from sys.dba_free_space group by tablespace_name ) mbfree,
     ( select sum(Bytes)/1024/1024 MBytes, tablespace_name
       from sys.dba_data_files group by tablespace_name ) data
where mbfree.tablespace_name (+) = data.tablespace_name
  and ceil(100*round(MBytes-MBytes_Livre)/ceil(MBytes)) > 89
/


set feed on head off
prompt
prompt
prompt Tablespaces sem nenhum DATAFILE AUTOEXTENSIBLE com pouco espaco livre(>90% ocupado)
prompt

set head off
select distinct 'A tablespace '||total.TABLESPACE_NAME||' nao possui nenhum datafile autoextensible e tem apenas '||
       floor(nvl(sum(free.bytes),0)/total.bytes*100)||'% de espaco livre'
from (select  tablespace_name,   sum(bytes) bytes
        from  sys.dba_data_files  group by tablespace_name) total,
              dba_free_space  free
where  total.tablespace_name = free.tablespace_name(+)
 and  10 >= (select floor(nvl(sum(f2.bytes),0)/t2.bytes*100) pctfre
               from (select tablespace_name, sum(bytes) bytes
                       from sys.dba_data_files group by tablespace_name) t2, dba_free_space  f2
              where  t2.tablespace_name = f2.tablespace_name(+)
                and  t2.tablespace_name = total.tablespace_name
              group by  t2.tablespace_name, t2.bytes)
 and total.tablespace_name not in (select distinct d.TABLESPACE_NAME
                                from dba_data_files d
                                where autoextensible = 'YES')
group by  total.tablespace_name, total.bytes
order by 1 desc
/



set head off newp none
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt TABLES/INDEXES INFO
prompt


/*
set head off newp none feed off
prompt
prompt TOP 10 TABLES USAGE

set head on newp none
COLUMN ctyp      FORMAT a13                  HEADING 'Command Type'
COLUMN obj       FORMAT a30                  HEADING 'Object Name'
COLUMN noe       FORMAT 999,999,999,999,999  HEADING 'Number of Executions'
COLUMN rowp      FORMAT 999,999,999,999,999  HEADING 'Rows Processed'
COLUMN gets      FORMAT 999,999,999,999,999  HEADING 'Buffer Gets'
SELECT    ctyp  , obj  , 0 - exem noe  , rowp  , gets
FROM (select distinct exem, ctyp, obj, gets, rowp
      from (select
              DECODE(   s.command_type
                      , 2,  'Insert into '
                      , 3,  'Select from '
                      , 6,  'Update  of  '
                      , 7,  'Delete from '
                      , 26, 'Lock    of  ')   ctyp
            , o.owner || '.' || o.name        obj
            , SUM(0 - s.executions)           exem
            , SUM(s.buffer_gets)              gets
            , SUM(s.rows_processed)           rowp
          from
              gv\$sql                s
            , gv\$object_dependency  d
            , gv\$db_object_cache    o
          where
                s.command_type  IN (2,3,6,7,26)
            and d.from_address  = s.address
            and d.to_owner      = o.owner
            and o.owner not like '%SYS%'
            and d.to_name       = o.name
            and o.type          = 'TABLE'
          group by s.command_type, o.owner, o.name
          order by 5 desc
    )
)
WHERE rownum <= 10
order by 3,4;
*/



set head off newp none feed off
PROMPT
PROMPT  TABLES AND INDEXES FRAGMENTATION
select '------------------------------------------------------------------' from dual;
PROMPT

set head on newp 1
SET SERVEROUTPUT ON

declare

  db_size_mb number := 0;

  size_frag_mb number := 0;     -- index and table fragmentation
  size_frag_i_mb number := 0;   -- index
  size_frag_t_mb number := 0;   -- table

  number_of_free_extents number := 10;

begin

  dbms_output.enable(100000);


  SELECT Round(NVL(Sum(bytes)/1024/1024, 0), 2) INTO db_size_mb
  FROM dba_data_files;


  SELECT Round(NVL(Sum(bytes)/1024/1024, 0), 2)
    INTO size_frag_t_mb
  FROM dba_free_space FE,
    (SELECT S.tablespace_name, Max(S.next_extent) AS "min_next_extent"
     FROM dba_segments S
     WHERE S.segment_type = 'TABLE'
       AND S.tablespace_name <> 'SYSTEM'
     GROUP BY S.tablespace_name) MS
  WHERE FE.tablespace_name = MS.tablespace_name
  AND FE.bytes < number_of_free_extents * MS."min_next_extent";



  SELECT Round(NVL(Sum(bytes)/1024/1024, 0), 2)
    INTO size_frag_i_mb
  FROM dba_free_space FE,
    (SELECT S.tablespace_name, Max(S.next_extent) AS "min_next_extent"
     FROM dba_segments S
     WHERE S.segment_type = 'INDEX'
       AND S.tablespace_name <> 'SYSTEM'
     GROUP BY S.tablespace_name) MS
  WHERE FE.tablespace_name = MS.tablespace_name
  AND FE.bytes < number_of_free_extents * MS."min_next_extent";


  size_frag_mb := size_frag_t_mb + size_frag_i_mb;


  dbms_output.put_line( 'Database total size: ' || db_size_mb || 'MB');
  dbms_output.put_line( 'Fragmentation total size: ' || size_frag_mb || 'MB,
      that is ' || Round(100 * size_frag_mb / db_size_mb, 2) || '% of total');
  dbms_output.put_line( 'Table fragmentation size: ' || size_frag_t_mb || 'MB,
      that is ' || Round(100 * size_frag_t_mb / db_size_mb, 2) || '% of total');
  dbms_output.put_line( 'Index fragmentation size: ' || size_frag_i_mb || 'MB,
      that is ' || Round(100 * size_frag_i_mb / db_size_mb, 2) || '% of total');

end;
/


set head off newp none
clear columns
clear breaks
clear computes
prompt

set head off newp none feed off
select '------------------------------------------------------------------' from dual;
prompt

select 'CHAINED/MIGRATED ROWS' from dual;
prompt
select 'Localiza tabelas com linhas encadeadas ou migradas' from dual;
prompt
set head on feed on newp 1
column c1 heading "Owner"   format a9;
column c2 heading "Table"   format a25;
column c3 heading "PCTFREE" format 99;
column c4 heading "PCTUSED" format 99;
column c5 heading "avg row" format 99,999;
column c6 heading "Rows"    format 999,999,999;
column c7 heading "Chains"  format 999,999,999;
column c8 heading "Pct"     format .99;


select
   owner              c1,
   table_name         c2,
   pct_free           c3,
   pct_used           c4,
   avg_row_len        c5,
   num_rows           c6,
   chain_cnt          c7,
   chain_cnt/num_rows c8
from dba_tables
where
table_name not in
 (select table_name from dba_tab_columns
   where
 data_type in ('RAW','LONG RAW')
 )
and
chain_cnt > 0
order by chain_cnt desc
/

set head off
Prompt SQL COMMAND
prompt
select 'alter table '||owner||'.'||table_name||' move;'
 from dba_tables
where
table_name not in
 (select table_name from dba_tab_columns
   where
 data_type in ('RAW','LONG RAW')
 )
and
chain_cnt > 0
order by chain_cnt desc
/

prompt
prompt FAZER REBUILD DOS INDICES UNUSABLES APOS MOVE DE TABELAS
prompt
PROMPT SELECT 'ALTER INDEX ' || owner || '.' || INDEX_name || ' REBUILD --ONLINE;'
PROMPT FROM   dba_indexes WHERE  STATUS = 'UNUSABLE';;
PROMPT



set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt
prompt PARTITINING
prompt

column "OWNER.TABLE"       format a25
column "OWNER.TABLE.INDEX" format a40
column partition_name      format a20
column "TYPE"              format a8
column tablespace_name     format a25
column high_value          format a15

break on "OWNER.TABLE" skip 1 on "TYPE" on tablespace_name
set verify off

select  p.table_owner||'.'|| p.table_name "OWNER.TABLE",
        t.partitioning_type "TYPE",
        p.tablespace_name,
        p.partition_name,
        p.num_rows,
        p.HIGH_VALUE
 from dba_tab_partitions p, dba_part_tables t
where p.table_name=t.table_name
  and p.table_owner = t.owner
  AND p.TABLE_OWNER not like 'SYS%'
order by p.table_name, p.partition_name
/


prompt
prompt IND PARTITION INFO
---------------------
prompt

break on "OWNER.TABLE.INDEX" skip 1 on "TYPE" on tablespace_name
set verify off

select  i.owner||'.'||i.table_name||'.'||i.index_name "OWNER.TABLE.INDEX",
        pi.partitioning_type "TYPE",
        nvl(p.tablespace_name,i.tablespace_name) "TABLESPACE_NAME",
        nvl(p.partition_name,'NOT PARTITIONED') "PARTITION_NAME",
        nvl(p.num_rows,i.num_rows) "NUM_ROWS",
        p.HIGH_VALUE
 from dba_ind_partitions p, dba_part_indexes pi, dba_indexes i
where i.index_name  = p.index_name(+)
  and i.owner = p.index_owner(+)
  and i.index_name  = pi.index_name(+)
  and i.owner = pi.owner(+)
  AND i.OWNER not like 'SYS%'
  and i.table_name in (select distinct t.table_name from dba_tab_partitions t
                        where t.table_owner not like 'SYS%')
order by i.owner, i.index_name, p.partition_name
/


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
select 'INDEXES UNUSABLES' from dual;
prompt
select 'Verifica a existencia de indices invalidos no banco' from dual;
prompt
column OWNER           format a25         heading 'OWNER'
set head on newp 1
SET LINESIZE  145
SET PAGESIZE  9999

column owner           format a25         heading 'OWNER'

set head on
SELECT owner, index_name, status
FROM dba_indexes
WHERE status not in ('VALID','N/A')
union
SELECT ' ' owner, 'ALL INDEXES' index_name, 'VALID' status
FROM dual where 'VALID' = (SELECT distinct status FROM dba_indexes
                      WHERE status='VALID');
prompt
prompt





set head off newp none
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt REDO SIZE
col member format a50
col status format a10
col inst_id format 09
col group# format 09
set head on newp none
break on report on inst_id on group# skip 1
compute sum label "Total " of MB on inst_id

SELECT a.inst_id, a.group#, a.member, b.bytes/1024/1024 MB, b.status
FROM gv\$logfile a, gv\$log b
WHERE a.group# = b.group#
and a.inst_id=b.thread#
order by 1,2,3;

!EOF_SQL1

##############################################
# SE UTILIZAR ASM
##############################################


ASM=`ps -ef | grep "+ASM" | grep -v grep`
#if ! test -z "${ASM}"; then
if [ "" != "${ASM}" ]; then
sqlplus  -s "/ as sysdba"<<!EOF_SQL2

set sqlprompt '' linesize 138 sqln off trim on feed off pages 4000 trimspool on head off timing off colsep ''
prompt


set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt VERIFICACAO RAC e ASM
prompt
select '------------------------------------------------------------------' from dual;
prompt

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt ASM DISKS
prompt Utilizacao dos discos no ASM
prompt Se Warning(*), adicionar disco ao Disk Group
set head on newp 1

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
COLUMN warn                   format a4            HEAD ' * '


break on report on disk_group_name skip 1

compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
      name                                     group_name
    , total_mb                                 total_mb
    , (total_mb - free_mb)                     used_mb
    , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
    , decode(greatest(100*nvl(sum(free_mb),0)/total_mb,10),10,'Warn', ' ') warn
  FROM
      gv\$asm_diskgroup
  group by name, total_mb, free_mb
  ORDER BY
  name;


prompt
prompt
prompt ACFS - ASM CLUSTER FILESYSTEM
prompt Utilizacao dos discos ACFS
prompt Se Warning(*), adicionar disco ao Disk Group
prompt

set head on newp 1
COLUMN fs_name                FORMAT a30
COLUMN vol_device             FORMAT a11

SELECT fs_name,
       vol_device,
       primary_vol,
       total_mb/1024 "Tot(GB)", round(free_mb/1024) "Free(GB)",
       decode(greatest(100*nvl(sum(free_mb),0)/total_mb,10),10,'Warn', ' ') warn
FROM GV\$ASM_ACFSVOLUMES
GROUP BY fs_name, vol_device, primary_vol, total_mb, free_mb;

!EOF_SQL2

else

sqlplus  -s "/ as sysdba"<<!EOF_SQL2
set head off feed off lines 138 pages 0 timing off colsep ''
col DEST_NAME for a50
col DESTINATION for a50
prompt
prompt ARCHIVES
prompt
prompt ARCHIVES DESTINATION
prompt
select 'DEST_NAME                                          DESTINATION                                        LOG_SEQUENCE' from dual;
select '-------------------------------------------------- -------------------------------------------------- ------------' from dual;
spool /tmp/v_arch_dir.tmp
select DEST_NAME, DESTINATION, LOG_SEQUENCE from v\$archive_dest
where destination is not null;
spool off
!EOF_SQL2
sort -u /tmp/v_arch_dir.tmp | grep -v DESCRIPTION > /tmp/v_arch_dir.lst
fi

echo
echo UTILIZACAO DA AREA DE ARCHIVES
echo
while read line; do
   dir=`echo $line|awk '{print $2}'`
   cd $dir;
   echo "Existem `ls $dir|wc -l` archives no diretorio $dir (`df -h $dir|grep -v \"Filesystem\|Sist\" | grep -v ^+|awk '{print $6, $4}'` Free)";
done < /tmp/v_arch_dir.lst


sqlplus  -s "/ as sysdba"<<!EOF_SQL3
set sqlprompt '' linesize 138 sqln off trim on feed off pages 4000 trimspool on head off timing off colsep ''
set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
PROMPT
PROMPT ARCHIVE LOG LIST
PROMPT
archive log list
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt QUANTIDADE DE ARCHIVES POR HORA + MEDIA DIA
prompt A MEDIA IDEAL E de 3 a 4 ARCHIVES POR HORA.
prompt SE FOR MAIOR QUE ISSO OS REDOS LOGFILES DEVEM SER AUMENTADOS.

set linesize 200 trimspool on feedback off head on

clear columns
Column SOMA format 9999 justify right
Column "MED/HOR" format 9999 justify right
Column "00h" format 999 justify right
Column "01h" format 999 justify right
Column "02h" format 999 justify right
Column "03h" format 999 justify right
Column "04h" format 999 justify right
Column "05h" format 999 justify right
Column "06h" format 999 justify right
Column "07h" format 999 justify right
Column "08h" format 999 justify right
Column "09h" format 999 justify right
Column "10h" format 999 justify right
Column "11h" format 999 justify right
Column "12h" format 999 justify right
Column "13h" format 999 justify right
Column "14h" format 999 justify right
Column "15h" format 999 justify right
Column "16h" format 999 justify right
Column "17h" format 999 justify right
Column "18h" format 999 justify right
Column "19h" format 999 justify right
Column "20h" format 999 justify right
Column "01h" format 999 justify right
Column "22h" format 999 justify right
Column "23h" format 999 justify right

clear breaks
clear computes
--break on trunc(completion_time)  on report
break on report skip 2
compute avg label "MEDIAS"  of "SOMA" on report
break on report skip 2
compute avg of "MED/HOR" on report

select trunc(completion_time) AS "DATA",
count(1) AS "SOMA",
count(1)/24 AS "MED/HOR",
sum(DECODE(to_char(completion_time, 'HH24'), '00', 1, 0)) AS "00h",
sum(DECODE(to_char(completion_time, 'HH24'), '01', 1, 0)) AS "01h",
sum(DECODE(to_char(completion_time, 'HH24'), '02', 1, 0)) AS "02h",
sum(DECODE(to_char(completion_time, 'HH24'), '03', 1, 0)) AS "03h",
sum(DECODE(to_char(completion_time, 'HH24'), '04', 1, 0)) AS "04h",
sum(DECODE(to_char(completion_time, 'HH24'), '05', 1, 0)) AS "05h",
sum(DECODE(to_char(completion_time, 'HH24'), '06', 1, 0)) AS "06h",
sum(DECODE(to_char(completion_time, 'HH24'), '07', 1, 0)) AS "07h",
sum(DECODE(to_char(completion_time, 'HH24'), '08', 1, 0)) AS "08h",
sum(DECODE(to_char(completion_time, 'HH24'), '09', 1, 0)) AS "09h",
sum(DECODE(to_char(completion_time, 'HH24'), '10', 1, 0)) AS "10h",
sum(DECODE(to_char(completion_time, 'HH24'), '11', 1, 0)) AS "11h",
sum(DECODE(to_char(completion_time, 'HH24'), '12', 1, 0)) AS "12h",
sum(DECODE(to_char(completion_time, 'HH24'), '13', 1, 0)) AS "13h",
sum(DECODE(to_char(completion_time, 'HH24'), '14', 1, 0)) AS "14h",
sum(DECODE(to_char(completion_time, 'HH24'), '15', 1, 0)) AS "15h",
sum(DECODE(to_char(completion_time, 'HH24'), '16', 1, 0)) AS "16h",
sum(DECODE(to_char(completion_time, 'HH24'), '17', 1, 0)) AS "17h",
sum(DECODE(to_char(completion_time, 'HH24'), '18', 1, 0)) AS "18h",
sum(DECODE(to_char(completion_time, 'HH24'), '19', 1, 0)) AS "19h",
sum(DECODE(to_char(completion_time, 'HH24'), '20', 1, 0)) AS "20h",
sum(DECODE(to_char(completion_time, 'HH24'), '21', 1, 0)) AS "21h",
sum(DECODE(to_char(completion_time, 'HH24'), '22', 1, 0)) AS "22h",
sum(DECODE(to_char(completion_time, 'HH24'), '23', 1, 0)) AS "23h"
FROM gv\$archived_log
where inst_id=thread#
GROUP BY trunc(completion_time)
ORDER BY 1
/



set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt QUANTIDADE DE ARCHIVES POR DIA + VOLUME GERADO(MB)
prompt A MEDIA IDEAL E de 3 a 4 ARCHIVES POR HORA.
prompt SE FOR MAIOR QUE ISSO OS REDOS LOGFILES DEVEM SER AUMENTADOS.

set lines 200 trimspool on feedback off head on
clear columns

PROMPT
PROMPT GERACAO DE ARCHIVES POR DIA/HORA
PROMPT
Column "QTD ARCHS DIA" format 99999 justify right
Column "MED ARCHS HOR" format 9999 justify right
Column "MB DIA" format 999999 justify right
Column "MED MB/HOR" format 999999 justify right
clear breaks
clear computes
break on thread# skip 1 on report
compute avg label "MEDIA INST"         of    "QTD ARCHS DIA"   on thread#
compute avg label "MEDIAS GER"         of    "QTD ARCHS DIA"   on report
compute avg label "MED ARCHS HOR INST" of    "MED ARCHS HOR"   on thread#
compute avg label "MED ARCHS HOR GER"  of    "MED ARCHS HOR"   on report
compute avg label "MB DIA INST"        of    "MB DIA"          on thread#
compute avg label "MB DIA GER"         of    "MB DIA"          on report
compute avg label "MED MB/HOR INST"    of    "MED MB/HOR"      on thread#
compute avg label "MED MB/HOR GER"     of    "MED MB/HOR"      on report

select distinct thread#,
trunc(COMPLETION_TIME) AS "DATA",
count(1) AS "QTD ARCHS DIA",
count(1)/24 AS "MED ARCHS HOR",
sum(blocks*block_size)/1024/1024 AS "MB DIA",
sum((blocks*block_size)/1024/1024)/24 AS "MED MB/HOR"
FROM gv\$archived_log h
where inst_id=thread#
GROUP BY thread#, trunc(h.COMPLETION_TIME)
ORDER BY 1,2
/






set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt TOP 15 ARCHIVE CREATOR

set head on newp none
Col username for a15
Col program for a25
Col machine for a25

select * from
(SELECT i.inst_id, s.sid, s.serial#, s.username, s.program, s.machine, i.block_changes
  FROM gv\$session s, gv\$sess_io i
 WHERE s.sid = i.sid
   AND i.block_changes > 0
   AND s.username is not null
 ORDER BY 1, 7 desc, 2, 3, 4, 6)
where rownum<=15
/

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt LISTAGEM DAS PROPRIEDADES DO BANCO
set linesize 200
set trimspool on
set feedback off
set head on
COLUMN property_name FORMAT A30
COLUMN property_value FORMAT A30
COLUMN description FORMAT A50
SELECT PROPERTY_NAME, PROPERTY_VALUE FROM database_properties order by 1;

set head off newp none feed off
clear columns
clear breaks
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt LISTAGEM DOS PARAMETROS CONFIGURADOS NO BANCO
set linesize 200 trimspool on feedback off head on
col inst_id format 999
col name format a40
col value format a70
break on name skip 1
select name, inst_id, value from gv\$parameter order by 1,2;

set head off newp none feed off
prompt
select '------------------------------------------------------------------' from dual;
prompt
prompt LISTAGEM DOS PARAMETROS DE AUDITORIA
set lines 200 pages 40000
set trimspool on
set feedback off
set head off
prompt
prompt  Security related initialization parameters
select '       '||name || '=' || value "PARAMETER"
from   sys.v_\$parameter
where  name in ('remote_login_passwordfile', 'remote_os_authent',
                'os_authent_prefix', 'dblink_encrypt_login',
                'audit_trail', 'transaction_auditing');
prompt
prompt Auditing Initialization Parameters
select '       '||name || '=' || value PARAMETER
from   sys.v_\$parameter where name like '%audit%'
/
set head on feed on
prompt Password file users
select * from sys.v_\$pwfile_users
/
prompt
set head on feed off
prompt Statement Audits Enabled on this Database
prompt
column user_name format a10
column audit_option format a40
select *
from   sys.dba_stmt_audit_opts
/

prompt
prompt Privilege Audits Enabled on this Database
select * from dba_priv_audit_opts
/

set head on feed on
prompt Object Audits Enabled on this Database
select (owner ||'.'|| object_name) object_name,
       alt, aud, com, del, gra, ind, ins, loc, ren, sel, upd, ref, exe
from   dba_obj_audit_opts
where  alt != '-/-' or aud != '-/-'
   or  com != '-/-' or del != '-/-'
   or  gra != '-/-' or ind != '-/-'
   or  ins != '-/-' or loc != '-/-'
   or  ren != '-/-' or sel != '-/-'
   or  upd != '-/-' or ref != '-/-'
   or  exe != '-/-'
/

prompt
set head on feed off
prompt Default Audits Enabled on this Database
select * from all_def_audit_opts
/

prompt
set head on feed on
prompt DIRECTORIES
col DIRECTORY_PATH format a60
select * from dba_directories
/

set feed off
prompt
alter database backup controlfile to trace as '/tmp/backup_controlfile_${ORACLE_SID}.$dmy'
/
create pfile='/tmp/init\$ORACLE_SID.ora' from spfile
/
!EOF_SQL3


##############################################
# SE UTILIZAR RAC
##############################################

ASM=`ps -ef | grep "dbw0_+ASM" | grep -v grep`
#if ! test -z "${ASM}"; then
if [ "" != "${ASM}" ]; then
   ASM=`ps -ef | grep "dbw0_+ASM" | grep ^$USER | grep -v grep`
   #if test -z "${ASM}"; then
   if [ "" = "${ASM}" ]; then
      echo
      echo "# Execute o comando /tmp/VerifyGrid.sh para verificacao do cluster com o usuario: `ps -ef | grep dbw0_+ASM | grep -v grep | cut -d\" \" -f1`"

echo "echo # VERIFICACAO DOS SERVICOS                                                          "  >/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "echo # Verifica se todos servicos estao no ar                                            " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "echo crs_stat -t ----------------- Verificando status do CRS                             " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "crs_stat -t                                                                              " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "echo crs_status -p --------------- Verificando AUTOSTART DOS SERVICOS CRS                " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "crs_stat -p | egrep ^\"(NAME|AUTO_START)\"                                               " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "# crsctl check crs --------------- Check do CRS                                          " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "crsctl check crs                                                                         " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "echo # ocrcheck -t --------------- Verificando integridade do OCR                        " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "ocrcheck                                                                                 " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "echo # ocrconfig -showbackup ----- Verificando backup do OCR                             " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "ocrconfig -showbackup                                                                    " >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "# crsctl query css votedisk ------  Verifica configuracao e espelhamento dos Voting Disks" >>/tmp/VerifyGrid.sh
echo "echo                                                                                     " >>/tmp/VerifyGrid.sh
echo "crsctl query css votedisk                                                                " >>/tmp/VerifyGrid.sh

   else
      sqlplus  -s "/ as sysdba"<<"      !EOF_SQL3"

      set sqlprompt '' linesize 138 sqln off trim on feed off pages 4000 trimspool on head off timing off colsep ''
      prompt
      set head off newp none feed off
      prompt
      select '------------------------------------------------------------------' from dual;
      prompt
      prompt VERIFICACAO DOS SERVICOS
      prompt
      prompt Verifica se todos servicos estao no ar
      prompt
      prompt crs_status -t
      prompt
      !crs_stat -t
      prompt
      prompt

      prompt Verifica se servicos estao AUTO_START
      prompt
      prompt crs_stat
      prompt
      !crs_stat -p | egrep ^"(NAME|AUTO_START)"
      prompt
      prompt

      prompt Verifica situacao do CRS
      prompt
      prompt crsctl check crs
      prompt
      !crsctl check crs
      prompt
      prompt

      prompt Verifica integridade do OCR
      prompt
      prompt ocrcheck
      prompt
      !ocrcheck
      prompt
      prompt

      prompt Verifica Backup do OCR
      prompt
      prompt ocrconfig -showbackup
      prompt
      !ocrconfig -showbackup
      prompt
      prompt

      prompt Verifica configuracao do espelhamento dos Voting Disks
      prompt
      prompt crsctl query css votedisk
      prompt
      !crsctl query css votedisk
      prompt
      prompt


      !EOF_SQL3
   fi
fi

echo
echo
echo "------------------------------------------------------------------"
echo "Arquivos de configuracao do banco $ORACLE_SID"
echo "------------------------------------------------------------------"
echo
echo CRONTAB
echo

cron=`crontab -l`
#if ! test -z "${cron}"; then
if [ "" != "${cron}" ]; then

   crontab -l
else
   echo Nao ha crontab para o usuario $USER
fi

echo
echo "------------------------------------------------------------------"
echo

bashprof=`cat ~/.bash_profile 2>/dev/null`
#if test -n "${bashprof}"; then
if [ "" != "${bashprof}" ]; then
   echo
   echo .BASH_PROFILE
   echo
   cat ~/.bash_profile
else
   prof=`cat ~/.profile 2>/dev/null`
   if [ "" != "${prof}" ]; then
   echo
   echo .PROFILE
   echo
      cat ~/.profile
   fi
fi


echo
echo "------------------------------------------------------------------"
echo
echo
echo PFILE
echo

if test -f "$ORACLE_HOME/dbs/init${ORACLE_SID}.ora"; then
   cat "$ORACLE_HOME/dbs/init${ORACLE_SID}.ora"
else
#   dbname=`sed -e "s/[' ']*"/"/g" /tmp/v_instname.lst`
#   pfiledir="$ORACLE_BASE/admin/$dbname/pfile"
#   cd $pfiledir
#   init=`ls init*ora*`
#   if test -f $init; then
#     cat $init
#   else
     echo PFILE nao encontrado
#   fi
fi
echo
echo "------------------------------------------------------------------"
echo
if test -f "/tmp/init${ORACLE_SID}.ora"; then
   echo SPFILE
   echo
   cat /tmp/init${ORACLE_SID}.ora
   echo
else
   echo
   echo Nao utiliza SPFILE
   echo
fi
echo
echo "------------------------------------------------------------------"
echo
echo TNSNAMES.ORA
if test -f "$ORACLE_HOME/network/admin/tnsnames.ora"; then
   echo "$ORACLE_HOME/network/admin/tnsnames.ora"
   cat $ORACLE_HOME/network/admin/tnsnames.ora
else
   if test -f "$TNS_ADMIN/tnsnames.ora"; then
      echo "$TNS_ADMIN/tnsnames.ora"
      cat $TNS_ADMIN/tnsnames.ora
   else
      echo TNSNAMES.ORA nao encontrado.
   fi
fi
echo
echo "------------------------------------------------------------------"
echo
echo SQLNET.ORA
echo
if test -f "$ORACLE_HOME/network/admin/sqlnet.ora"; then
   echo "$ORACLE_HOME/network/admin/sqlnet.ora"
   cat $ORACLE_HOME/network/admin/sqlnet.ora
else
   if test -f "$TNS_ADMIN/sqlnet.ora"; then
      echo "$TNS_ADMIN/sqlnet.ora"
      cat $TNS_ADMIN/sqlnet.ora
   else
      echo SQLNET.ORA nao encontrado.
   fi
fi
echo "------------------------------------------------------------------"
echo
echo LISTENER.ORA
if test -f "$ORACLE_HOME/network/admin/listener.ora"; then
   echo "$ORACLE_HOME/network/admin/listener.ora"
   cat $ORACLE_HOME/network/admin/listener.ora
else
   if test -f "$TNS_ADMIN/listener.ora"; then
      echo "$TNS_ADMIN/listener.ora"
      cat $TNS_ADMIN/listener.ora
   else
      echo LISTENER.ORA nao encontrado.
   fi
fi
echo
echo LISTENER STATUS
lsnrctl status
echo
echo
echo
echo "------------------------------------------------------------------"
echo
echo CONTROLFILE
echo
echo "alter database backup controlfile to trace as '/tmp/backup_controlfile_${ORACLE_SID}.$dmy'"
cat  /tmp/backup_controlfile_${ORACLE_SID}.$dmy
echo
echo "------------------------------------------------------------------"
echo
sqlplus -s "/ as sysdba" >/dev/null<<EOF
set pages 0 trimspool on feedback off head off timing off colsep ''
spool /tmp/v_dump_dir.lst
select value from v\$parameter where value like '%bdump%' or name = 'background_dump_dest';
spool off
EOF
dumpdir=`cat /tmp/v_dump_dir.lst`
alertlog="alert_${ORACLE_SID}.log"

echo -e "SINTETIZANDO ERROS DO ALERT=${dumpdir}/${alertlog} \c"

dmy=`date +%d%m%y_%H%M`
cd $dumpdir
alert=alert_${ORACLE_SID}.log
qtdlinhas=`cat ${alert} | wc -l `
echo
echo
echo "O ALERT.LOG POSSUI ${qtdlinhas} LINHAS"
echo
> /tmp/erros_do_alertlog.lst
datai=`head -100 ${dumpdir}/${alertlog} | grep "2018\|2019\|2020\|2021\|2022" | head -1`
dataf=`tail -100 ${dumpdir}/${alertlog} | grep "2018\|2019\|2020\|2021\|2022" | tail -1`

echo "LISTAGEM SINTETICA DOS ERROS REPORTADOS NO ALERT.LOG DO BANCO $ORACLE_SID" > /tmp/erros_do_alertlog.$dmy
echo >> /tmp/erros_do_alertlog.$dmy

echo "REGISTRO INICIAL DO LOG ($datai)" >> /tmp/erros_do_alertlog.$dmy
echo "REGISTRO   FINAL DO LOG ($dataf)" >> /tmp/erros_do_alertlog.$dmy
echo >> /tmp/erros_do_alertlog.$dmy
echo > /tmp/10erros_do_alertlog.tm1
echo > /tmp/10erros_do_alertlog.tm2

counter=0
while read line;
do
counter=`expr $counter + 1`
testdat=`echo "${line}"|cut -d" " -f1`
case ${testdat} in
      Sun|Mon|Tue|Wed|Thu|Fri|Sat|Dom|seg|ter|qua|qui|sex|sab) dataerr=${line}
esac
testerr=`echo "${line}"|cut -c1-4`
if [ "${testerr}" = "ORA-" ]; then
   echo "${dataerr} - ${line}" >> /tmp/10erros_do_alertlog.tm1
   erro=""
   erro=`echo "${line}" | cut -d' '  -f1 | cut -d: -f1`
   found=""
   found=`grep ${erro} /tmp/erros_do_alertlog.lst`
   if [ "${erro}" != "${found}" ]; then
      count=`grep "${erro}" ${dumpdir}/${alertlog} | wc -l`
      echo "${count} vez(es) - ${line}" >>  /tmp/erros_do_alertlog.$dmy
      echo ${erro} >> /tmp/erros_do_alertlog.lst
   fi
fi
done < ${dumpdir}/${alertlog}
echo >> /tmp/10erros_do_alertlog.tm1

echo
echo -e "BUSCANDO ULTIMOS ERROS NO ALERT \c"
echo

echo > /tmp/10erros_do_alertlog.$dmy
echo "LISTAGEM DOS 10 ULTIMOS ERROS REPORTADOS NO ALERT.LOG DO BANCO $ORACLE_SID" >> /tmp/10erros_do_alertlog.$dmy
echo >> /tmp/10erros_do_alertlog.$dmy

while read line;
do
echo ${line} >> /tmp/10erros_do_alertlog.tm2
done < /tmp/10erros_do_alertlog.tm1
echo


cat /tmp/erros_do_alertlog.$dmy
echo
cat /tmp/10erros_do_alertlog.tm2  | tail -10 >> /tmp/10erros_do_alertlog.$dmy
cat /tmp/10erros_do_alertlog.$dmy
echo
echo
echo -Para ZERAR o ALERT.LOG guardando o antigo, copie e cole o seguinte comando:
echo mv ${dumpdir}/${alertlog} ${dumpdir}/${alertlog}.$dat
echo
echo
echo ------------------------------------------------------------------
echo
echo ----  VERIFICANDO BACKUP RMAN  ----
echo
echo ------------------------------------------------------------------
echo
sqlplus  -s "/ as sysdba"<<!EOF_SQL4

set sqlprompt '' linesize 138 sqln off trim on feed off pages 4000 trimspool on head off timing off colsep ''
select '------------------------------------------------------------------' from dual;
prompt BACKUP RMAN
select '------------------------------------------------------------------' from dual;
prompt


Set head on
COLUMN status       FORMAT a15           HEADING 'Status'
COLUMN tag          FORMAT a40           HEADING 'Tag'
COLUMN elapsed_minutes   FORMAT 999,99   HEADING 'Elapsed|Minutes'
COLUMN deleted           FORMAT a8       HEADING 'Deleted?'

prompt
prompt Time of backup by TAG.
prompt

SELECT
   tag
   ,DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')        status
  , sum(bp.elapsed_seconds)/60       elapsed_minutes
FROM
    v\$backup_set    bs
  , v\$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
GROUP BY
    bp.status, bp.tag
order by  1
/

prompt
prompt
prompt ULTIMO BACKUP FULL DO BANCO
select 'Banco  = '||name "Ultimo Backup FULL - RMAN" from v\$database
union
select 'Data   = '||to_char(max(ldate)) "Ultimo Backup"
               from (
                    select df.file#, max(bdf.completion_time) ldate
                      from gv\$backup_datafile bdf, gv\$datafile df
                     where bdf.file# = df.file#
   --                    and bdf.incremental_level = 0
                     group by df.file#
                     having max(df.creation_time) < max(bdf.completion_time)) xxx
union
select 'Dias   = '||to_char(sysdate-min(bdays), 'FM99999990') Dias
               from (
                    select df.file#, max(bdf.completion_time) bdays
                      from gv\$backup_datafile bdf, gv\$datafile df
                     where bdf.file# = df.file#
   --                    and bdf.incremental_level = 0
                     group by df.file#
                     having max(df.creation_time) < max(bdf.completion_time)) yyy;


set head on feed off
prompt
prompt Datafiles backed up during past 24 Hours
col "Datafiles backed up" for a20

SELECT dbfiles||' from '||numfiles "Datafiles backed up",
cfiles "Control Files backed up", spfiles "SPFiles backed up"
FROM (select count(*) numfiles from sys.v_\$datafile),
(select count(*) dbfiles
from sys.v_\$backup_datafile a, sys.v_\$datafile b
where a.file# = b.file#
and a.completion_time > sysdate - 1),
(select count(*) cfiles from sys.v_\$backup_datafile
where file# = 0 and completion_time > sysdate - 1),
(select count(*) spfiles from sys.v_\$backup_spfile
where completion_time > sysdate - 1);


prompt
prompt Archlog files backed up during past 24 Hours
col "Archlog files backed up" for a20

SELECT backedup||' from '||archived "Archlog files backed up",
ondisk "Archlog files still on disk"
FROM (select count(*) archived
from sys.v_\$archived_log where completion_time > sysdate - 1),
(select count(*) backedup from sys.v_\$archived_log
where backup_count > 0
and completion_time > sysdate - 1),
(select count(*) ondisk from sys.v_\$archived_log
where archived = 'YES' and deleted = 'NO')
/

/
prompt
prompt
prompt LISTA BLOCOS CORROMPIDOS POR TABLESPACE/DATAFILES
prompt
set feed on
col tablespace_name for a30
col CORRUPTION_CHANGE# for 9999999999999999999999999
select d.tablespace_name, c.FILE#, d.file_name, count(1) corrupted from V\$DATABASE_BLOCK_CORRUPTION c, dba_data_files d
 where c.file#=d.file_id
 group by d.tablespace_name,c.FILE#,d.file_name
 order by 1,2;

prompt



!EOF_SQL4


echo
echo SHOW ALL PARAMETERS
rman target /<<EOF
show all;
exit
EOF



echo
echo REPORT NEED BACKUP REDUNDANCY 1
rman target /<<EOF
report need backup redundancy 1;
exit
EOF

echo
echo ------------------------------------------------------------------
echo
echo "PROCESSOS $USER"
echo
ps -ef | grep ^$USER | grep $ORACLE_SID | grep -v LOCAL | grep -v levantamento | grep -v grep | sort -nk 5 | cut -c1-130



) | tee levantamento_$ORACLE_SID.$dmy

echo
echo
echo Relatorio gerado: levantamento_$ORACLE_SID.$dmy
echo
echo
echo
echo
done
