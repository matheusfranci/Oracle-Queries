SELECT G.GROUP#, TYPE, MEMBER, BYTES / 1024 AS MB

FROM V$LOG g

JOIN V$LOGFILE V ON G.GROUP# = V.GROUP#;