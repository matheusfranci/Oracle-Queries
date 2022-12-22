-- Verificando parâmetros dos profiles
select resource_type, resource_name, limit from dba_profiles;

-- Verificando todos os usuários
select username,user_id from dba_users;

-- Verificando os parâmetros de profile em determinado usuário 
select resource_type, resource_name, limit from dba_profiles where profile='SYSDG';

-- Verificando os grants
col username format a10
set line size 300
col sys_priv format a16
col object_owner format a13
col object_name format a23
col run_name format a27
SELECT SYS_PRIV, OBJECT_OWNER, OBJECT_NAME,
RUN_NAME FROM DBA_USED_PRIVS WHERE USERNAME ='C##MATHEUS';
