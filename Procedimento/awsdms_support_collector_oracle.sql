

column FIRST_CHANGE# format 999999999999999999
column NEXT_CHANGE# format 999999999999999999
column CURRENT_SCN format 999999999999999999


prompt _______________________________________________________________
prompt AWS DMS Support Collector for Oracle
prompt
prompt Version 1.0
prompt
prompt
prompt This script will collect information on your database to help troubleshoot an issue you are having with the DMS service.
prompt
prompt Before running the script, you should read and understand the sql which will be executed from both a performance and security perspective.
prompt
prompt If you are not comfortable executing or sharing the data from any of the sql, you may comment/remove that SQL.
prompt
prompt Once the script is complete, it will display the html output file name.
prompt
prompt Please review the information which you are sending to aws and if comfortable, upload it using the instructions found on the following link...
prompt https://docs.aws.amazon.com/dms/latest/userguide/CHAP_SupportScripts.html 
prompt
prompt
prompt
prompt
pause Press ENTER to continue to ctrl-C to abort
prompt
prompt
accept v_owner prompt 'Please enter the Schema name you wish to Migrate/Replicate : '
accept v_connector prompt 'Please enter the Oracle User Name which DMS will use to connect to your database : '
accept v_days prompt 'Please enter the number of days data you wish to examine [default 3] : ' DEFAULT 3
prompt Executing script...
prompt
prompt


set termout off
set linesize 420
set pagesize 100
set markup html on spool on entmap off
set verify off



-- Get date/time and db name for output file.
column dt new_val X
select to_char(sysdate,'yyyy-mm-dd-hh24-mi-ss') dt from dual;
column v_dbname new_val Y
select name v_dbname from v$database; 
spool dms_support_oracle-&&X-&&Y..html
--spool dms_support_script_oracle.html


set markup html off


--
-- This Section contains the table of contents.
--
--
-- prompt <h1 align="center">DMS Oracle Support Bundle</h1>
prompt <p id="Top"><h1 align="center">DMS Oracle Support Bundle</h1></p>
prompt <div >
prompt <p><strong>Contents</strong></p>
prompt <ol>
prompt <li><a href="#Overview">Overview</a>
prompt </li>
prompt <li><a href="#DatabaseConfiguration">Database Configuration</a>
prompt <ol>
prompt <li><a href="#DatabaseConfiguration1">Database Name</a></li>
prompt <li><a href="#DatabaseConfiguration2">Database Version</a></li>
prompt <li><a href="#DatabaseConfiguration3">Operating System version</a></li>
prompt <li><a href="#DatabaseConfiguration4">SGA Size</a></li>
prompt <li><a href="#DatabaseConfiguration5">Is this a RAC database</a></li>
prompt <li><a href="#DatabaseConfiguration6">Is Dataguard enabled</a></li>
prompt <li><a href="#DatabaseConfiguration7">Redo log sizes</a></li>
prompt <li><a href="#DatabaseConfiguration8">Supplemental logging and forced logging at database level</a></li>
prompt <li><a href="#DatabaseConfiguration9">Forced logging at tablespace level</a></li>
prompt <li><a href="#DatabaseConfiguration10">Is ASM in use</a></li>
prompt <li><a href="#DatabaseConfiguration11">NLS settings</a></li>
prompt <li><a href="#DatabaseConfiguration12">Is it a container databases</a></li>
prompt <li><a href="#DatabaseConfiguration13">Is it a pluggable database</a></li>
prompt </ol>
prompt </li>

prompt <li><a href="#SizeDetails">Size Details</a>
prompt <ol>
prompt <li><a href="#SizeDetails1">Database size</a></li>
prompt <li><a href="#SizeDetails2">Schema Sizes</a></li>
prompt <li><a href="#SizeDetails3">Total size of migration schema tables</a></li>
prompt <li><a href="#SizeDetails4">Total size of migration schema LOB Segments</a></li>
prompt <li><a href="#SizeDetails5">Top objects by size</a></li>
prompt </ol>
prompt </li>

prompt <li><a href="#DatabaseLoad">Database Load</a>
prompt <ol>
prompt <li><a href="#DatabaseLoad1">redo generated per day</a></li>
prompt <li><a href="#DatabaseLoad2">redo rate per hour</a></li>
prompt <li><a href="#DatabaseLoad4">CDC SQl performance</a></li>
prompt </ol>
prompt </li>

prompt <li><a href="#Table_Load">Table Load</a>
prompt <ol>
prompt <li><a href="#TableLoad2">Table modifications breakdown (insert/update/delete)</a></li>
-- prompt <li><a href="#TableLoad3">SizeDetails3</a></li>
prompt </ol>
prompt </li>

prompt <li><a href="#TableDetails">Table Details</a>
prompt <ol>
prompt <li><a href="#TableDetails1">Lob information</a></li>
prompt <li><a href="#TableDetails2">Table stastics (num of rows,avg row length etc.)</a></li>
prompt <li><a href="#TableDetails3">Partition count per table</a></li>
prompt <li><a href="#TableDetails4">SUB Partition count per partition</a></li>
prompt <li><a href="#TableDetails5">Existing MViews</a></li>
prompt <li><a href="#TableDetails6">Object Type count</a></li>
prompt <li><a href="#TableDetails7">Data Type count</a></li>
prompt <li><a href="#TableDetails8">Supplemental logging details</a></li>
prompt <li><a href="#TableDetails9">Table Compression</a></li>
prompt <li><a href="#TableDetails10">Table Encryption</a></li>
prompt <li><a href="#TableDetails11">Clustered tables</a></li>
prompt <li><a href="#TableDetails12">Nested tables</a></li>
prompt <li><a href="#TableDetails13">IOT with Overflow tables</a></li>
prompt </ol>
prompt </li>

prompt <li><a href="#ArchivalInformation">Archival Information</a>
prompt <ol>
prompt <li><a href="#ArchivalInformation1">Archive Destinations</a></li>
prompt <li><a href="#ArchivalInformation2">Archive log status</a></li>
prompt </ol>
prompt </li>



prompt <li><a href="#Permissions">Permissions</a>
prompt <ol>
prompt <li><a href="#Permissions1">System privlidges</a></li>
prompt <li><a href="#Permissions2">Table Grants</a></li>
prompt </ol>
prompt </li>


prompt <li><a href="#PotentialIssues">Potential Issues</a>
prompt <ol>
prompt <li><a href="#PotentialIssues1">Unsupported DataTypes</a></li>
prompt <li><a href="#PotentialIssues2">Tables with No PK</a></li>
prompt <li><a href="#PotentialIssues3">LOB columns with NOT NULL set</a></li>
prompt <li><a href="#PotentialIssues5">Oldest transaction with block changes</a></li>
prompt <li><a href="#PotentialIssues6">PK AND Unique key on the same table</a></li>
prompt <li><a href="#PotentialIssues6">DMS User Session Waits</a></li>
prompt </ol>
prompt </li>


prompt </div>




-- 
-- This Section contains the actual sql to extract the information.
-- 
-- Please review and feel free to comment out anything you are not comfortable sharing, or running against your database.
--



prompt <title>AWS DMS Support bundle script for Oracle</title>

-- New Major heading :
prompt <hr>
prompt <p id="Overview"><h2>Overview :</h2></p>


prompt <br>
prompt This is the output from the DMS Support script for Oracle.<br>
prompt <br>
prompt Please upload to AWS Support via a Customer Case.<br>
prompt <br>
prompt <br>
set heading off
select 'Current Database Time : <b>' || sysdate || '</b>' from dual;
prompt <br>
prompt <br>
prompt Schema name being Migrated/Replicated :<b> &v_owner</b>
prompt <br>
prompt <br>
prompt Oracle User Name which DMS will use to connect :<b> &v_connector</b>
prompt <br>
prompt <br>
prompt Number of days to analyse :<b> &v_days </b> 
prompt <br>
prompt <br>
set heading on


-- New Major heading :
prompt <hr>
prompt <p id="DatabaseConfiguration"><h2>Database Configuration</h2></p>



-- New Minor heading and block :
set markup html off
prompt <p id="DatabaseConfiguration1"><h2>Database Name :</h2></p>
prompt <li><a href="#Top">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration2">next</a></li>
set markup html on spool on entmap off
-- START SQL
select NAME,OPEN_MODE,DATABASE_ROLE,CURRENT_SCN,DB_UNIQUE_NAME from v$database;
-- END SQL
set markup html off
prompt <br>
prompt <br>




-- New Minor heading and block :
prompt <p id="DatabaseConfiguration2"><h2>Database Version :</h2></p>
prompt <li><a href="#DatabaseConfiguration1">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration3">next</a></li>
prompt <br>

prompt Please check the following documentation for supported database versions... <br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Oracle Source</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.Oracle.htmll">Oracle Target</a>
set markup html on spool on entmap off
-- START SQL
select * from v$version;
-- END SQL
set markup html off
prompt <br>
prompt <br>







-- New Minor heading and block :
prompt <p id="DatabaseConfiguration3"><h2>Operating System version</h2></p> 
prompt <li><a href="#DatabaseConfiguration2">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration4">next</a></li>
set markup html on spool on entmap off
-- START SQL
select dbms_utility.port_string from dual;
-- END SQL
set markup html off
prompt <br>
prompt <br>



column VALUE format 999,999,999,999,999,999
-- New Minor heading and block :
prompt <p id="DatabaseConfiguration4"><h2>SGA Size :</h2></p>
prompt <li><a href="#DatabaseConfiguration3">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration5">next</a></li>
set markup html on spool on entmap off
-- START SQL
select INST_ID,NAME,VALUE from gv$sga order by 1,2;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="DatabaseConfiguration5"><h2>Is this a RAC database :</h2></p>
prompt <li><a href="#DatabaseConfiguration4">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration6">next</a></li>
prompt <br>
prompt If more than one row is returned below then it is a RAC system.<br><br>
prompt If this is the case, then the following documentation may be of use...<br>
prompt <a href="https://aws.amazon.com/blogs/database/best-practices-for-migrating-an-oracle-database-to-amazon-rds-postgresql-or-amazon-aurora-postgresql-source-database-considerations-for-the-oracle-and-aws-dms-cdc-environment">Best practices for migrating an Oracle database</a><br>
prompt 
set markup html on spool on entmap off
-- START SQL
select INSTANCE_NUMBER,INSTANCE_NAME,STATUS,THREAD#,ARCHIVER,DATABASE_STATUS,INSTANCE_ROLE,
ACTIVE_STATE from gv$instance order by 1,2;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="DatabaseConfiguration6"><h2>Is Dataguard enabled :</h2></p>
prompt <li><a href="#DatabaseConfiguration5">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration7">next</a></li>
prompt If Active Dataguard, or a physical standby opened in read only mode is in use, it is possible to to use the standby as a source for DMS. <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
prompt <a href="https://aws.amazon.com/blogs/database/aws-dms-now-supports-binary-reader-for-amazon-rds-for-oracle-and-oracle-standby-as-a-source/">AWS DMS now supports Binary Reader for Amazon RDS for Oracle and Oracle Standby as a source</a><br>
prompt
set markup html on spool on entmap off
-- START SQL
select * from GV$DATAGUARD_CONFIG;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="DatabaseConfiguration7"><h2>Redo log sizes :</h2></p>
prompt <li><a href="#DatabaseConfiguration6">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration8">next</a></li>
set markup html on spool on entmap off
-- START SQL
select INST_ID,GROUP#,THREAD#,SEQUENCE#,BYTES,ARCHIVED,STATUS,FIRST_CHANGE#, NEXT_CHANGE# from gv$log order by 1,2,3;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="DatabaseConfiguration8"><h2>Supplemental logging and forced logging at database level :</h2></p>
prompt <li><a href="#DatabaseConfiguration7">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration9">next</a></li>
prompt To capture change data, AWS DMS requires supplemental logging to be enabled on your source database for AWS DMS. <br>
prompt Minimal supplemental logging must be enabled at the database level. <br>
prompt AWS DMS also requires that identification key logging be enabled. <br>
prompt This option causes the database to place all columns of a row's primary key in the redo log file whenever a row containing a primary key is updated (even if no value in the primary key has changed). <br>
prompt You can set this option at the database or table level. <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/sbs/CHAP_On-PremOracle2Aurora.Steps.ConfigureOracle.html">Configure Your Oracle Source Database </a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source</a><br>
prompt <a href="https://aws.amazon.com/blogs/database/best-practices-for-migrating-an-oracle-database-to-amazon-rds-postgresql-or-amazon-aurora-postgresql-source-database-considerations-for-the-oracle-and-aws-dms-cdc-environment/">Best practices for migrating an Oracle database</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/sbs/CHAP_On-PremOracle2Aurora.Steps.Troubleshooting.html">Troubleshooting</a><br>

set markup html on spool on entmap off
-- START SQL
select NAME,RESETLOGS_TIME,OPEN_MODE,DATABASE_ROLE,DATAGUARD_BROKER,GUARD_STATUS,
SUPPLEMENTAL_LOG_DATA_MIN,SUPPLEMENTAL_LOG_DATA_PK,SUPPLEMENTAL_LOG_DATA_UI,
FORCE_LOGGING,CURRENT_SCN,SUPPLEMENTAL_LOG_DATA_FK,SUPPLEMENTAL_LOG_DATA_ALL,SUPPLEMENTAL_LOG_DATA_PL 
from v$database;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="DatabaseConfiguration9"><h2>Forced logging at tablespace level :</h2></p>
prompt <li><a href="#DatabaseConfiguration8">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration10">next</a></li>
prompt In Force logging mode Oracle database must write the redo records even when NOLOGGING is used with DDL Statements.<br>
prompt It will force the write of REDO records even when no-logging is specified.<br><br>
set markup html on spool on entmap off
-- START SQL
select TABLESPACE_NAME,FORCE_LOGGING from dba_tablespaces order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="DatabaseConfiguration10"><h2>Is ASM in use :</h2></p>
prompt <li><a href="#DatabaseConfiguration9">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration11">next</a></li>
prompt If the database is using Oracle ASM to store its redo and archive log files, ongoing replication is enabled, <br>
prompt and DMS binary reader is enabled, certain non-default configuration settings need to be configured.<br>
prompt i.e. you need to correctly configure your Extra Connection Attributes to replicate.<br>
prompt e.g. useLogminerReader=N;copyToTempFolder=/backups/dms;archivedLogDestId=1;accessTempFolderDirectly=N;useBfile=Y;asm_user=bjanshego;asm_server=10.61.4.41/+ASM;deleteProccessedArchiveLogs=Y;archivedLogsOnly=Y<br> <br>
prompt
prompt In addition to this, ff you are using DMS versions 3.x or later, pay particular attention to settings such as parallelASMReadThreads and readAheadBlocks for performance.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://aws.amazon.com/blogs/database/how-to-migrate-from-oracle-asm-to-aws-using-aws-dms/">How to Migrate from Oracle ASM to AWS using AWS DMS</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
prompt <a href="https://aws.amazon.com/blogs/database/best-practices-for-migrating-an-oracle-database-to-amazon-rds-postgresql-or-amazon-aurora-postgresql-source-database-considerations-for-the-oracle-and-aws-dms-cdc-environment/">Best practices for migrating an Oracle database</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/sbs/CHAP_RDSOracle2PostgreSQL.Steps.CreateSourceTargetEndpoints.html">Step 6: Create AWS DMS Source and Target Endpoints</a><br>
set markup html on spool on entmap off
-- START SQL
select count(*) from GV$ASM_DISK_STAT;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="DatabaseConfiguration11"><h2>NLS settings :</h2></p>
prompt <li><a href="#DatabaseConfiguration10">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration12">next</a></li>
prompt If NLS settings differ between the source and target database, this can occasionally  cause issue.<br>
prompt e.g.<br>
prompt The error "ORA-12899: value too large for column column-name" is often caused by a mismatch in the character sets used by the source and target databases or when NLS settings differ between the two databases. <br>
prompt A common cause of this error is when the source database NLS_LENGTH_SEMANTICS parameter is set to CHAR and the target database NLS_LENGTH_SEMANTICS parameter is set to BYTE. <br>
prompt
set markup html on spool on entmap off
-- START SQL
select PARAMETER,VALUE from V$NLS_PARAMETERS order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="DatabaseConfiguration12"><h2>Is it a container databases :</h2></p>
prompt <li><a href="#DatabaseConfiguration11">previous : </a><a href="#Top">top : </a><a href="#DatabaseConfiguration13">next</a></li>
prompt AWS DMS doesn't support multi-tenant container databases (CDB). <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br><br>
prompt Note : This sql may fail on pre 12C databases.<br>
set markup html on spool on entmap off
-- START SQL
SELECT CDB FROM V$DATABASE;
-- END SQL
set markup html off
prompt <br>
prompt <br>



-- New Minor heading and block :
prompt <p id="DatabaseConfiguration13"><h2>Is it a pluggable database :</h2></p>
prompt <li><a href="#DatabaseConfiguration12">previous : </a><a href="#Top">top : </a><a href="#SizeDetails1">next</a></li>
prompt AWS DMS does not support connections to a pluggable database (PDB) using Oracle LogMiner. To connect to a PDB, access the redo logs using Binary Reader.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
prompt Note : This sql may fail on pre 12C databases.<br><br>
set markup html on spool on entmap off
-- START SQL
SELECT count(*) FROM DBA_PDBS ORDER BY PDB_ID;
-- END SQL
set markup html off
prompt <br>
prompt <br>



--------------------------------------------------------------------------
-- New Major heading :
prompt <hr>
prompt <p id="SizeDetails"><h2>Size Details</h2></p>


-- New Minor heading and block :
prompt <p id="SizeDetails1"><h2>Database size :</h2></p>
prompt <li><a href="#DatabaseConfiguration13">previous : </a><a href="#Top">top : </a><a href="#SizeDetails2">next</a></li>
prompt This section shows the total size of all datafiles in the database. (not all data will be getting replicated)<br><br>
prompt
prompt If there is a large amount of data to be moved, several options can help to improve the speed.<br><br>
prompt Firstly, the number of tables being migrated at the same time can be increased from the default of 8 up to 49, using the  MaxFullLoadSubTasks  setting.<br><br>
prompt
prompt Other options include using DMS parallel features against large tables, by either utalising native oracle partitioning if possible, or the DMS range-segmentation option.<br><br>
prompt
prompt Another tool that can be used, is to set the table load order, to force the largest table to be processed in the first batch of tables.<br><br>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://aws.amazon.com/blogs/database/introducing-aws-dms-replication-engine-version-3-1-2/">AWS Database Migration Service improves migration speeds by adding support for parallel full load</a><br>
prompt <a href="https://aws.amazon.com/about-aws/whats-new/2018/12/aws-database-migration-service-adds-support-for-parallel-full-load/">AWS Database Migration Service Improves Migration Speeds by Adding Support for Parallel Full Load and New LOB Migration Mechanisms</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html">Best practices for AWS Database Migration Service</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.FullLoad.html">Full-load task settings</a><br>
set markup html on spool on entmap off
-- START SQL
SELECT SUM (bytes) / 1024 / 1024 / 1024 AS GB FROM dba_data_files;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="SizeDetails2"><h2>Schema Sizes :</h2></p>
prompt <li><a href="#SizeDetails1">previous : </a><a href="#Top">top : </a><a href="#SizeDetails3">next</a></li>
prompt This section shows the total size of all SCHEMAS in the database. (not all data will be getting replicated)<br><br>
prompt
prompt If there is a large amount of data to be moved, several options can help to improve the speed.<br><br>
prompt Firstly, the number of tables being migrated at the same time can be increased from the default of 8 up to 49, using the  MaxFullLoadSubTasks  setting.<br><br>
prompt
prompt Other options include using DMS parallel features against large tables, by either utalising native oracle partitioning if possible, or the DMS range-segmentation option.<br><br>
prompt
prompt Another tool that can be used, is to set the table load order, to force the largest table to be processed in the first batch of tables.<br><br>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://aws.amazon.com/blogs/database/introducing-aws-dms-replication-engine-version-3-1-2/">AWS Database Migration Service improves migration speeds by adding support for parallel full load</a><br>
prompt <a href="https://aws.amazon.com/about-aws/whats-new/2018/12/aws-database-migration-service-adds-support-for-parallel-full-load/">AWS Database Migration Service Improves Migration Speeds by Adding Support for Parallel Full Load and New LOB Migration Mechanisms</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html">Best practices for AWS Database Migration Service</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.FullLoad.html">Full-load task settings</a><br>
set markup html on spool on entmap off
-- START SQL
select owner,round(sum(bytes)/1024/1024/1024) "SIZE IN GIGS" from dba_segments
where owner not in('ANONYMOUS','APEX_030200','OLAPSYS' ,'APEX_040200','APEX_PUBLIC_USER','APPQOSSYS','AUDSYS','BI','CTXSYS','DBSNMP','DIP','DVF','DVSYS','EXFSYS','FLOWS_FILES','GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER','HR','IX','LBACSYS','MDDATA','MDSYS','OE','ORACLE_OCM' ,'ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PM','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSBACKUP','SYSDG','SYSKM','SYSTEM','WMSYS','XDB','SYSMAN','RMAN','RMAN_BACKUP','MT') 
group by owner order by 2 desc;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="SizeDetails3"><h2>Total size of migration schema tables :</h2></p>
prompt <li><a href="#SizeDetails2">previous : </a><a href="#Top">top : </a><a href="#SizeDetails4">next</a></li>
prompt This section shows the total size of the SCHEMA being migrated. <br><br>
prompt
prompt If there is a large amount of data to be moved, several options can help to improve the speed.<br><br>
prompt Firstly, the number of tables being migrated at the same time can be increased from the default of 8 up to 49, using the  MaxFullLoadSubTasks  setting.<br><br>
prompt
prompt Other options include using DMS parallel features against large tables, by either utalising native oracle partitioning if possible, or the DMS range-segmentation option.<br><br>
prompt
prompt Another tool that can be used, is to set the table load order, to force the largest table to be processed in the first batch of tables.<br><br>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://aws.amazon.com/blogs/database/introducing-aws-dms-replication-engine-version-3-1-2/">AWS Database Migration Service improves migration speeds by adding support for parallel full load</a><br>
prompt <a href="https://aws.amazon.com/about-aws/whats-new/2018/12/aws-database-migration-service-adds-support-for-parallel-full-load/">AWS Database Migration Service Improves Migration Speeds by Adding Support for Parallel Full Load and New LOB Migration Mechanisms</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html">Best practices for AWS Database Migration Service</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.FullLoad.html">Full-load task settings</a><br>
set markup html on spool on entmap off
-- START SQL
select SEGMENT_TYPE, round(sum(BYTES)/1024/1024/1024,2) "Total Size Gigs" from dba_segments where owner=upper('&v_owner')
and SEGMENT_TYPE in('TABLE SUBPARTITION','TABLE PARTITION','NESTED TABLE','LOB PARTITION','TABLE')
group by SEGMENT_TYPE order by 2;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="SizeDetails4"><h2>Total size of migration schema LOB Segments :</h2></p>
prompt <li><a href="#SizeDetails3">previous : </a><a href="#Top">top : </a><a href="#SizeDetails5">next</a></li>
prompt This section shows the total size of lob segments which are owned by the Schema being migrated.<br><br>
prompt
prompt Lobs can often be the source of performance issues with a migration.<br>
prompt Understanding the databases lob sizes and the various options within DMS is key to their migration performance.<br><br>
prompt
prompt To help get optimal settings, read the documentation below and also consider the following...<br>
prompt Decide between the 3 modes available to move lobs (Inline LOB,Full LOB,Limited LOB)<br>
prompt Consider using Per table LOB settings.<br>
prompt Consider using Tables load order during full load, to make sure large lob tables are loaded first.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.LOBSupport.html">Setting LOB support for source databases in an AWS DMS task </a><br>
prompt <a href="https://aws.amazon.com/premiumsupport/knowledge-center/dms-improve-speed-lob-data/">How can I improve the speed of an AWS DMS task that has LOB data?</a><br>
prompt <a href="https://aws.amazon.com/blogs/database/introducing-aws-dms-replication-engine-version-3-1-2/">AWS Database Migration Service improves migration speeds by adding support for parallel full load and new LOB migration mechanisms</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html">Best practices for AWS Database Migration Service</a><br>

set markup html on spool on entmap off
-- START SQL
select SEGMENT_TYPE, round(sum(BYTES)/1024/1024/1024,2) "Total Size Gigs" from dba_segments where owner=upper('&v_owner')
and SEGMENT_TYPE in('LOBSEGMENT')
group by SEGMENT_TYPE order by 2;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="SizeDetails5"><h2>Top objects by size :</h2></p>
prompt <li><a href="#SizeDetails4">previous : </a><a href="#Top">top : </a><a href="#DatabaseLoad1">next</a></li>
prompt This section lists the tables owned by the Schema being migrated, including and ordered by size.<br>
prompt The column named L, indicates if the table contains a lob column.<br><br>
prompt
prompt Note : The size column includes the size of associated lob segments.<br>
set markup html on spool on entmap off
-- START SQL
select TABLE_NAME,contain_lob "Lob Segment", sum("Total Size Gigs") "Total Size Gigs" from(
        select (case when TABLE_NAME is null then TAB_NAME else TABLE_NAME end) TABLE_NAME,contain_lob, "Total Size Gigs"
        from(
                select size_list.tab_name, lob_list.table_name ,lob_list.contain_lob,sum(size_list."Total Size Gigs")/1024/1024/1024 "Total Size Gigs"
                from
                (select SEGMENT_NAME, table_name , 'Y' as contain_lob from dba_lobs where OWNER=upper('&v_owner') ) lob_list
                right outer join
                (select  segment_name, segment_name as tab_name, 'N' as contain_lob , sum(bytes) "Total Size Gigs" from dba_segments where owner=upper('&v_owner')  and SEGMENT_TYPE in('TABLE SUBPARTITION','TABLE PARTITION','NESTED TABLE','LOB PARTITION','LOBSEGMENT','TABLE') group by segment_name, segment_name) size_list
                on lob_list.segment_name = size_list.segment_name
                group by size_list.tab_name, lob_list.table_name ,lob_list.contain_lob
        )
) group by TABLE_NAME,contain_lob order by 3 desc;
-- END SQL
set markup html off
prompt <br>
prompt <br>







------------------------------------------------------------------------------------------
-- New Major heading :
prompt <hr>
prompt <p id="DatabaseLoad"><h2>Database Load</h2></p>


-- New Minor heading and block :
prompt <p id="DatabaseLoad1"><h2>Redo generated per day :</h2></p>
prompt <li><a href="#SizeDetails5">previous : </a><a href="#Top">top : </a><a href="#DatabaseLoad2">next</a></li>
prompt The database redo generation rate is important when performing ongoing replication.<br>
prompt If CDC source latency is being encountered, it may be caused by the redo rate.<br><br>
prompt
prompt If this is the case, there are several things which can be investigated to help DMS scale as required.<br>
prompt e.g.<br>
prompt Spread your tables across multiple DMS tasks.<br>
prompt Decide between LogMiner and BInary reader.<br>
prompt If the database in general has a high redo rate, but DMS is only replicating a low % of the data, then logminer may be better.<br><br>
set markup html on spool on entmap off
-- START SQL
select trunc(completion_time) rundate ,count(*) logswitch ,round((sum(blocks*block_size)/1024/1024)) "REDO PER DAY (MB)"
from v$archived_log  
where completion_time > sysdate- &v_days
group by trunc(completion_time) order by 1;  
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="DatabaseLoad2"><h2>Redo rate per hour :</h2></p>
prompt <li><a href="#DatabaseLoad1">previous : </a><a href="#Top">top : </a><a href="#DatabaseLoad4">next</a></li>
prompt The database redo generation rate is important when performing ongoing replication.<br>
prompt If CDC source latency is being encountered, it may be caused by the redo rate.<br><br>
prompt
prompt If this is the case, there are several things which can be investigated to help DMS scale as required.<br>
prompt e.g.<br>
prompt Spread your tables across multiple DMS tasks.<br>
prompt Decide between LogMiner and BInary reader.<br>
prompt If the database in general has a high redo rate, but DMS is only replicating a low % of the data, then logminer may be better.<br><br>
set markup html on spool on entmap off
-- START SQL
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24'; 
select to_date(completion_time,'DD-MM-YYYY HH24') rundate ,count(*) logswitch ,round((sum(blocks*block_size)/1024/1024)) "REDO PER HOUR (MB)"
from v$archived_log  
where completion_time > sysdate- &v_days
group by to_date(completion_time,'DD-MM-YYYY HH24') order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>





-- New Minor heading and block :
prompt <p id="DatabaseLoad4"><h2>CDC SQl performance :</h2></p>
prompt <li><a href="#DatabaseLoad2">previous : </a><a href="#Top">top : </a><a href="#TableLoad2">next</a></li>
prompt This section contains statistics on how sql issued by DMS is performing inside the database.<br><br>
prompt 
prompt The first 50 characters of the sql text are retrieved. This is enough to identify which sql command is being executed. But will not contain any customer information. <br><br>
set markup html on spool on entmap off
-- START SQL
select * from(
        select inst_id,sql_id,sum(ROWS_PROCESSED),sum(EXECUTIONS), (sum(ROWS_PROCESSED)/sum(EXECUTIONS)) "Rows/Execution",
        avg(round((ROWS_PROCESSED) / (FETCHES ) )) "Rows per fetch",
        avg(round((FETCHES) / (EXECUTIONS ) )) "Fetches per execution",
        avg(BUFFER_GETS/executions) "BuffGets/exec",
        avg(ELAPSED_TIME/executions) "Elaps/Exec",
        substr(trim(sql_text),1,50) sqlText
        from gv$sql where PARSING_SCHEMA_NAME=upper('&v_connector')
        and module like('repctl%')
        and sql_id is not null
        and executions > 0
        and fetches > 0
        group by inst_id,sql_id,substr(trim(sql_text),1,50)
        order by 4 desc
        )
where rownum < 51;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-------------------------------------------------------------------------------------------------


-- New Major heading :
prompt <hr>
prompt <p id="Table_Load"><h2>Table Load</h2></p>


-- New Minor heading and block :
prompt <p id="TableLoad2"><h2>Table modifications breakdown (insert/update/delete) :</h2></p>
prompt <li><a href="#TableLoad1">previous : </a><a href="#Top">top : </a><a href="#TableDetails">next</a></li>
prompt This section reads from the dba_tab_modifications view. This contains a cumulative number of all of the DML (inserts updates and deletes) for a specific table.<br> 
prompt The values are reset after the table is analysed and the views data is not updated immediately.<br><br>

prompt The output is included here as a lightweight way to see the type of operations being performed on the tables and to help get an idea of which tables receive the most amount of DML.<br>

set markup html on spool on entmap off
-- START SQL
select TABLE_OWNER,TABLE_NAME,PARTITION_NAME,INSERTS,UPDATES,DELETES,(INSERTS + UPDATES + DELETES) "TOTAL CHANGES"
from dba_tab_modifications 
where TABLE_OWNER not in ('ANONYMOUS','APEX_030200','OLAPSYS' ,'APEX_040200','APEX_PUBLIC_USER','APPQOSSYS','AUDSYS','BI','CTXSYS','DBSNMP','DIP','DVF','DVSYS','EXFSYS','FLOWS_FILES','GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER','HR','IX','LBACSYS','MDDATA','MDSYS','OE','ORACLE_OCM' ,'ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','PM','SCOTT','SH','SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYS','SYSBACKUP','SYSDG','SYSKM','SYSTEM','WMSYS','XDB','SYSMAN','RMAN','RMAN_BACKUP','MT') 
order by 7 desc;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-------------------------------------------------------------------------------------------------





-- New Major heading :
prompt <hr>
prompt <p id="TableDetails"><h2>Table Details</h2></p>

-- New Minor heading and block :
prompt <p id="TableDetails1"><h2>Lob information :</h2></p>
prompt <li><a href="#TableLoad2">previous : </a><a href="#Top">top : </a><a href="#TableDetails2">next</a></li>
prompt This section shows details for the lob segments which are owned by the Schema being migrated. The data is taken from dba_lobs.<br><br>
prompt
prompt Lobs can often be the source of performance issues with a migration.<br>
prompt Understanding the databases lob sizes and the various options within DMS is key to their migration performance.<br><br>
prompt
prompt To help get optimal settings, read the documentation below and also consider the following...<br>
prompt Decide between the 3 modes available to move lobs (Inline LOB,Full LOB,Limited LOB)<br>
prompt Consider using Per table LOB settings.<br>
prompt Consider using Tables load order during full load, to make sure large lob tables are loaded first.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.LOBSupport.html">Setting LOB support for source databases in an AWS DMS task </a><br>
prompt <a href="https://aws.amazon.com/premiumsupport/knowledge-center/dms-improve-speed-lob-data/">How can I improve the speed of an AWS DMS task that has LOB data?</a><br>
prompt <a href="https://aws.amazon.com/blogs/database/introducing-aws-dms-replication-engine-version-3-1-2/">AWS Database Migration Service improves migration speeds by adding support for parallel full load and new LOB migration mechanisms</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html">Best practices for AWS Database Migration Service</a><br>

set markup html on spool on entmap off
-- START SQL
select OWNER,TABLE_NAME,COLUMN_NAME,SEGMENT_NAME,CHUNK,IN_ROW,SECUREFILE 
from dba_lobs where owner =upper('&v_owner') 
order by OWNER,TABLE_NAME;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="TableDetails2"><h2>Table stastics (num of rows,avg row length etc.) :</h2></p>
prompt <li><a href="#TableDetails1">previous : </a><a href="#Top">top : </a><a href="#TableDetails3">next</a></li>
prompt This section provides information from dba_tables and gives an idea of the number of rows in a table, among other data.<br>
prompt The data in this table is only as good as the table statistics collected by the databaase. If they are out of date, then the data will be less accurate.<br><br>
set markup html on spool on entmap off
-- START SQL
column owner format a15
column DEGREE format a8
select OWNER,TABLE_NAME,NUM_ROWS,BLOCKS,EMPTY_BLOCKS,AVG_SPACE,AVG_ROW_LEN,LAST_ANALYZED,PARTITIONED,LOGGING,trim(DEGREE) DEGREE,COMPRESSION 
from dba_tables where OWNER =upper('&v_owner') 
order by 1,2,3;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="TableDetails3"><h2>Partition count per table :</h2></p>
prompt <li><a href="#TableDetails2">previous : </a><a href="#Top">top : </a><a href="#TableDetails4">next</a></li>
prompt This section shows if any of the tables being migrated are using Oracle partitioning.<br>
prompt If so, then it is possible to use the DMS parallel features to move large tables faster and more efficiently.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://aws.amazon.com/blogs/database/introducing-aws-dms-replication-engine-version-3-1-2/">AWS Database Migration Service improves migration speeds by adding support for parallel full load</a><br>
prompt <a href="https://aws.amazon.com/about-aws/whats-new/2018/12/aws-database-migration-service-adds-support-for-parallel-full-load/">AWS Database Migration Service Improves Migration Speeds by Adding Support for Parallel Full Load and New LOB Migration Mechanisms</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_BestPractices.html">Best practices for AWS Database Migration Service</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.FullLoad.html">Full-load task settings</a><br>
set markup html on spool on entmap off
-- START SQL
select * from(
SELECT
   TABLE_OWNER,
   TABLE_NAME,
   count(*)
FROM
    DBA_TAB_PARTITIONS
where TABLE_OWNER =upper('&v_owner') 
group by TABLE_OWNER,TABLE_NAME
ORDER BY 3 desc)
where rownum < 101;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="TableDetails4"><h2>SUB Partition count per partition :</h2></p>
prompt <li><a href="#TableDetails3">previous : </a><a href="#Top">top : </a><a href="#TableDetails5">next</a></li>
prompt Sub Partitions can be used in the same way as partitions. Please see the section above for more details.<br>
set markup html on spool on entmap off
-- START SQL
select * from(
SELECT
   TABLE_OWNER,
   TABLE_NAME,
   count(*) "Partition Count",
   sum(SUBPARTITION_COUNT) "SUB Partition Count"
FROM
    DBA_TAB_PARTITIONS
where TABLE_OWNER =upper('&v_owner') 
group by TABLE_OWNER,TABLE_NAME
ORDER BY 3 desc)
where rownum < 101;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="TableDetails5"><h2>Existing MViews :</h2></p>
prompt <li><a href="#TableDetails4">previous : </a><a href="#Top">top : </a><a href="#TableDetails6">next</a></li>
prompt AWS DMS does not support the ROWID data type or materialized views based on a ROWID column.<br>
set markup html on spool on entmap off
-- START SQL
select OWNER,MVIEW_NAME from dba_mviews 
where OWNER =upper('&v_owner') 
order by 1,2;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="TableDetails6"><h2>Object Type count :</h2></p>
prompt <li><a href="#TableDetails5">previous : </a><a href="#Top">top : </a><a href="#TableDetails7">next</a></li>
prompt THis section identifies the number of columns are defined as which object types.<br>
prompt Note, not all object types can be migrated. And also DMS will not migrate sequences.<br><br> 
set markup html on spool on entmap off
-- START SQL
select OWNER,OBJECT_TYPE,count(*) from dba_objects 
where OWNER =upper('&v_owner') 
group by OWNER,OBJECT_TYPE order by 3 desc;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="TableDetails7"><h2>Data Type count :</h2></p>
prompt <li><a href="#TableDetails6">previous : </a><a href="#Top">top : </a><a href="#TableDetails8">next</a></li>
prompt This section shows a count for each datatype being migrated.<br>
prompt DMS will not migrate certain data types.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
select OWNER,DATA_TYPE,count(*) 
from dba_tab_columns where 
OWNER =upper('&v_owner') 
group by OWNER,DATA_TYPE order by 3 desc;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="TableDetails8"><h2>Supplemental logging details :</h2></p>
prompt <li><a href="#TableDetails7">previous : </a><a href="#Top">top : </a><a href="#TableDetails9">next</a></li>
prompt To capture change data, AWS DMS requires supplemental logging to be enabled on your source database for AWS DMS. <br>
prompt Minimal supplemental logging must be enabled at the database level. <br>
prompt AWS DMS also requires that identification key logging be enabled. <br>
prompt This option causes the database to place all columns of a row's primary key in the redo log file whenever a row containing a primary key is updated (even if no value in the primary key has changed). <br>
prompt You can set this option at the database or table level. <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/sbs/CHAP_On-PremOracle2Aurora.Steps.ConfigureOracle.html">Configure Your Oracle Source Database </a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source</a><br>
prompt <a href="https://aws.amazon.com/blogs/database/best-practices-for-migrating-an-oracle-database-to-amazon-rds-postgresql-or-amazon-aurora-postgresql-source-database-considerations-for-the-oracle-and-aws-dms-cdc-environment/">Best practices for migrating an Oracle database</a><br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/sbs/CHAP_On-PremOracle2Aurora.Steps.Troubleshooting.html">Troubleshooting</a><br>

set markup html on spool on entmap off
-- START SQL
select LOG_GROUP_NAME,TABLE_NAME,LOG_GROUP_TYPE,ALWAYS from DBA_LOG_GROUPS where owner=upper('&v_owner') order by 2;
select LOG_GROUP_NAME,TABLE_NAME,COLUMN_NAME,POSITION,LOGGING_PROPERTY from DBA_LOG_GROUP_COLUMNS where OWNER=upper('&v_owner') order by 2,3;
-- END SQL
set markup html off
prompt <br>
prompt <br>



-- New Minor heading and block :
prompt <p id="TableDetails9"><h2>Table Compression :</h2></p>
prompt <li><a href="#TableDetails8">previous : </a><a href="#Top">top : </a><a href="#TableDetails10">next</a></li>
prompt The following shows any tables for schema &v_connector which have compression enabled.<br><br>
prompt
prompt Logminer and Binary support different types of compression.<br>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.Compression">Supported compression methods for using Oracle as a source for AWS DMS </a><br>
set markup html on spool on entmap off
-- START SQL
select table_name,COMPRESSION,COMPRESS_FOR from dba_tables where owner=upper('&v_connector') and COMPRESSION !='DISABLED';
-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="TableDetails10"><h2>Table Encryption :</h2></p>
prompt <li><a href="#TableDetails9">previous : </a><a href="#Top">top : </a><a href="#TableDetails11">next</a></li>
prompt AWS DMS has support for transparent data encryption (TDE). <br>
prompt Note : AWS DMS does not support transparent data encryption (TDE) when using Binary Reader with an Amazon RDS Oracle source. <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.Encryption">Supported encryption methods for using Oracle as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
prompt <B>Checking for encrypted columns :</B><br>
select count(*) from DBA_ENCRYPTED_COLUMNS where OWNER=upper('&v_connector');
prompt <B>Checking for encrypted tablespaces :</B><br>
SELECT count(*) FROM DBA_TABLESPACES where ENCRYPTED='YES';
-- END SQL
set markup html off
prompt <br>
prompt <br>



-- New Minor heading and block :
prompt <p id="TableDetails11"><h2>Clustered tables :</h2></p>
prompt <li><a href="#TableDetails10">previous : </a><a href="#Top">top : </a><a href="#TableDetails12">next</a></li>
prompt LogMiner supports table clusters for use by AWS DMS. Binary Reader does not. . <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Oracle Source</a><br>
set markup html on spool on entmap off
-- START SQL
select table_name,CLUSTER_NAME from dba_tables where owner=upper('&v_connector') and CLUSTER_NAME is not null order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>



-- New Minor heading and block :
prompt <p id="TableDetails12"><h2>Nested tables :</h2></p>
prompt <li><a href="#TableDetails11">previous : </a><a href="#Top">top : </a><a href="#TableDetails13">next</a></li>
prompt As of version 3.3.1, AWS DMS supports the replication of Oracle tables containing columns that are nested tables or defined types.. <br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.NestedTables">Replicating nested tables using Oracle as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
select table_name,CLUSTER_NAME from dba_tables where owner=upper('&v_connector') and CLUSTER_NAME is not null order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="TableDetails13"><h2>IOT with Overflow tables :</h2></p>
prompt <li><a href="#TableDetails12">previous : </a><a href="#Top">top : </a><a href="#ArchivalInformation1">next</a></li>
prompt When you use AWS DMS Binary Reader to access the redo logs, AWS DMS does not support CDC for index-organized tables with an overflow segment. <br>
prompt Alternatively, you can consider using LogMiner for such tables. <br><br>
prompt
prompt If the table is an index-organized table, then IOT_TYPE is IOT, IOT_OVERFLOW, or IOT_MAPPING. <br>
prompt If the table is not an index-organized table, then IOT_TYPE is NULL.<br>
set markup html on spool on entmap off
-- START SQL
SELECT table_name, iot_type, iot_name FROM dba_tables  where owner=upper('&v_connector') and  IOT_TYPE is not null;
-- END SQL
set markup html off
prompt <br>
prompt <br>


------------------------------------------------------------------------------
-- New Major heading :
prompt <hr>
prompt <p id="ArchivalInformation"><h2>Archival Information</h2></p>

-- New Minor heading and block :
prompt <p id="ArchivalInformation1"><h2>Archive Destinations :</h2></p>
prompt <li><a href="#TableDetails8">previous : </a><a href="#Top">top : </a><a href="#ArchivalInformation2">next</a></li>
set markup html on spool on entmap off
-- START SQL
select DEST_ID,DEST_NAME,STATUS,TARGET,ARCHIVER,DESTINATION,AFFIRM,TYPE,DB_UNIQUE_NAME,APPLIED_SCN from V$ARCHIVE_DEST;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="ArchivalInformation2"><h2>Archive log status :</h2></p>
prompt <li><a href="#ArchivalInformation1">previous : </a><a href="#Top">top : </a><a href="#Permissions1">next</a></li>
prompt DMS recommends that archive logs be kept on disk for 24 hours before being deleted.<br>
set markup html on spool on entmap off
-- START SQL
select NAME,DEST_ID,THREAD#,SEQUENCE#,FIRST_CHANGE#,FIRST_TIME,NEXT_CHANGE#,NEXT_TIME,STANDBY_DEST,ARCHIVED,APPLIED,DELETED,STATUS,COMPLETION_TIME from V$ARCHIVED_LOG where COMPLETION_TIME > sysdate -1;
-- END SQL
set markup html off
prompt <br>
prompt <br>






------------------------------------------------------------------------------
-- New Major heading :
prompt <hr>
prompt <p id="Permissions"><h2>Permissions</h2></p>

-- New Minor heading and block :
prompt <p id="Permissions1"><h2>System privileges :</h2></p>
prompt <li><a href="#ArchivalInformation2">previous : </a><a href="#Top">top : </a><a href="#Permissions2">next</a></li>
prompt DMS has different minimum permission requirements depending on if a task is full load, performs CDC, performs validation, is on premise vrs an RDS database.<br><br>
prompt
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
select PRIVILEGE from DBA_SYS_PRIVS where GRANTEE=upper('&v_connector') order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="Permissions2"><h2>Table Grants :</h2></p>
prompt <li><a href="#Permissions2">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues">next</a></li>
set markup html on spool on entmap off
-- START SQL
select TABLE_NAME,PRIVILEGE from DBA_TAB_PRIVS where OWNER=upper('&v_owner') and GRANTEE=upper('&v_connector') order by 1;
-- END SQL
set markup html off
prompt <br>
prompt <br>




------------------------------------------------------------------------------
-- New Major heading :
prompt <hr>
prompt <p id="PotentialIssues"><h2>Potential Issues</h2></p>

-- New Minor heading and block :
prompt <p id="PotentialIssues1"><h2>Unsupported data types :</h2></p>
prompt <li><a href="#ArchivalInformation2">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues2">next</a></li>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
select TABLE_NAME,COLUMN_NAME,DATA_TYPE from dba_tab_columns 
where owner=upper('&v_owner') 
and 	(	DATA_TYPE in('BFILE','ROWID','REF','UROWID','ANYDATA','UNDEFINED')
	or
	(	DATA_TYPE in(select TYPE_NAME from dba_types where OWNER=upper('&v_owner') )   )
	)
;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="PotentialIssues2"><h2>Tables with No PK :</h2></p>
prompt <li><a href="#PotentialIssues1">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues3">next</a></li>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
select table_name from dba_tables 
where OWNER=upper('&v_owner')
minus
select table_name
from dba_constraints
where OWNER=upper('&v_owner')
and constraint_type in ('P','U');
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="PotentialIssues3"><h2>Lob columns with NOT NULL set  :</h2></p>
prompt <li><a href="#PotentialIssues2">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues5">next</a></li>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>

set markup html on spool on entmap off
-- START SQL
-- LOB columns with NOT NULL set
select TABLE_NAME,COLUMN_NAME from dba_tab_columns 
where OWNER=upper('&v_owner') and DATA_TYPE in('CLOB','NCLOB','BLOB') and NULLABLE='N' order by 1,2;

-- END SQL
set markup html off
prompt <br>
prompt <br>


-- New Minor heading and block :
prompt <p id="PotentialIssues5"><h2>Oldest transaction with block changes :</h2></p>
prompt <li><a href="#PotentialIssues4">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues6">next</a></li>
set markup html on spool on entmap off
-- START SQL
-- Oldest transaction with block changes
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS'; 
select sysdate "Current Time",min(to_date(START_TIME,'MM/DD/YY HH24:MI:SS')) "Oldest Transaction Start time",
(sysdate - min(to_date(START_TIME,'MM/DD/YY HH24:MI:SS'))) "Transaction duration"  from v$transaction where CR_CHANGE > 0;
-- END SQL
set markup html off
prompt <br>
prompt <br>

-- New Minor heading and block :
prompt <p id="PotentialIssues6"><h2>PK AND Unique key on the same table :</h2></p>
prompt <li><a href="#PotentialIssues6">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues7">next</a></li>
prompt For additional details please see the following section of our documentation...<br>
prompt <a href="https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html">Using an Oracle database as a source for AWS DMS</a><br>
set markup html on spool on entmap off
-- START SQL
-- Oldest transaction with block changes
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS'; 
-- ?????????????????????  Need sql for this
-- END SQL
set markup html off
prompt <br>
prompt <br>



-- New Minor heading and block :
prompt <p id="PotentialIssues7"><h2>DMS User Session Waits :</h2></p>
prompt <li><a href="#PotentialIssues6">previous : </a><a href="#Top">top : </a><a href="#PotentialIssues8">next</a></li>
prompt <br>
prompt The following contains the current session wait event and timeing for the DMS user &v_connector. <br>
prompt This is a point in time snapshot of the session waits, but can sometimes help to identify contention inside the database.
prompt
prompt For futher details on these wait events, please refer to the Oracle documentation.
set markup html on spool on entmap off
-- START SQL
select INST_ID,sid,event,USERNAME,STATUS,PROGRAM,LOGON_TIME,LAST_CALL_ET,WAIT_TIME,SECONDS_IN_WAIT,STATE,WAIT_TIME_MICRO 
from gv$session where username=upper('&v_connector');
-- END SQL
set markup html off
prompt <br>
prompt <br>







set markup html off

spool off;

set termout on 
set verify on




prompt
prompt Script complete.
prompt
prompt The output is saved to dms_support_oracle-&&X-&&Y..html 
prompt
prompt Please review this file and upload to your AWS support case.
prompt
prompt
