-- ADR = Automatic Diagnostic Repository
select name, value from v$diag_info;

-- Alteração do adr // Ela é dinâmica desde que o diretório exista
ALTER SYSTEM SET diagnostic_dest='/u0dest/dest/dest/'

-- Automatic Diagnostic Repository Command Interpreter (ADRCI)

[oracle@prd prd]$ adrci
show homes
show alert
show alert -p "message_text like '%incident%'"
show alert -tail 20
show alert -p "message_text like '%ORA-%'"
show control

-- Alteração na rotina de limpeza dos logs, alerts e incidents
set control (SHORTP_POLICY = 72) Trace files, core dump files e packaging information
set control (LONGP_POLICY = 2190) -- incident information, incident dumps e alert logs

-- set ORACLE_HOME
SET HOME diag/rdbms/prd/prd

-- Limpeza
purge
purge -type trace --pode ser outro tipo

-- Verificação de problemas e incidentes
show problem
show incident
show incident -mode detail -p "incident_id=28794"
