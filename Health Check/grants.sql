-- #######################################################################################################
-- CNSEG	                                                                                             #
--                                                                                                       #
-- SCRIPT     : reporta-backup-rman.sql                                                                  #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 09/01/2024		                                                                         #
-- PROPOSITO  : exibe a execução dos backups via rman                                                    #
--                                                                                                       #
-- #######################################################################################################
-- REVISOES                                                                                              #
--                                                                                                       #
--########################################################################################################
--
--
SET SERVEROUTPUT ON
SET LINESIZE 32000;
SET PAGESIZE 40000;
SET LONG 50000;
SET FEEDBACK OFF
set heading on
set termout on
set colsep |
SET lines 200
set long 999999999
set markup html on spool on entmap off

ttitle center 'INSTANCIA' skip 2
select instance_name from v$instance;


ttitle center 'USUARIOS COM GRANT DE DBA' skip 2
SELECT GRANTEE,
       PRIVILEGE,
       ACCOUNT_STATUS
FROM   (SELECT GRANTEE,
               LTRIM(MAX(SYS_CONNECT_BY_PATH(PRIVILEGE, ', ')), ', ') PRIVILEGE
        FROM   (SELECT GRANTEE,
                       PRIVILEGE,
                       ROW_NUMBER() OVER(PARTITION BY GRANTEE ORDER BY PRIVILEGE) RN
                FROM   (SELECT DISTINCT NVL(A.GRANTEE, B.GRANTEE) GRANTEE,
                                        NVL(A.PRIVILEGE, B.PRIVILEGE) PRIVILEGE
                        FROM   (SELECT A.GRANTEE,
                                       A.GRANTED_ROLE PRIVILEGE
                                FROM   (SELECT A.*
                                        FROM   DBA_ROLE_PRIVS A
                                        CONNECT BY PRIOR GRANTEE = GRANTED_ROLE) A,
                                       DBA_SYS_PRIVS B
                                WHERE  A.GRANTEE NOT IN (SELECT ROLE
                                                         FROM   DBA_ROLES)
                                AND    A.GRANTED_ROLE = B.GRANTEE
                                AND    (B.PRIVILEGE LIKE 'DROP ANY%' OR B.PRIVILEGE LIKE 'GRANT%' OR B.PRIVILEGE IN ('ADMINISTER DATABASE TRIGGER'))) A
                        FULL   OUTER JOIN (SELECT GRANTEE,
                                                 PRIVILEGE
                                          FROM   DBA_SYS_PRIVS
                                          WHERE  (PRIVILEGE LIKE 'DROP ANY%' OR PRIVILEGE LIKE 'GRANT%' OR PRIVILEGE IN ('ADMINISTER DATABASE TRIGGER'))
                                          AND    GRANTEE NOT IN (SELECT ROLE
                                                                 FROM   DBA_ROLES)) B ON B.GRANTEE = A.GRANTEE)
                                                                 )
        START  WITH RN = 1
        CONNECT BY PRIOR RN = RN - 1
            AND    PRIOR GRANTEE = GRANTEE
        GROUP  BY GRANTEE) A,
       DBA_USERS B
WHERE  A.GRANTEE = B.USERNAME
ORDER  BY 1;


ttitle center 'DDL USUARIOS' skip 2
SELECT DBMS_METADATA.GET_DDL('USER', USERNAME) || '/' DDL
FROM DBA_USERS;


ttitle center 'SENHA USUARIOS' skip 2
select 'alter user "'||username||'" identified by values '''||extract(xmltype(dbms_metadata.get_xml('USER',username)),
'//USER_T/PASSWORD/text()').getStringVal()||''';' old_password from dba_users ;