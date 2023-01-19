--Necessário shutdown e startup no modo restrito
shut immediate;

startup restrict;

-- consulta o atual
select value from nls_database_parameters where parameter = 'NLS_CHARACTERSET';

-- substitui o atual pelo WE8ISO8859P1
ALTER DATABASE CHARACTER SET INTERNAL_USE WE8ISO8859P1;

-- Tirandoo do modo restrito
alter system disable restricted session;
 
