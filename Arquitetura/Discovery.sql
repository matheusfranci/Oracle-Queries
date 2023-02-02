-- script discovery_oracle.sql 
-- Atualizado em 11-01-2023 por Marcos Ferreira

/*

	-- INSTRUÇÕES SCRIPT  discovery_oracle.sql
	-- Rodar este script no SQLPLUS; caso seja executado no sqldeveloper, rodar como “script” (tecla F5). 
	-- O RESULTADO DEVE SER ENTREGUE EM FORMATO “TXT”.
	-- NO NOME DO ARQUIVO DE SAÍDA, INCLUIR O NOME DO CLIENTE PARA FACILITAR O ENTENDIMENTO. EX: resultados_discovery_cliente.txt

*/

-- spoolling 
set timing off 
spo resultados_discovery.txt 

-- parametros sqlplus
set feed off 
set lines 300 pages 999	
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';


/* *** DADOS GERAIS *** */ 
-- NOME DO BANCO e outras caracteristicas 
select name, log_mode, force_logging,  flashback_on, GUARD_STATUS, CONTROLFILE_TYPE, SWITCHOVER_STATUS
from v$database; 
prompt 

-- VERSAO DO BANCO DE DADOS 
col BANNER for a100 
prompt	VERSAO 
select banner from v$version 
union 
select dbms_utility.port_string from dual;
prompt 

-- DADOS DE INSTANCIA 
prompt INSTANCIAS 
select inst_id, status, instance_name, host_name 
from gv$instance;

-- PARAMETROS DO BANCO DE DADOS 
prompt PARAMETROS DB 
Set line 200
col PROPERTY_NAME for a40  
col PROPERTY_VALUE form a80
select 	PROPERTY_NAME,
		PROPERTY_VALUE 
from database_properties
order by 1;
prompt 

-- TAMANHO DO BANCO DE DADOS 
prompt TAMANHO DO BANCO DE DADOS
col size_gb for 99999999999
break on report
compute sum of size_gb on report
	select 'datafile' name, round(sum(bytes)/1024/1024/1024,2) size_gb from v$datafile
	union 
	select 'tempfile' name, round(sum(bytes)/1024/1024/1024,2) size_gb from v$tempfile
	union
	select 'controlfile' name, (BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 size_gb from v$controlfile;
prompt 


-- SCHEMAS E TAMANHOS 
prompt SCHEMAS E TAMANHOS
col owner for a30 
select owner, round(sum(bytes)/1024/1024/1024,2) as tamanho_GB 
	from dba_segments 
	group by owner 
	order by 2;
prompt

-- DADOS DE NLS 
col PARAMETER for a40
prompt NLS PARAMETERS 
SELECT a.*
  FROM NLS_DATABASE_PARAMETERS a;
prompt 

-- PARAMETROS DAS INSTANCIAS
col name for a70  
col value for a110
prompt INSTANCES PARAMETERS  
SELECT inst_id, 
	 substr(name,0,512) name
	,NVL(SUBSTR(value,0,512) , 'null value') value 
  FROM  gv$parameter
  ORDER BY 1,2;
prompt 

-- TABLESPACES 
prompt TABLESPACES 
SELECT
	d.tablespace_name,
	d.status,
	d.contents PTYPE,
	d.extent_management EXTENT_MGMT,
	round(NVL(sum(df.bytes) / 1024 / 1024, 0),2) SIZE_MB,
	round(NVL(sum(df.bytes) - NVL(sum(f.bytes), 0), 0)/1024/1024,0) USED_MB,
	round(NVL((sum(df.bytes) - NVL(sum(f.bytes), 0)) / sum(df.bytes) * 100, 0),0) USED_PERCENT,
	d.initial_extent,
	NVL(d.next_extent, 0) NEXT_EXTENT,
	round(NVL(max(f.bytes) / 1024 / 1024, 0),0) LARGEST_FREE 
FROM dba_tablespaces d
	,dba_data_files df
	,dba_free_space f 
WHERE d.tablespace_name = df.tablespace_name  
   AND df.tablespace_name = f.tablespace_name  (+) 
   AND df.file_id  = f.file_id  (+) 
GROUP BY d.tablespace_name, d.status, d.contents, d.extent_management
	  ,d.initial_extent, d.next_extent
 ORDER BY 1,2,3;
prompt 


-- ocupacao logica por pdb (exibe a quantia de objetos por tipo, e tamanho) 
col PDB_NAME for a15 
select 
	p.pdb_name,
	s.segment_type,
	count(*),  
	round(sum(s.bytes)/1024/1024/1024,2) tam_gb,
	s.con_id 
from cdb_segments s,
	cdb_pdbs p
where p.con_id=s.con_id
group by p.pdb_name, s.con_id, s.segment_type 
order by 1,3; 

 
/* *** DADOS DE MEMORIA *** */
-- SGA
prompt SGA INFO 
col value for 999999999999999
SELECT name,value  FROM v$sga;
prompt 

-- ADVICE SGA 
COL  SGA_SIZE FOR 999999999999999
COL ESTD_PHYSICAL_READS FOR 999999999999999
SELECT inst_id, SGA_SIZE, SGA_SIZE_FACTOR, ESTD_PHYSICAL_READS 
FROM gv$sga_target_advice;   
prompt   

-- PGA 
-- ADVICE PGA 
prompt PGA INFO 
COL PGA_TARGET_FOR_ESTIMATE FOR 999999999999999
COL ESTD_EXTRA_BYTES_RW FOR 999999999999999
SELECT inst_id, 
	PGA_TARGET_FACTOR, PGA_TARGET_FOR_ESTIMATE,
	ESTD_PGA_CACHE_HIT_PERCENTAGE,
	ESTD_EXTRA_BYTES_RW, ESTD_OVERALLOC_COUNT
	FROM gV$PGA_TARGET_ADVICE ORDER BY 1;
prompt 

-- maximo de pga utilizada: 
prompt PGA: MAXIMO UTILIZACAO 
select  c.name || ' - ' || to_char (to_number(a.value) + to_number(b.value) ) as pga_maxima_utilizada  
from 
	(select  VALUE from gv$parameter where name = 'sga_max_size') a,
	(select value from gV$PGASTAT where name = 'total PGA allocated')b,
	v$database c ;
prompt 


/* *** PHYSICAL MEMORY ***/ 
prompt PHYSICAL MEMORY 
select *
  from (select min(to_char(b.begin_interval_time, 'dd-mm-yy hh24:mi')) inicio,
               max(to_char(b.end_interval_time, 'dd-mm-yy hh24:mi')) fim,
               round(max(case
                           when a.stat_name = 'PHYSICAL_MEMORY_BYTES' then
                            a.value
                           else
                            null
                         end) / 1024 / 1024,
                     0) - round(max(case
                                      when a.stat_name = 'FREE_MEMORY_BYTES' then
                                       a.value
                                      else
                                       null
                                    end) / 1024 / 1024,
                                0) PHYSICAL_USED_MEM,
               round(max(case
                           when a.stat_name = 'PHYSICAL_MEMORY_BYTES' then
                            a.value
                           else
                            null
                         end) / 1024 / 1024,
                     0) PHYSICAL_TOTAL_MEM,
               a.snap_id
          from dba_hist_osstat a, dba_hist_snapshot b, dba_hist_osstat c
         where a.dbid = b.dbid
           and a.snap_id = b.snap_id
           and a.snap_id - 1 = c.snap_id
           and b.end_interval_time > sysdate - 10
         group by a.snap_id
         order by 1) b;
prompt 		 
		 
		 
/* *** DADOS DE CPU  ***/ 

col STAT_NAME form A30
col VALUE form a10
col comments form a70
prompt CPU e MEMORIA 
select STAT_NAME,
		to_char(VALUE) as VALUE  ,
		COMMENTS 
	from v$osstat 
	where stat_name  IN ('NUM_CPUS','NUM_CPU_CORES','NUM_CPU_SOCKETS')
union
	select STAT_NAME,
			round(VALUE/1024/1024/1024,2) || ' GB'  ,COMMENTS 
		from v$osstat 
		where stat_name  IN ('PHYSICAL_MEMORY_BYTES');
prompt 

-- DEMAIS UTILIZACOES DO BANCO DE DADOS
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';
prompt CONSUMO DE CPU E I/O DA SEMANA RAC AWARE
SELECT INSTANCE_NUMBER,
       min(to_char(begin_time, 'dd-mm-yyyy-hh24:mi')) inicio,
       max(to_char(end_time, 'dd-mm-yyyy-hh24:mi')) fim,
       round(sum(case metric_name when 'Host CPU Utilization (%)' then average end),1) Host_CPU_util,
       round(sum(case metric_name when 'Physical Read Total Bytes Per Sec' then average end) / 1024 / 1024, 1) Physical_Read_MBps,
       round(sum(case metric_name when 'Physical Write Total Bytes Per Sec' then average end) / 1024 / 1024, 1) Physical_Write_MBps,
       round(sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then average  end), 1) Physical_Read_IOPS,
       round(sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end), 1) Physical_write_IOPS,
       round(sum(case metric_name when 'Redo Writes Per Sec' then average end), 1) Physical_redo_IOPS,
       round(sum(case metric_name when 'Network Traffic Volume Per Sec' then average end) / 1024 / 1024, 1) Network_Mb_per_sec,
       snap_id
  from dba_hist_sysmetric_summary
where trunc(begin_time) > trunc(sysdate - 7)
group by INSTANCE_NUMBER,snap_id
order by INSTANCE_NUMBER,snap_id;
prompt 
		
-- OS STAT 
COL VALUE FOR 999999999999999	
SELECT * FROM GV$OSSTAT;	
prompt 

-- DADOS DE UTILIZACAO DE FEATURES 
-- in memory 
prompt FEATURES: IN-MEMORY (cdb) 
select distinct inmemory from cdb_tables;
prompt 

-- particionamento 
prompt FEATURES: PARTITIONING 
select * from v$option where parameter='Partitioning';
select name, version, last_usage_date,currently_used 
	from DBA_FEATURE_USAGE_STATISTICS where upper(name) like '%PARTITION%';
prompt 



-- cdb_pdbs
prompt FEATURES: Multinenant 
SELECT CDB FROM V$DATABASE;
prompt 
prompt PDBS
col name for a10 
SELECT NAME, CON_ID, DBID, CON_UID, GUID 
	FROM V$CONTAINERS 
	ORDER BY CON_ID;
prompt 


-- licenciamento 
prompt SESSOES, ETC
SELECT a.*   
	FROM v$license a;
prompt 

SELECT SESSIONS_HIGHWATER ,SESSIONS_MAX ,SESSIONS_CURRENT
	FROM v$license;
prompt   

-- REDO LOG 
prompt REDO LOG
prompt 
prompt REDO LOG: TAMANHO DOS REDOS POR THREAD 
select db.name, thread#,  count(*), bytes/1024/1024 as tam_MB 
	from v$log,
		 v$database db 
	group by bytes, thread#, db.name;
	
	
prompt REDO LOG:	Historico de archived_log / dia
select THREAD#,
		to_char(COMPLETION_TIME,'MM-DD') "MM-DD",
		count(*) QTD, 
		round(sum(BLOCKS*BLOCK_SIZE)/1024/1024) SIZE_MB 
	from gv$archived_log 
	group by THREAD#,to_char(COMPLETION_TIME,'MM-DD') 
	order by 1,2;
prompt 

prompt REDO LOG: UTILIZACAO DETALHADA 
select 
    to_char(first_time,'DD-MM-YYYY') day,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'00',1,0)),'99') hour_00,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'01',1,0)),'99') hour_01,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'02',1,0)),'99') hour_02,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'03',1,0)),'99') hour_03,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'04',1,0)),'99') hour_04,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'05',1,0)),'99') hour_05,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'06',1,0)),'99') hour_06,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'07',1,0)),'99') hour_07,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'08',1,0)),'99') hour_08,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'09',1,0)),'99') hour_09,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'10',1,0)),'99') hour_10,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'11',1,0)),'99') hour_11,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'12',1,0)),'99') hour_12,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'13',1,0)),'99') hour_13,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'14',1,0)),'99') hour_14,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'15',1,0)),'99') hour_15,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'16',1,0)),'99') hour_16,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'17',1,0)),'99') hour_17,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'18',1,0)),'99') hour_18,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'19',1,0)),'99') hour_19,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'20',1,0)),'99') hour_20,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'21',1,0)),'99') hour_21,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'22',1,0)),'99') hour_22,
    to_char(sum(decode(substr(to_char(first_time,'DDMMYYYY:HH24:MI'),10,2),'23',1,0)),'99') hour_23
from
    v$log_history 
group by
    to_char(first_time,'DD-MM-YYYY')
order by
    1;
prompt 


/* *** backup *** */ 
prompt BACKUP 
set line 200 pages 999
col inicio form a20
col termino form a20
select * from (
	select INPUT_TYPE, 
	to_char(START_TIME,'DD-MM-YYYY HH24:MI:SS') as INICIO, 
	to_char(END_TIME,'DD-MM-YYYY HH24:MI:SS') as TERMINO,
	ELAPSED_SECONDS sec,  -- melhorar esta coluna 
	TRUNC((END_TIME - START_TIME)*24*60) as TEMP_MIN,
	round(INPUT_BYTES/1024/1024/1024) as "INPUT SIZE(GB)", 
	round(OUTPUT_BYTES/1024/1024/1024) as "BKP SIZE(GB)", 
	round(COMPRESSION_RATIO) as "COMPRESS RATIO",
	OUTPUT_DEVICE_TYPE as DEVICE, 
	STATUS
from v$RMAN_BACKUP_JOB_DETAILS
	order by start_time desc)
	where rownum < 180;
set pages 999
prompt 

spo off 
