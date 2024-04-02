SELECT sysdate, e.owner, e.object_name,a.username, a.sid, a.serial#, a.osuser, 
(b.blocks*d.block_size)/1048576 MB_used
FROM v$session a, v$tempseg_usage b, v$sqlarea c, dba_objects e,
     (select block_size from dba_tablespaces where tablespace_name='TEMP') d
    WHERE b.tablespace = 'TEMP'
    and a.saddr = b.session_addr
    AND c.address= a.sql_address
    AND c.hash_value = a.sql_hash_value
    AND e.object_id = a.plsql_entry_object_id
    AND (b.blocks*d.block_size)/1048576 > 1024
    ORDER BY b.tablespace, 6 desc;
