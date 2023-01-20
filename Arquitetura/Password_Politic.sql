-- Desabilitar senha complexa
alter profile default limit password_verify_function null;

-- Desabilitar tempo de reuso de senha
alter profile DEFAULT limit PASSWORD_REUSE_TIME UNLIMITED;

-- Desabilitar máximo de reusos da senha
ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX UNLIMITED;

-- Consultando parametros relacionados
select * from dba_profiles where profile='DEFAULT';
