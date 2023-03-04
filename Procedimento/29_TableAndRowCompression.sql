-- Using Table and Row Compression
--Verificando as compressões nas tabelas
SELECT table_name, compression, compress_for FROM user_tables;

SELECT table_name, partition_name, compression, compress_for
  FROM user_tab_partitions;
  
-- Precisa licenciar a feature de compressão
ALTER TABLE admin_emp MOVE NOCOMPRESS;

ALTER TABLE admin_emp MOVE ROW STORE COMPRESS;

ALTER TABLE admin_emp MOVE ROW STORE COMPRESS ADVANCED;
