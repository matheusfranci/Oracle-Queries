-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : ALERTAS.sql                                                                              #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024	                                                                         #
-- PROPOSITO  : analise dos alertas                                                                      #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 1000
SET lines 200
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


ttitle center '!!!ERROS IMPORTANTES 7 DIAS!!!' skip 2
select originating_timestamp, module_id, MESSAGE_TEXT
from   v$diag_alert_ext 
WHERE originating_timestamp > SYSDATE -7
AND message_level = 1;

ttitle center '!!!ATENCAO 7 DIAS!!!' skip 2
select originating_timestamp, module_id, MESSAGE_TEXT
from   v$diag_alert_ext 
WHERE originating_timestamp > SYSDATE -7
AND message_level = 8;


--prompt #######  !!!ACOES NORMAIS DO BANCO ULTIMAS 24 HORAS!!!  ####### 

--select originating_timestamp, module_id, MESSAGE_TEXT
--from   v$diag_alert_ext 
--WHERE originating_timestamp > SYSDATE -1
--AND message_level = 16;


