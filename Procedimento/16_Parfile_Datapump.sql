JOB_NAME=EXPORT_ORION
DIRECTORY=ORACLE_BASE
DUMPFILE=EXPORT_ORCLPDB.dmp
FULL=Y

expdp system/2022@orclpdb parfile=C:\oracle_19c\expdp.par logfile=export.log
