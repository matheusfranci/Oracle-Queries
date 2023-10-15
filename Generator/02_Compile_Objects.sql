Select 'Alter '||decode(object_type,'PACKAGE BODY','PACKAGE','UNDEFINED','SNAPSHOT',OBJECT_TYPE)||' '||
       Owner || '.' || decode(substr(Object_name, 1, 4), '_ALL', '"' || object_name || '"', object_name) ||' '||
       decode(object_type,'PACKAGE BODY','COMPILE BODY','COMPILE')||';'
From   Dba_Objects
where  Status <> 'VALID';


@?\rdbms\admin\utlrp.sql;
OR
@?\rdbms\admin\utlirp.sql;
