-- Verificar as tabelas com o parâmetro inferior a 20
SELECT COUNT(1)
FROM DBA_TABLES
WHERE OWNER IN ('RM', 'CONSINCO', 'ZEUSMANAGER', 'NDD_CONNECTOR', 'ZEUSMANAGER_ESTRUTURA')
  AND TEMPORARY = 'N'
  AND INI_TRANS < 20;
  
  --Alteração de fato
  DECLARE
    Texto_DDL  VARCHAR2(256);
BEGIN	
    FOR initrans_data IN (SELECT 'ALTER TABLE ' || OWNER || '.' || TABLE_NAME || ' INITRANS 20' AS COMANDO
                          FROM DBA_TABLES
                          WHERE OWNER IN ('RM', 'CONSINCO', 'ZEUSMANAGER', 'NDD_CONNECTOR', 'ZEUSMANAGER_ESTRUTURA')
						    AND TEMPORARY = 'N'
                            AND INI_TRANS < 20)
    LOOP
	    BEGIN
    	    Texto_DDL := initrans_data.COMANDO;
            EXECUTE IMMEDIATE Texto_DDL;
		EXCEPTION
		    WHEN OTHERS THEN
			    NULL;
		END;
    END LOOP;
END;	
/

-- Verificar os índices com o parâmetro inferior a 20
SELECT COUNT(1)
FROM DBA_INDEXES
WHERE OWNER IN ('RM', 'CONSINCO', 'ZEUSMANAGER', 'NDD_CONNECTOR', 'ZEUSMANAGER_ESTRUTURA')
  AND TEMPORARY = 'N'
  AND INI_TRANS < 20;
  
  -- Alteração dos initrans dos índices
  DECLARE
    Texto_DDL  VARCHAR2(256);
BEGIN	
    FOR initrans_data IN (SELECT 'ALTER INDEX ' || OWNER || '.' || INDEX_NAME || ' INITRANS 20' AS COMANDO
                          FROM DBA_INDEXES
                          WHERE OWNER IN ('RM', 'CONSINCO', 'ZEUSMANAGER', 'NDD_CONNECTOR', 'ZEUSMANAGER_ESTRUTURA')
						    AND TEMPORARY = 'N'
                            AND INI_TRANS < 20)
    LOOP
	    BEGIN
    	    Texto_DDL := initrans_data.COMANDO;
            EXECUTE IMMEDIATE Texto_DDL;
		EXCEPTION
		    WHEN OTHERS THEN
			    NULL;
		END;
    END LOOP;
END;	
/
