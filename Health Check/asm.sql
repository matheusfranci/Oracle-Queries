-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : asm.sql                                                                                  #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024		                                                                         #
-- PROPOSITO  : Tamanho dos disks groups do ASM                                                          #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 1000
SET FEEDBACK OFF
set heading on
set termout OFF
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;

ttitle center 'SITUACAO DOS DISKGROUPS' skip 2
SELECT 
    name as "Disk Group", 
    free_mb as "Livre", 
    total_mb as "Total", 
    ROUND(free_mb/total_mb*100, 2) as "Livre%"
FROM v$asm_diskgroup;
