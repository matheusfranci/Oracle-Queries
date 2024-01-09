-- #############################################################################
-- Unimix Tecnologia
--
-- SCRIPT     : NAME_of_SCRIPT
-- AUTOR      : AUTHORS_NAME
-- DATA       : DATE_of_CREATION
-- PLATAFORMA : (nao dependente)
-- PROPOSITO  : Forneca uma clara, e se necessario, longa
-- #############################################################################
-- REVISOES   
-- 
--##############################################################################
--clear screen
@@plinha

prompt scripts disponiveis no diretorio

@@plinha

prompt 
prompt puser.sql                     define usuario e senha
prompt pconn.sql                     conecta a instancia informada
prompt 
prompt login.sql                     prepara o ambiente do sqlplus
prompt pcheckdg.sql                  consulta status dataguard (a partir do prim) 
prompt pdatafiles.sql                lista os datafiles
prompt pindexmonitorado.sql          lista os indexes monitorados
prompt pkill.sql                     executa kill session
prompt plistadomidx.sql              Listar os indices tipo "domain" presentes na instancia
prompt psessativas.sql               lista as sessoes ativas
prompt psessblockwait.sql            lista as sessoes bloqueadoras e em espera
prompt prepobjinvalido.sql	         lista os objetos invalidos
prompt reporta-backup-rman.sql       reporta os ultimos backups para fita
prompt 
prompt 