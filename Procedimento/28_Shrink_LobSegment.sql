-- Ncessário saber o nome do lob
SELECT b.owner,b.table_name,b.column_name,a.segment_name, a.bytes
FROM dba_segments a JOIN dba_lobs b on A.SEGMENT_NAME=B.SEGMENT_NAME
and B.SEGMENT_NAME='SYS_LOB0000064465C00005$$';

ALTER TABLE OWNER.TABLE MODIFY LOB (COLUMN_NAME) (SHRINK SPACE);
ALTER TABLE COGNOS.CMDATA MODIFY LOB (DATAPROP) (SHRINK SPACE);
