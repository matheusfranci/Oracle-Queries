--Criação de tablespace, lembrando que o tamanho máximo será 32gb
CREATE tablespace EASY_DAT_MED 
DATAFILE '+DATA/RJD14/DATAFILES/easy_dat_med13.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med01.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med02.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med03.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med04.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med05.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med06.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med07.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med08.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med09.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med10.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med11.dbf' size 6024M,
'+DATA/RJD14/DATAFILES/easy_dat_med12.dbf' size 6024M  AUTOEXTEND ON;

--CRIAÇÃO DE TEMPORARY
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 30720M AUTOEXTEND ON;

--Resize em datafile!
ALTER DATABASE DATAFILE '+DATA/DFRPRD01_GRU1JQ/E9511690284BC0AFE05386C9030A8DDF/DATAFILE/USERS.271.1115926815' RESIZE 1024M;

-- Lembrando que há possibilidades de utilizar a cláusula reuse
CREATE tablespace EASY_DAT_MED 
DATAFILE '+DATA/rjd14/datafile/easy_dat_med13.dbf' size 6024M,
'+DATA/rjd14/datafile/easy_dat_med01.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med02.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med03.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med04.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med05.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med06.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med07.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med08.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med09.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med10.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med11.dbf' size 6024M REUSE,
'+DATA/rjd14/datafile/easy_dat_med12.dbf' size 6024M REUSE AUTOEXTEND ON;

--Resize de datafile
alter database
datafile '+DG_FRA_VIA/viarac/datafile/consinco_dat.650.1110371321'
resize 31744M;
