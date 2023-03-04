show parameter db_create_file_dest

show parameter db_create_online_log

show parameter db_recovery_file_dest

alter system set db_create_file_dest='/u02/oradata' scope=both;

alter system set db_recovery_file_dest='/u02/fast_recovery_area' scope=both;

alter system set db_recovery_file_dest_size=10G scope=both;

-- db_create_online_log_dest são parâmetros utilizados para multiplexar os redos
alter system set DB_CREATE_ONLINE_LOG_DEST_1 ='/u02/oradata' scope=both;

alter system set DB_CREATE_ONLINE_LOG_DEST_2 ='/u03/oradata' scope=both;

alter system set LOG_ARCHIVE_DEST_1 ='LOCATION=USE_DB_RECOVERY_FILE_DEST' scope=both;
