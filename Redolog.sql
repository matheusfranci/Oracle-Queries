-- Tamanho em MBS
select GROUP#,THREAD#,SEQUENCE#,bytes/1024/1024,
MEMBERS,STATUS from v$log;

-- Redo status
SELECT
 a.GROUP#,
 a.THREAD#,
 a.SEQUENCE#,
 a.ARCHIVED,
 a.STATUS,
 b.MEMBER AS REDOLOG_FILE_NAME,
 (a.BYTES/1024/1024) AS SIZE_MB
FROM v$log a
JOIN v$logfile b ON a.Group#=b.Group#
ORDER BY a.GROUP#;
