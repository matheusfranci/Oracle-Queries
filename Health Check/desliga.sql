-- #############################################################################
-- Unimix Tecnologia
--
-- SCRIPT     : verifica_banco.sql
-- AUTOR      : Marcos Rocha
-- DATA       : 30/04/2012
-- PROPOSITO  : emitir relatorio das instancias.
-- #############################################################################
-- REVISOES   
-- 
-- #############################################################################
-- setup do sqlplus
set pagesize 100 
set linesize 150
set colsep |
set termout off
SET MARKUP HTML ON

set termout on
-- inicio do relatorio
prompt DESLIGANDO TOADAS AS INSTANCIAS DO TRF5
set heading off
select ' --> '||instance_name||' <--' from v$instance
/

set heading on
prompt ------------------------------

prompt estado da instância

prompt ------------------------------

--SHUTDOWN IMMEDIATE;