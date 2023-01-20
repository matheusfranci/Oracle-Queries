select to_char(round(value,4),'999.99') ||'%' "PGA Hit Ratio"
from sys.v_$pgastat
where name = 'cache hit percentage';
