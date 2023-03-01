select 'alter database datafile '|| file_name|| ' '|| ' autoextend on maxsize unlimited;'from dba_data_files where autoextensible='NO';

select 'ALTER DATABASE DATAFILE "'|| file_name|| '" '|| 'AUTOEXTEND ON MAXSIZE UNLIMITED;'from dba_data_files where autoextensible='NO';
