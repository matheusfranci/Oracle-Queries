select

size_for_estimate ,

buffers_for_estimate ,

estd_physical_read_factor ,

estd_physical_reads 

from

v$db_cache_advice

where

name = 'DEFAULT'

and

block_size = (SELECT value FROM V$PARAMETER

WHERE name = 'db_block_size')

and

advice_status = 'ON';