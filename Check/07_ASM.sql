SELECT 
    name as "Disk Group", 
    free_mb as "Livre", 
    total_mb as "Total", 
    ROUND(free_mb/total_mb*100, 2) as "Livre%"
FROM v$asm_diskgroup;

-- Melhorada
SELECT 
(SELECT name FROM V$DATABASE) AS "Dbname",
name as "Diskgroup",
ROUND(total_mb / 1024) as "Total_ASM(GB)",
ROUND(free_mb / 1024) as "Free_ASM(GB)",
ROUND(free_mb/total_mb*100, 2) as "Perc_Livre",
ROUND(100 - (free_mb/total_mb*100), 2) as "Perc_Ocup"
FROM v$asm_diskgroup

-- SCP dentro do asm
-- Precisa ser feito dentro do usuário GRID
ASMCMD> cp /u01/app/oracle/rm/datapump/EXPDP_RM.dmp +DATA/dump/EXPDP_RM.dmp
