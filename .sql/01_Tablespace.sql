set feed off
column DT new_value DATA noprint
select to_char(sysdate, 'DDMMYYYY_HH24MI') DT from dual;

set feed on pages 4000 verify off head on lines 200
accept ts_tablespace prompt "INFORME O NOME DA TABLESPACE PARA VER UTILIZACAO (<ENTER>=TODAS) :  "
prompt
accept percent prompt "INFORME o PERCENTUAL MAXIMO PARA ALERTA (<ENTER>=95) :  "
prompt
prompt TABLESPACE INFO
prompt ---------------;
col xtype   head "Type"             for a9
col xtbsn   head "Tablespace"       for a25
col xext    head "Ext|Mng"          for a3 trunc
col xseg    head "Seg|Mng"          for a3 trunc
col xlog    head "Log"              for a3 trunc
col xsta    head "Sta"              for a3 trunc
col xmaxs   head "MaxSize|(MB)"     for 99999999999
col xsize   head "Size|(MB)"        for 99999999
col xused   head "Used|(MB)"        for 99999999
col xfree   head "Free|(MB)"        for 9999999
col xfreem  head "Free|Of Max|(MB)" for 99999999999
col xusedp  head "%Used"            for 999
col xusedm  head "%Used|Of Max"     for 999
col xwarn1  head "W|a|r|n"          for a1
col xwarn2  head "W|a|r|n"          for a1
col xqtdseg head "Qtd|Segments"     for 9999999
col xqtddf  head "Qtd|Datafiles"    for 9999999
BREAK ON xtype skip 1 ON report
COLUMN DUMMY NOPRINT;
COMPUTE SUM OF xsize   ON xtype
COMPUTE SUM OF xused   ON xtype
COMPUTE SUM OF xfree   ON xtype
COMPUTE SUM OF xfreem  ON xtype
COMPUTE SUM OF xqtddf  ON xtype
COMPUTE SUM OF xqtdseg ON xtype
COMPUTE SUM OF xsize   ON report
COMPUTE SUM OF xused   ON report
COMPUTE SUM OF xfree   ON report
COMPUTE SUM OF xfreem  ON report
COMPUTE SUM OF xqtddf  ON report
COMPUTE SUM OF xqtdseg ON report
COMPUTE SUM label "TOTAL"       OF xmaxs ON xtype
COMPUTE SUM label "TOTAL GERAL" OF xmaxs ON Report
spool /tmp/tbs_${ORACLE_SID}_&DATA
select    tbs.tipo                                                                      xtype
          ,nvl(data.tablespace_name,nvl(mbfree.tablespace_name,'UNKOWN'))               xtbsn
          ,tbs.ext_management                                                           xext
          ,tbs.seg_management                                                           xseg
          ,tbs.logging                                                                  xlog
          ,tbs.status                                                                   xsta
          ,nvl(qtddf.qtddf,0)                                                           xqtddf
          ,nvl(qtdseg.qtd,0)                                                            xqtdseg
          ,round(MaxMBytes)                                                             xmaxs
          ,round(MBytes)                                                                xsize
          ,round(MBytes-MBytes_Livre)                                                   xused
          ,round(MBytes)-round(MBytes-MBytes_Livre)                                     xfree
          ,round(MaxMBytes)-round(MBytes-MBytes_Livre)                                  xfreem
          ,ceil(100*round(MBytes-MBytes_Livre)/ceil(MBytes))                            xusedp
          ,decode(least(ceil(100*round(MBytes-MBytes_Livre)/ceil(MBytes)),nvl('&PERCENT',95)),nvl('&PERCENT',95),'*', ' ')     xwarn1
          ,ceil(100*round(MBytes-MBytes_Livre)/ceil(MaxMBytes))                                    xusedm
          ,decode(least(ceil(100*round(MBytes-MBytes_Livre)/ceil(MaxMBytes)),nvl('&PERCENT',95)),nvl('&PERCENT',95),'*', ' ')  xwarn2
from
( select nvl(sum(bytes)/1024/1024,0) MBytes_Livre, tablespace_name
       from sys.dba_free_space group by tablespace_name ) mbfree,
(  select tablespace_name,
        (sum(decode(nvl(MaxBytes,0),0,Bytes,MaxBytes)/1024/1024) - sum(Bytes)/1024/1024) MaxBytes_Livre,
        (sum(Bytes)/1024/1024) - sum(Bytes)/1024/1024 MaxMBytes_Livre
       from sys.dba_data_files group by tablespace_name ) maxmbfree,
     ( select sum(decode(nvl(MaxBytes,0),0,Bytes,MaxBytes))/1024/1024 MaxMBytes, sum(Bytes)/1024/1024 MBytes, tablespace_name
       from sys.dba_data_files group by tablespace_name ) data,
     ( select tablespace_name, decode(status,'READ ONLY','RO',status) status, logging, contents tipo, extent_management ext_management,
       segment_space_management seg_management from dba_tablespaces) tbs,
     ( select s.tablespace_name, count(1) qtd from dba_segments s, dba_tablespaces t
        where t.tablespace_name=s.tablespace_name and t.contents='PERMANENT' group by s.tablespace_name) qtdseg,
     ( select tablespace_name, count(1) qtddf from dba_data_files
        group by tablespace_name) qtddf
where mbfree.tablespace_name (+) = data.tablespace_name
  and maxmbfree.tablespace_name (+) = data.tablespace_name
  and tbs.tablespace_name=mbfree.tablespace_name
  and tbs.tablespace_name like upper(nvl('&ts_tablespace','%'))
  and tbs.tablespace_name = qtdseg.tablespace_name (+)
  and tbs.tablespace_name = qtddf.tablespace_name (+)
union
SELECT
   'TEMPORARY'                                            xtype
  , tbs2.tablespace_name                                  xtbsn
  , tbs2.extent_management                                xext
  , tbs2.segment_space_management                         xseg
  , tbs2.logging                                          xlog
  , tbs2.status                                           xsta
  , 0                                                     xqtdDf
  , 0                                                     xqtdSeg
  , round(NVL(tempf.MaxMBytes, 0))                        xmaxs
  , round(NVL(tempf.MBytes, 0))                           xsize
  , round(NVL(used.MBytes, 0))                            xused
  , round((NVL(tempf.MBytes, 0)-NVL(used.MBytes, 0)))     xfree
  , round((NVL(tempf.MaxMBytes, 0)-NVL(used.MBytes, 0)))  xfreem
  , TRUNC(NVL(used.MBytes / tempf.MBytes * 100, 0))       xused
  ,' '                                                    xwarn1
  , TRUNC(NVL(used.MBytes / tempf.MaxMBytes * 100, 0))    xusedm
  ,' '                                                    xwarn2
FROM sys.dba_tablespaces tbs2
  , ( select tablespace_name, decode(status,'READ ONLY','RO',status) status, sum(decode(MaxBytes,0,Bytes,MaxBytes))/1024/1024 MaxMBytes, sum(Bytes)/1024/1024 MBytes
      from dba_temp_files
      group by tablespace_name, status
    ) tempf
  , ( select ss.tablespace_name,sum(ss.used_blocks*ts.blocksize)/1024/1024 MBytes
           from gv$sort_segment ss, sys.ts$ ts
           where ss.tablespace_name = ts.name
           group by ss.tablespace_name
    ) used
  , v$sort_segment  sort
WHERE
      tbs2.tablespace_name = tempf.tablespace_name(+)
  AND tbs2.tablespace_name = used.tablespace_name(+)
  AND tbs2.tablespace_name = sort.tablespace_name(+)
  AND tbs2.contents like 'TEMPORARY'
  and tbs2.tablespace_name like upper(nvl('&ts_tablespace','%'))
order by 1, 2
/
SPOOL OFF
PROMPT
PROMPT spool at /tmp/tbs_${ORACLE_SID}_&DATA..lst
PROMPT

prompt
ACCEPT NONE PROMPT "<ENTER>=LISTA DATAFILES   <CONTROL+C>=CANCELA"
prompt
prompt
prompt DATAFILE INFO
prompt -------------;
accept df_tablespace prompt "INFORME O NOME DA TABLESPACE PARA LISTAR OS DATAFILES (<ENTER>=Opção anterior) :  "
set linesize 150 verify off
col xtablespace head "Tablespace"       for a15
col xstatus     head "Status"           for a7
col xfileName   head "FileName(FileID)" for a65
col xmax        head "Max|(MB)"         for 99999999
col xsize       head "Size|(MB)"        for 99999999
col xused       head "Used|(MB)"        for 99999999
col xfree       head "Free|(MB)"        for 9999999
col xfreeOfMax  head "Free|Of|Max|(MB)" for 99999999
col xusedOfMax  head "Used|Of|Max|(%)"  for 999
col xaut        head "Aut"              for a3
BREAK on xtablespace skip 1 on report skip 1
--COLUMN DUMMY NOPRINT;
COMPUTE SUM label "TOTAL GERAL"    OF xmax ON report
COMPUTE SUM OF    "Size(MB)"       ON report
COMPUTE SUM OF    "Used(MB)"       ON report
COMPUTE SUM OF    "FreeOfMax(MB)"  ON report

SPOOL /tmp/tbs_${ORACLE_SID}_&DATA APPEND
prompt
SELECT /*+ ordered */ d.tablespace_name                                                       xtablespace
     , d.file_name||'('||d.file_id||')'                                                       xfileName
     , v.status                                                                               xstatus
     , d.maxbytes/1024/1024                                                                   xmax
     , d.bytes/1024/1024                                                                      xsize
     , trunc(NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2)                          xused
     , trunc((d.maxbytes/1024/1024) - NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2) xfreeOfMax
     , round(((trunc(NVL((d.bytes - s.bytes),d.bytes),2))*100)/d.maxbytes)                    xusedOfMax
     , d.autoextensible                                                                       xaut
 FROM sys.dba_data_files d
     , v$datafile v
     , (SELECT file_id, SUM(bytes) bytes
         FROM sys.dba_free_space
         WHERE tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))  GROUP BY file_id) s
WHERE (s.file_id (+)= d.file_id)
      AND d.tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))
      AND (d.file_name = v.name)
      AND d.autoextensible='YES'
UNION
SELECT /*+ ordered */ d.tablespace_name                                                    xtablespace
     , d.file_name||'('||d.file_id||')'                                                    xfileName
     , v.status                                                                            xstatus
     , d.maxbytes/1024/1024                                                                xmax
     , d.bytes/1024/1024                                                                   xsize
     , trunc(NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2)                       xused
     , trunc((d.bytes/1024/1024) - NVL((d.bytes - s.bytes)/1024/1024,d.bytes/1024/1024),2) xfreeOfMax
     , round((NVL((d.bytes - s.bytes),d.bytes)*100)/d.bytes)                               xusedOfMax
     , autoextensible                                                                      xaut
 FROM sys.dba_data_files d
     , v$datafile v
     , (SELECT file_id, SUM(bytes) bytes
         FROM sys.dba_free_space
         WHERE tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))  GROUP BY file_id) s
WHERE (s.file_id (+)= d.file_id)
      AND d.tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))
      AND d.file_name = v.name
      AND d.autoextensible='NO'
UNION
SELECT /*+ ordered */ d.tablespace_name                                               xtablespace
     , d.file_name||'('||d.file_id||')'                                               xfileName
     , d.status                                                                       xstatus
     , d.maxbytes/1024/1024                                                           xmax
     , d.bytes/1024/1024                                                              xsize
     , NULL                                                                           xused
     , NULL                                                                           xfreeOfMax
     , NULL                                                                           xusedOfMax
     , autoextensible                                                                 xaut
 FROM sys.dba_temp_files d
    WHERE d.tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))
      AND autoextensible='YES'
UNION
SELECT /*+ ordered */ d.tablespace_name                                               xtablespace
     , d.file_name||'('||d.file_id||')'                                               xfileName
     , d.status                                                                       xstatus
     , d.maxbytes/1024/1024                                                           xmax
     , d.bytes/1024/1024                                                              xsize
     , NULL                                                                           xused
     , NULL                                                                           xfreeOfMax
     , NULL                                                                           xUsedOfMax
     , autoextensible                                                                 xaut
 FROM sys.dba_temp_files d
    WHERE d.tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))
      AND autoextensible='NO'
ORDER BY 1, 2
/

prompt
prompt
prompt DATAFILE COM MAXSIZE QUE PRECISAM SER AJUSTADOS (maxbytes<bytes)
set head off feed on verify off
select 'alter database datafile '''||file_name||''' autoextend on maxsize '||bytes||';'
 from dba_data_files
where maxbytes<bytes and autoextensible='YES'
  and tablespace_name like upper(nvl('&df_tablespace',nvl('&ts_tablespace','%')))
/
prompt
set head on
SPOOL OFF

PROMPT spool at /tmp/tbs_${ORACLE_SID}_&DATA..lst
PROMPT
