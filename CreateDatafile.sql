ALTER TABLESPACE CONSINCO_DAT
ADD DATAFILE '+DG_DATA_VIA/viarac/datafile/consinco_dat78.dbf' size 31744M;

ALTER TABLESPACE CONSINCO_DAT
ADD DATAFILE '+DG_DATA_VIA/viarac/datafile/consinco_dat79.dbf' size 31744M;

ALTER TABLESPACE CONSINCO_DAT
ADD DATAFILE '+DG_DATA_VIA/viarac/datafile/consinco_dat80.dbf' size 31744M AUTOEXTEND ON 
NEXT 1024K MAXSIZE 32256M ;

alter database
datafile '+DATA/rms01_gru188/datafile/cpdinter_d_2.dbf'
resize 31744M;
