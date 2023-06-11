-- Verifique se há porta HTTPS configurada
select dbms_xdb_config.getHttpsPort() from dual;

-- Verifique se há porta HTTP configurada
select dbms_xdb_config.getHttpPort() from dual;

-- Caso tenha use-a ou mude através dessa procedure
exec dbms_xdb_config.sethttpsport(5500)

-- Depois verifique se mostra no listener
lsnrctl status

-- OBS: Deve ser feito para cada pdb
-- Os links seguem esse padrão:
https://172.16.9.110:5500/em/

-- Entre com a senha de sys configurada na instalação


Note:In accordance with industry standards, Oracle is deprecating Flash-based Oracle Enterprise Manager Express (Oracle EM Express). Starting with Oracle Database 19c, Oracle EM Express, the default management option for Oracle Database, is based on Java JET technology. In this initial release, there are some options available in Flash-based Oracle EM Express that are not available in the JET version. If necessary, use the following command to revert to Flash Oracle EM Express:
SQL> @?/rdbms/admin/execemx emx


To return to JET Oracle EM Express, use the following command:
SQL> @?/rdbms/admin/execemx omx
