SET LINESIZE  145 PAGESIZE  100 HEAD ON VERIFY    off

COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN free_mb                FORMAT 999,999,999   HEAD 'Free Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'


break on report on disk_group_name skip 1

compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    name                                     group_name
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , free_mb                                  free_mb
  , ROUND((1- (free_mb / decode(nvl(total_mb,0),0,1,nvl(total_mb,0))))*100, 2)  pct_used
FROM
    v$asm_diskgroup
ORDER BY
    name;
