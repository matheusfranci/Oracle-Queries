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

-- Considerando o auto extend
SELECT df.tablespace_name tablespace_name,
 max(df.autoextensible) auto_ext,
 round(df.maxbytes / (1024 * 1024), 2) max_ts_size,
 round((df.bytes - sum(fs.bytes)) / (df.maxbytes) * 100, 2) max_ts_pct_used,
 round(df.bytes / (1024 * 1024), 2) curr_ts_size,
 round((df.bytes - sum(fs.bytes)) / (1024 * 1024), 2) used_ts_size,
 round((df.bytes-sum(fs.bytes)) * 100 / df.bytes, 2) ts_pct_used,
 round(sum(fs.bytes) / (1024 * 1024), 2) free_ts_size,
 nvl(round(sum(fs.bytes) * 100 / df.bytes), 2) ts_pct_free
FROM dba_free_space fs,
 (select tablespace_name,
 sum(bytes) bytes,
 sum(decode(maxbytes, 0, bytes, maxbytes)) maxbytes,
 max(autoextensible) autoextensible
 from dba_data_files
 group by tablespace_name) df
WHERE fs.tablespace_name (+) = df.tablespace_name
GROUP BY df.tablespace_name, df.bytes, df.maxbytes
UNION ALL
SELECT df.tablespace_name tablespace_name,
 max(df.autoextensible) auto_ext,
 round(df.maxbytes / (1024 * 1024), 2) max_ts_size,
 round((df.bytes - sum(fs.bytes)) / (df.maxbytes) * 100, 2) max_ts_pct_used,
 round(df.bytes / (1024 * 1024), 2) curr_ts_size,
 round((df.bytes - sum(fs.bytes)) / (1024 * 1024), 2) used_ts_size,
 round((df.bytes-sum(fs.bytes)) * 100 / df.bytes, 2) ts_pct_used,
 round(sum(fs.bytes) / (1024 * 1024), 2) free_ts_size,
 nvl(round(sum(fs.bytes) * 100 / df.bytes), 2) ts_pct_free
FROM (select tablespace_name, bytes_used bytes
 from V$temp_space_header
 group by tablespace_name, bytes_free, bytes_used) fs,
 (select tablespace_name,
 sum(bytes) bytes,
 sum(decode(maxbytes, 0, bytes, maxbytes)) maxbytes,
 max(autoextensible) autoextensible
 from dba_temp_files
 group by tablespace_name) df
WHERE fs.tablespace_name (+) = df.tablespace_name
GROUP BY df.tablespace_name, df.bytes, df.maxbytes
ORDER BY 4 DESC;
