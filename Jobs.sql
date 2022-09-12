** VERIFICANDO UM JOB **
select job_name, owner, enabled, state from dba_scheduler_jobs;

** TODAS AS INFORMAÇÕES DE UM JOB ESPECÍFICO **
select * from DBA_SCHEDULER_JOB_RUN_DETAILS where JOB_NAME = 'nome do job';

** HABILITANDO UM JOB **
execute dbms_scheduler.enable('owner.job');

** DESABILITANDO UM JOB **
execute dbms_scheduler.disable('owner.job');
