--Usuário exemplo criado, segue comando de criação:
alter session set "_ORACLE_SCRIPT"=true;

CREATE USER exemlo IDENTIFIED BY "null"
PASSWORD EXPIRE ;

Seguem os grants;

GRANT CONNECT TO exemplo;

grant create session, select any table, select any dictionary to exemplo;
