-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : interconnct.sql                                                                              #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024		                                                                         #
-- PROPOSITO  : Tempo entre os nodes via interconnect                                                    #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
--
--
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 1000
SET FEEDBACK OFF
set heading on
set termout on
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;

prompt -- doc id-181489.1 "The average cr block receive time or current block receive time should typically be less than 15 milliseconds depending on your system configuration and volume, is the average latency of a consistent-read request round-trip from the requesting instance to the holding instance and back to the requesting instance.#

ttitle center 'TEMPO DO INTERCONNECT' skip 2
SELECT b1.inst_id, b2.VALUE "GCS CR BLOCKS RECEIVED",
     b1.VALUE "GCS CR BLOCK RECEIVE TIME",
     ((b1.VALUE / b2.VALUE) * 10) "AVG CR BLOCK RECEIVE TIME (ms)"
     FROM gv$sysstat b1, gv$sysstat b2
     WHERE b1.name = 'global cache cr block receive time'
     AND b2.name = 'global cache cr blocks received'
     AND b1.inst_id = b2.inst_id OR b1.name = 'gc cr block receive time'
     AND b2.name = 'gc cr blocks received'
     AND b1.inst_id = b2.inst_id;