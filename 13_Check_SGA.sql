select
COMPONENT
,ROUND(CURRENT_SIZE/1024/1024) AS TAMANHO_ATUAL
,ROUND(MIN_SIZE/1024/1024) AS TAMANHO_MINIMO
,ROUND(MAX_SIZE/1024/1024) AS TAMANHO_MAXIMO
,LAST_OPER_TYPE
,LAST_OPER_TIME
,ROUND(GRANULE_SIZE/1024/1024) AS GRANULE_SIZE from v$sga_dynamic_components;

--Uso da sga
select round(used.bytes /1024/1024 ,2) used_mb
, round(free.bytes /1024/1024 ,2) free_mb
, round(tot.bytes /1024/1024 ,2) total_mb
from (select sum(bytes) bytes
from v$sgastat
where name != 'free memory') used
, (select sum(bytes) bytes
from v$sgastat
where name = 'free memory') free
, (select sum(bytes) bytes
from v$sgastat) tot ;

--Tamanho total
SELECT sum(value)/1024/1024 "TOTAL SGA (MB)" FROM v$sga;

--Verificando as pools
Select POOL, Round(bytes/1024/1024,0) Free_Memory_In_MB From V$sgastat Where Name Like '%free memory%';

--Alteração da sga no oracle 19c
ALTER SYSTEM SET sga_target = 4G  scope=spfile; 
ALTER SYSTEM SET = 4G scope=spfile;

