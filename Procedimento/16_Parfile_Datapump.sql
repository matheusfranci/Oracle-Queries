JOB_NAME=EXPORT
DIRECTORY=ORACLE_BASE
DUMPFILE=EXPORT_ECOAPP.dmp
FULL=Y

expdp system/2022@ecoapp parfile=C:\oracle_19c\parameterfile.par logfile=export.log

-- Atachar no job e verificar os status
expdp system/2022@ecoapp attach=EXPORT
procedimento usuário/senha@instância attach=nomedojob
Após atachar para verificar o status basta escrever status na linha de comando

/*
Export> status

Job: EXPORT
  OperaþÒo: EXPORT
  Modo: FULL
  Estado: EXECUTING
  Bytes Processados: 0
  Paralelismo Atual: 1
  Contagem de Erros do Job: 0
  PulsaþÒo do job: 6
  Arquivo de Dump: C:\ORACLE_19C\EXPORT_ECOAPP.DMP
    bytes gravados: 4.096

Worker 1 Status:
  ID da InstÔncia: 1
  Instance name: orcl
  Nome do host: MATHEUSHO
  Horßrio de inÝcio do objeto: Quarta-Feira, 00 Sßb, 0000 0:00:00
  Status do objeto em: Segunda-Feira, 06 Fevereiro, 2023
  Nome do Processo: DW00
  Estado: EXECUTING
*/
-- Procedimento para aumentar a streams_pool que auxilia na velocidade da importação
select 'ALTER SYSTEM SET STREAMS_POOL_SIZE='||(max(to_number(trim(c.ksppstvl)))+67108864)||' SCOPE=SPFILE;' 
from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c 
where a.indx = b.indx 
and a.indx = c.indx 
and lower(a.ksppinm) 
in ('__streams_pool_size','streams_pool_size');

SQL> show parameter STREAMS_POOL_SIZE
To Change the STREAMS_POOL_SIZE:
SQL> ALTER SYSTEM SET STREAMS_POOL_SIZE=100M SCOPE=both;
System altered.

-- Necessário rebootar a instância
shut immediate;
startup;


