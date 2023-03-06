select df.tablespace_name, df.file_name, round(df.bytes/1024/1024) totalSizeMB, nvl(round(usedBytes/1024/1024), 0) usedMB, nvl(round(freeBytes/1024/1024), 0) freeMB,
    nvl(round(freeBytes/df.bytes * 100), 0) freePerc, df.autoextensible
from dba_data_files df
    left join (
        select file_id, sum(bytes) usedBytes
        from dba_extents
        group by file_id
    ) ext on df.file_id = ext.file_id
    left join (
        select file_id, sum(bytes) freeBytes
        from dba_free_space
        group by file_id
    ) free on df.file_id = free.file_id
order by df.tablespace_name, df.file_name;


SELECT  Substr(df.tablespace_name,1,20) "Tablespace Name",
        Substr(df.file_name,1,80) "File Name",
        Round(df.bytes/1024/1024,0) "Size (M)",
        decode(e.used_bytes,NULL,0,Round(e.used_bytes/1024/1024,0)) "Used (M)",
        decode(f.free_bytes,NULL,0,Round(f.free_bytes/1024/1024,0)) "Free (M)",
        decode(e.used_bytes,NULL,0,Round((e.used_bytes/df.bytes)*100,0)) "% Used"
FROM    DBA_DATA_FILES DF,
       (SELECT file_id,
               sum(bytes) used_bytes
        FROM dba_extents
        GROUP by file_id) E,
       (SELECT sum(bytes) free_bytes,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE    e.file_id (+) = df.file_id
AND      df.file_id  = f.file_id (+)
ORDER BY df.tablespace_name,
         df.file_name
