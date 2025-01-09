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

-- Validando um dgg especifico
SELECT
G.NAME AS "Disk Group",
D.NAME AS "Discos",
ROUND(D.TOTAL_MB / 1024, 2) AS SIZE_GB
FROM V$ASM_DISK D
INNER JOIN V$ASM_DISKGROUP G
ON
D.GROUP_NUMBER= G.GROUP_NUMBER
WHERE G.NAME = 'SAUDEP_DATA1'
order by D.NAME

-- Adicionando:
-- ADD ASM SAMPLE
ALTER DISKGROUP SAUDEP_DATA1 ADD DISK
'ORCL:SAUDEP_DATA1_D13' NAME SAUDEP_DATA1_D13,
'ORCL:SAUDEP_DATA1_D14' NAME SAUDEP_DATA1_D14 REBALANCE Power 4;

-- Validando o rebalance:
select OPERATION,STATE,POWER,ACTUAL,SOFAR,
EST_WORK,EST_RATE,EST_MINUTES from v$asm_operation ;

-- SCP dentro do asm
-- Precisa ser feito dentro do usuário GRID
ASMCMD> cp /u01/app/oracle/rm/datapump/EXPDP_RM.dmp +DATA/dump/EXPDP_RM.dmp
