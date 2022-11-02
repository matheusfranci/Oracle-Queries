-- VERIFICANDO O SPFILE
SHOW PARAMETER SPFILE

-- CRIAÇÃO DO SPFILE
CREATE SPFILE FROM PFILE='/u01/app/oracle/product/19.0.0/dbhome_1/dbs/init.ora'

-- CRIAÇÃO DO SPFILE EM OUTRO DIRETÓRIO DIFERENTE DO PADRÃO
CREATE SPFILE='/u01/app/oracle/product/19.0.0/dbhome_1/dbs/spfileprd.ora' FROM PFILE='/u01/app/oracle/product/19.0.0/dbhome_1/dbs/init.ora'

-- CRIAÇÃO DE SPFILE COM BASE NA MEMÓRIA


startup pfile='/u01/app/oracle/product/19.0.0/dbhome_1/dbs/initprd.ora'
