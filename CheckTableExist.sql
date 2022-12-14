-- Verificando se a tabela existe

Select table_Name from user_Tables
WHERE table_name = 'TAB_REGRAS_ICMS';

Select table_Name from user_Tables
WHERE table_name LIKE '%ICMS';
