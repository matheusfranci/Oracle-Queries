-- expdp
expdp orion/orion tables=ZEUSMANAGER.TAB_REGRAS_ICMS directory=BK_DUMP dumpfile=TAB_REGRAS_ICMS.dmp logfile=TAB_REGRAS_ICMS.log

-- impdp REPLACE
impdp orion/orion@viahml tables=ZEUSMANAGER.TAB_REGRAS_ICMS directory=DATAPUMP_DIR dumpfile=TAB_REGRAS_ICMS.dmp logfile=imp_tab_regras_icms.log TABLE_EXISTS_ACTION=REPLACE

--  Uma boa prática seria fazer o delete from na tabela destino antes de importar
delete from tabela;
227677 rows deleted.

-- IMPDP com append
impdp orion/orion@viahml tables=ZEUSMANAGER.TAB_REGRAS_ICMS directory=DATAPUMP_DIR dumpfile=TAB_REGRAS_ICMS.dmp logfile=imp_tab_regras_icms.log TABLE_EXISTS_ACTION=APPEND

