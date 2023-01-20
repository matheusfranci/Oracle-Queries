-- Verificando parâmetros dos profiles
select resource_type, resource_name, limit from dba_profiles;

-- Verificando todos os usuários
select username,user_id from dba_users;

-- Verificando os parâmetros de profile em determinado usuário 
select resource_type, resource_name, limit from dba_profiles where profile='SYSDG';

-- Verificando os grants
SELECT PRIVILEGE
FROM sys.dba_sys_privs
WHERE grantee = 'C##MATHEUS';

-- Verificando grants em tabelas especificas
SELECT owner, table_name, select_priv, insert_priv, delete_priv, update_priv, references_priv, alter_priv, index_priv 
FROM table_privileges
 WHERE grantee='C##MATHEUS';

-- Extraindo ddl de usuário
SELECT dbms_metadata.get_ddl('USER','CONSINCO') FROM dual;
