-- Criação de common role
CREATE ROLE c##sec_admin IDENTIFIED BY 2022 CONTAINER=ALL; --Para todos os containers e pdbs c## igual ao prefixo common objects

-- Verificando as roles
select role from dba_roles;

-- Criação de Local Role
ALTER SESSION SET CONTAINER=MYPDB;
CREATE ROLE sec_admin CONTAINER=CURRENT

-- Grant em Common User
GRANT AUDIT_ADMIN TO c##orion CONTAINER=ALL;

-- Grant em Common User de dentro de um pdb
GRANT AUDIT_ADMIN TO C##orion CONTAINER=CURRENT;

-- Grant para uma role no pdb
Grant audit_admin to sec_admin;

-- Autenticando role com senha e provisóriamente, serve para uma sessão.
SET ROLE DBA IDENTIFIED BY 2022;
SET ROLE NONE;

