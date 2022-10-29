-- Verifique se há porta https configurada
select dbms_xdb_config.getHttpsPort() from dual;

-- Caso tenha use-a ou mude através dessa procedure
exec dbms_xdb_config.sethttpsport(porta aqui)

-- Depois verifique se mostra no listener
lsnrctl status

-- OBS: Deve ser feito para cada pdb
-- Os links seguem esse padrão:
https://192.xxx.x.xx:5501/em/

-- Entre com a senha de sys configurada na instalação
