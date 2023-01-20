--Usuário exemplo criado, segue comando de criação:
alter session set "_ORACLE_SCRIPT"=true;

CREATE USER exemlo IDENTIFIED BY "null"
PASSWORD EXPIRE ;

Seguem os grants;

GRANT CONNECT TO exemplo;

grant create session, select any table, select any dictionary to exemplo;

grant dba to matheusorion with admin option;


--Multitenant
grant create session to matheusorion container=all;

grant dba to matheusorion container=all;

grant select any dictionary to matheusorion container=all;

alter user matheusorion set container_data=all container=current;
