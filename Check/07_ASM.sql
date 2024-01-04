SELECT 
    name, 
    free_mb, 
    total_mb, 
    ROUND(free_mb/total_mb*100, 2) as percentage
FROM v$asm_diskgroup;

-- SCP dentro do asm
-- Precisa ser feito dentro do usuário GRID
ASMCMD> cp /u01/app/oracle/rm/datapump/EXPDP_RM.dmp +DATA/dump/EXPDP_RM.dmp
