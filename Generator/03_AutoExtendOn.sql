select 'alter database datafile '|| file_name|| ' '|| ' autoextend on maxsize unlimited;'from dba_data_files where autoextensible='NO';
