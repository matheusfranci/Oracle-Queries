-- Top 10 tabelas
SELECT * FROM
(select
SEGMENT_NAME,
SEGMENT_TYPE,
BYTES/1024/1024/1024 GB,
TABLESPACE_NAME
from
dba_segments
order by 3 desc ) WHERE
ROWNUM <= 10
