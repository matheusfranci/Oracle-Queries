-- VERIFICANDO UM JOB
select job_name, owner, enabled, state from dba_scheduler_jobs;
select last_run_duration, next_run_date, run_count, failure_count, schedule_name, owner, job_name, state from dba_scheduler_jobs;
select * from dba_jobs;
select * from dba_jobs where job between '504' AND '509';
select JOB, SCHEMA_USER, LAST_DATE, LAST_SEC, BROKEN, FAILURES, NEXT_SEC from dba_jobs where job between '504' AND '509';

** TODAS AS INFORMAÇÕES DE UM JOB ESPECÍFICO **
select * from DBA_SCHEDULER_JOB_RUN_DETAILS where JOB_NAME = 'nome do job';

** HABILITANDO UM JOB **
execute dbms_scheduler.enable('owner.job');
exec dbms_job.broken(1,FALSE);

** DESABILITANDO UM JOB **
execute dbms_scheduler.disable('owner.job');
exec dbms_job.broken(1,TRUE);
