SELECT name, type, total_mb, free_mb/1024 free_gb, required_mirror_free_mb, STATE,
usable_file_mb FROM V$ASM_DISKGROUP;

-- SCP dentro do asm
-- Precisa ser feito dentro do usuário GRID
ASMCMD> cp /u01/app/oracle/rm/datapump/EXPDP_RM.dmp +DATA/dump/EXPDP_RM.dmp
