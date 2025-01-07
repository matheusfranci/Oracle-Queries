set lines 9999
set pages 9999
SELECT 'restore archivelog from logseq  ' ||To_Char(al.sequence# -1)||  ' until logseq ' ||l.SEQUENCE#|| ' thread ' ||l.THREAD#|| ';'
  FROM v$archived_log al, v$log L
    WHERE 20290265853035 BETWEEN AL.first_change# AND AL.next_change#
       AND L.STATUS = 'CURRENT'
        AND AL.THREAD# = L.THREAD#
         ORDER BY l.thread#
           ;
