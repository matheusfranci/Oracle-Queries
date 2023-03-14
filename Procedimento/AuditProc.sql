##### Laboratório #####

--> Verificação do banco

CONN / AS SYSDBA

set lines 200 pages 10000
col table_name format a20

SELECT table_name, tablespace_name
FROM   dba_tables
WHERE  table_name IN ('AUD$', 'FGA_LOG$')
ORDER BY table_name;

TABLE_NAME                     TABLESPACE_NAME
------------------------------ ------------------------------
AUD$                           SYSTEM
FGA_LOG$                       SYSTEM


SQL> show parameter audit

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest 		     string	 /u01/app/oracle/admin/orcl/adu
						 mp
audit_sys_operations		     boolean	 TRUE
audit_syslog_level		     string
audit_trail			     string	 DB
unified_audit_common_systemlog	     string
unified_audit_sga_queue_size	     integer	 1048576
unified_audit_systemlog 	     string


--> Troca das tabelas de tablespace

BEGIN
  

CREATE TABLESPACE AUDIT_AUX DATAFILE SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

   --
   --Modificando para a  auditoria simples, a AUD$
   DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
    audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD
    , audit_trail_location_value => 'AUDIT_AUX'
     );
 
   --
   --Modificando para a  auditoria de FGA, a FGA_LOG$
   DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
    audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD
    , audit_trail_location_value => 'AUDIT_AUX'
     );    

END;


-- Check locations.
SELECT table_name, tablespace_name
FROM   dba_tables
WHERE  table_name IN ('AUD$', 'FGA_LOG$')
ORDER BY table_name;

TABLE_NAME                     TABLESPACE_NAME
------------------------------ ------------------------------
AUD$                           AUDIT_AUX
FGA_LOG$                       AUDIT_AUX

--> Verificando o size e age das trilhas de auditoria

COLUMN parameter_name FORMAT A30
COLUMN parameter_value FORMAT A20
COLUMN audit_trail FORMAT A20

SELECT *
FROM   dba_audit_mgmt_config_params
WHERE  parameter_name LIKE 'AUDIT FILE MAX%';


-- Set the Maximum size of OS audit files to 15,000Kb.
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_property(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
    audit_trail_property       => DBMS_AUDIT_MGMT.OS_FILE_MAX_SIZE,
    audit_trail_property_value => 15000);
END;
/


-- Set the Maximum age of XML audit files to 10 days.
BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_property(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
    audit_trail_property       => DBMS_AUDIT_MGMT.OS_FILE_MAX_AGE,
    audit_trail_property_value => 10);
END;
/


-- Purge

COLUMN parameter_name FORMAT A30
COLUMN parameter_value FORMAT A20
COLUMN audit_trail FORMAT A20

SELECT * FROM dba_audit_mgmt_config_params;


BEGIN
  DBMS_AUDIT_MGMT.init_cleanup(
    audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
    default_cleanup_interval => 12 /* hours */);
END;
/

SELECT * FROM dba_audit_mgmt_config_params;


SET SERVEROUTPUT ON
BEGIN
  IF DBMS_AUDIT_MGMT.is_cleanup_initialized(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD) THEN
    DBMS_OUTPUT.put_line('YES');
  ELSE
    DBMS_OUTPUT.put_line('NO');
  END IF;
END;
/


-- Manual Purge

BEGIN
  DBMS_AUDIT_MGMT.clean_audit_trail(
   audit_trail_type        => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
   use_last_arch_timestamp => TRUE);
END;
/


-- Criando um job de limpeza

BEGIN
  DBMS_AUDIT_MGMT.create_purge_job(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
    audit_trail_purge_interval => 24 /* hours */,  
    audit_trail_purge_name     => 'PURGE_ALL_AUDIT_TRAILS',
    use_last_arch_timestamp    => TRUE);
END;
/

SELECT job_action
FROM   dba_scheduler_jobs
WHERE  job_name = 'PURGE_ALL_AUDIT_TRAILS';




-->Auditoria Padrão


CONN sys@pdb_1 AS SYSDBA

CREATE USER TEST IDENTIFIED BY TEST QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO TEST;

CREATE USER test2 IDENTIFIED BY test2 QUOTA UNLIMITED ON users;
GRANT CREATE SESSION TO test2;

CREATE USER test3 IDENTIFIED BY test3 QUOTA UNLIMITED ON users;
GRANT CREATE SESSION TO test3;


AUDIT ALL BY test BY ACCESS;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE, DELETE TABLE BY test BY ACCESS;
AUDIT EXECUTE PROCEDURE BY test BY ACCESS;

CREATE TABLE test_tab (
  id  NUMBER
);

INSERT INTO test_tab (id) VALUES (1);
UPDATE test_tab SET id = id;
SELECT * FROM test_tab;
DELETE FROM test_tab;

DROP TABLE test_tab;

SELECT view_name
FROM   dba_views
WHERE  view_name LIKE 'DBA%AUDIT%'
ORDER BY view_name;




COLUMN db_user       FORMAT A10
COLUMN object_schema FORMAT A10
COLUMN object_name   FORMAT A10
COLUMN extended_timestamp FORMAT A35

SELECT db_user,
       extended_timestamp,
       object_schema,
       object_name,
       action
FROM   v$xml_audit_trail
WHERE  object_schema = 'TEST'
ORDER BY extended_timestamp;


select 'standard audit', sessionid,
    proxy_sessionid, statementid, entryid, extended_timestamp, global_uid,
    username, client_id, null, os_username, userhost, os_process, terminal,
    instance_number, owner, obj_name, null, new_owner,
    new_name, action, action_name, audit_option, transactionid, returncode,
    scn, comment_text, sql_bind, sql_text,
    obj_privilege, sys_privilege, admin_option, grantee, priv_used,
    ses_actions, logoff_time, logoff_lread, logoff_pread, logoff_lwrite,
    logoff_dlock, session_cpu
  from 
  dba_audit_trail
  where owner = 'TEST';




--> FGA


CONN test/TEST@pdb_1

CREATE TABLE EMP (
 empno     NUMBER(4) NOT NULL,
 ename     VARCHAR2(10),
 job       VARCHAR2(9),
 mgr       NUMBER(4),
 hiredate  DATE,
 sal       NUMBER(7,2),
 comm      NUMBER(7,2),
 deptno    NUMBER(2)
);

INSERT INTO EMP (empno, ename, sal) VALUES (9999, 'Ricardo', 10000);
INSERT INTO EMP (empno, ename, sal) VALUES (9999, 'Guilherme', 50001);
COMMIT;


CONN sys/oracle@pdb_1 AS sysdba

BEGIN
  DBMS_FGA.add_policy(
    object_schema   => 'TEST',
    object_name     => 'EMP',
    policy_name     => 'AUDIT_SALARIO',
    audit_condition => 'SAL > 50000',
    audit_column    => 'SAL');
END;
/


conn test/TEST@pdb_1

SELECT sal FROM emp WHERE ename = 'Ricardo';
SELECT sal FROM emp WHERE ename = 'Guilherme';

CONN sys/password AS SYSDBA
SELECT sql_text
FROM   dba_fga_audit_trail;


CONN sys/password AS SYSDBA
BEGIN
  DBMS_FGA.drop_policy(
    object_schema   => 'TEST',
    object_name     => 'EMP',
    policy_name     => 'AUDIT_SALARIO');
END;
/



--> Unified Audit

CREATE AUDIT POLICY policy_name 
  ACTIONS COMPONENT=DATAPUMP [EXPORT | IMPORT | ALL];

CONN / AS SYSDBA
CREATE AUDIT POLICY audit_dpump ACTIONS COMPONENT=DATAPUMP ALL;
AUDIT POLICY audit_dpump BY sys;



conn sys@pdb_1 as sysdba
CREATE AUDIT POLICY audit_pdb_1_dpump ACTIONS COMPONENT=DATAPUMP ALL;
AUDIT POLICY audit_pdb_1_dpump BY sys;

expdp \'sys/oracle@pdb_1 as sysdba\' DUMPFILE=pdb_01.dmp LOGFILE=pdb_01_exp.log DIRECTORY=test_dir full=y


sqlplus / as sysdba

sqlplus sys/oracle@pdb_1 as sysdba


EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

SET LINESIZE 200
COLUMN event_timestamp FORMAT A30
COLUMN dp_text_parameters1 FORMAT A30
COLUMN dp_boolean_parameters1 FORMAT A30

SELECT event_timestamp,
       dp_text_parameters1,
       dp_boolean_parameters1
FROM   unified_audit_trail
WHERE  audit_type = 'Datapump';




expdp \'sys/oracle@orcl as sysdba\' DUMPFILE=tbs_01.dmp LOGFILE=tbs_01_exp.log DIRECTORY=test_dir full=y

expdp \'sys/oracle@pdb_1 as sysdba\' DUMPFILE=test_01.dmp LOGFILE=test_01_exp.log DIRECTORY=test_dir schemas=test



NOAUDIT POLICY audit_pdb_1_dpump;
DROP AUDIT POLICY audit_pdb_1_dpump;


NOAUDIT POLICY test_audit_policy;
DROP AUDIT POLICY test_audit_policy;



