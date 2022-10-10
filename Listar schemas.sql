select distinct owner schema_name
from dba_segments
where owner in(select username from dba_users where default_tablespace not in ('SYSTEM','SYSAUX'))
order by owner;
