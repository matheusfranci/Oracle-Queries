-- #######################################################################################################
--                                                                            			                 #
--                                                                                                       #
-- SCRIPT     : check.sql                                                                                #
-- AUTOR      : Marcos Rocha                                                                             #
-- DATA       : 29/11/2023                                                     			                 #
-- PROPOSITO  : Checagem rápida da situação do ambiente gerando o report no diretório c:\cnseg\*         #
--                                                                                                       #
-- #######################################################################################################
--
--

prompt Usuario   :&&__nome_usuario
prompt Usuario   :&&__senha


--
--
--
--
spool 'B:\INFRA\ckecklist_db\backup\INDICES.html'
prompt .
prompt .
prompt ###################################
prompt ## IDENTIFICA INDICES            ##
prompt ###################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@indexes.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@indexes.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@indexes.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@indexes.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@indexes.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@indexes.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\DATAGUARD.html'
prompt .
prompt .
prompt #######################################
prompt ## DATAGUARD - AMBIENTE DE PRODUCAO  ##
prompt #######################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@pcheckdg.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@pcheckdg.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@pcheckdg.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@pcheckdg.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@pcheckdg.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@pcheckdg.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\BLOCK.html'
prompt .
prompt .
prompt ###################################
prompt ## IDENTIFICA BLOCOS CORROMPIDOS ##
prompt ###################################
prompt .
prompt .
@corruption_bl.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@corruption_bl.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@corruption_bl.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@corruption_bl.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@corruption_bl.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@corruption_bl.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@corruption_bl.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\TAMANHO_TABELAS.html'
prompt .
prompt .
prompt ###################################
prompt ## LISTA TAMANHO DE CADA TABELA  ##
prompt ###################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@tabelas.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@tabelas.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@tabelas.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@tabelas.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@tabelas.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@tabelas.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\BACKUP.html'
prompt .
prompt .
prompt ##########################
prompt ## BACKUP DOS AMBIENTES ##
prompt ##########################
prompt .
prompt .
@reporta-backup-rman.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@reporta-backup-rman.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@reporta-backup-rman.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@reporta-backup-rman.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@reporta-backup-rman.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@reporta-backup-rman.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@reporta-backup-rman.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\INSTANCIAS.html'
prompt .
prompt .
prompt ############################
prompt ## TESTANDO_AS_INSTANCIAS ##
prompt ############################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@verifica_banco.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@verifica_banco.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@verifica_banco.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@verifica_banco.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@verifica_banco.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@verifica_banco.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\TABLESPACES.html'
prompt .
prompt .
prompt ##############################
prompt ## VERIFICANDO OS DATAFILES ##
prompt ##############################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@tablespace.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@tablespace.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@tablespace.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@tablespace.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@tablespace.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@tablespace.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\ASM.html'
prompt .
prompt .
prompt ###################################
prompt ## VERIFICANDO AS INSTANCIAS ASM ##
prompt ###################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@asm.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@asm.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@asm.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@asm.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@asm.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@asm.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\SCHEDULES.html'
prompt .
prompt .
prompt ##############################
prompt ## VERIFICANDO OS SCHEDULES ##
prompt ##############################
prompt .
prompt .
@consulta_schedule.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@consulta_schedule.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@consulta_schedule.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@consulta_schedule.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@consulta_schedule.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@consulta_schedule.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@consulta_schedule.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\PARAMETROS.html'
prompt .
prompt .
prompt #####################################
prompt ## VERIFICANDO OS PARAMETROS DO DB ##
prompt #####################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@parameter.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@parameter.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@parameter.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@parameter.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@parameter.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@parameter.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\INTERCONNECT.html'
prompt .
prompt .
prompt  #############################
prompt  ## VERIFICANDO INTERCONNECT##
prompt  #############################
prompt .
prompt .
@interconnect.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@interconnect.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@interconnect.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@interconnect.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@interconnect.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@interconnect.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@interconnect.sql
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\ALERTAS.html'
prompt .
prompt .
prompt #####################################
prompt ## VERIFICANDO OS ALERTAS DO DB    ##
prompt #####################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@alertas.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@alertas.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@alertas.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@alertas.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@alertas.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@alertas.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\LOCKS.html'
prompt .
prompt .
prompt #############################
prompt ## VERIFICANDO LOCKS DO DB ##
prompt #############################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@locks.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@locks.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@locks.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@locks.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@locks.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@locks.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\TABLES_NOLOGGIN.html'
prompt .
prompt .
prompt ################################
prompt ## VERIFICANDO TABES_NOLOGGIN ##
prompt ################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@nologgin.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@nologgin.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@nologgin.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@nologgin.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@nologgin.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@nologgin.sql
prompt .
prompt .
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\USUARIOS.html'
prompt .
prompt .
prompt ################################
prompt ## VERIFICANDO USUARIOS		 ##
prompt ################################
prompt .
prompt .
@usuarios.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@usuarios.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@usuarios.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@usuarios.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@usuarios.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@usuarios.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@usuarios.sql
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\OPTIONS.html'
prompt .
prompt .
prompt ################################
prompt ## VERIFICANDO options		 ##
prompt ################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@option.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@option.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@option.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@option.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@option.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@option.sql
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\GRANTS.html'
prompt .
prompt .
prompt ######################################
prompt ## VERIFICANDO o_grant dos usuarios ##
prompt ######################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@grants.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@grants.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@grants.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@grants.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@grants.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@grants.sql
spool off
prompt .
prompt .
spool 'B:\INFRA\ckecklist_db\backup\constraints.html'
prompt .
prompt .
prompt ######################################
prompt ## VERIFICANDO constraints          ##
prompt ######################################
prompt .
prompt .
connect &&__nome_usuario/&&__senha@SP3_SINGLE_19C_HOMOLOG
@constraints.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_HOMOLOGDW
@constraints.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_DW
@constraints.sql
connect &&__nome_usuario/&&__senha@SP3_SINGLE_11G_I2
@constraints.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_DIVERSOS_NODE1
@constraints.sql
connect &&__nome_usuario/&&__senha@SP3_RAC_19C_RNS_NODE1
@constraints.sql
spool off
prompt .
prompt .

prompt ###########
prompt ** F I M **
prompt ###########
prompt .
prompt .
exit


