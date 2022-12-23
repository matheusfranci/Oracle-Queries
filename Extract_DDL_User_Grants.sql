select dbms_metadata.get_ddl('USER', 'CONSINCO') AS ddl
from dba_users u
where u.username = 'CONSINCO'
union all
select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', tq.username) AS ddl
from dba_ts_quotas tq
where tq.username = 'CONSINCO' and rownum = 1
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from dba_role_privs rp
where rp.grantee = 'CONSINCO'
and rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from dba_sys_privs sp
where sp.grantee = 'CONSINCO'
and rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from dba_tab_privs tp
where tp.grantee = 'CONSINCO'
and rownum = 1
union all
select dbms_metadata.get_granted_ddl('DEFAULT_ROLE', rp.grantee) AS ddl
from dba_role_privs rp
where rp.grantee = 'CONSINCO'
and rp.default_role = 'YES'
and rownum = 1
union all
select to_clob('/* Start profile creation script in case they are missing') AS ddl
from dba_users u
where u.username = 'CONSINCO'
and u.profile='DEFAULT'
and rownum = 1
union all
select dbms_metadata.get_ddl('PROFILE', u.profile) AS ddl
from dba_users u
where u.username = 'CONSINCO'
and u.profile='DEFAULT'
union all
select to_clob('End profile creation script */') AS ddl
from dba_users u
where u.username = 'CONSINCO'
and u.profile='DEFAULT'
and rownum = 1
/
