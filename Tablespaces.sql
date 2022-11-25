set lines 2000
set pages 2000
SELECT tablespace_name,
size_mb,
free_mb,
max_size_mb,
max_free_mb,
TRUNC((max_free_mb/max_size_mb) * 100) AS free_pct,
RPAD(' '|| RPAD('X',ROUND((max_size_mb-max_free_mb)/max_size_mb*10,0), 'X'),11,'-') AS used_pct
FROM (
SELECT a.tablespace_name,
b.size_mb,
a.free_mb,
b.max_size_mb,
a.free_mb + (b.max_size_mb - b.size_mb) AS max_free_mb
FROM (SELECT tablespace_name,
TRUNC(SUM(bytes)/1024/1024) AS free_mb
FROM dba_free_space
GROUP BY tablespace_name) a,
(SELECT tablespace_name,
TRUNC(SUM(bytes)/1024/1024) AS size_mb,
TRUNC(SUM(GREATEST(bytes,maxbytes))/1024/1024) AS max_size_mb
FROM dba_data_files
GROUP BY tablespace_name) b
WHERE a.tablespace_name = b.tablespace_name
)
ORDER BY tablespace_name;


SELECT  a.tablespace_name,
    ROUND (((c.BYTES - NVL (b.BYTES, 0)) / c.BYTES) * 100,2) percentage_used,
    c.BYTES / 1024 / 1024 space_allocated,
    ROUND (c.BYTES / 1024 / 1024 - NVL (b.BYTES, 0) / 1024 / 1024,2) space_used,
    ROUND (NVL (b.BYTES, 0) / 1024 / 1024, 2) space_free,
    c.DATAFILES
  FROM dba_tablespaces a,
       (    SELECT   tablespace_name,
                  SUM (BYTES) BYTES
           FROM   dba_free_space
       GROUP BY   tablespace_name
       ) b,
      (    SELECT   COUNT (1) DATAFILES,
                  SUM (BYTES) BYTES,
                  tablespace_name
           FROM   dba_data_files
       GROUP BY   tablespace_name
    ) c
  WHERE b.tablespace_name(+) = a.tablespace_name
    AND c.tablespace_name(+) = a.tablespace_name
ORDER BY tablespace_name;
