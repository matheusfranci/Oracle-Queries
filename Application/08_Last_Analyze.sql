select 
table_name, 
stale_stats, 
last_analyzed
from 
dba_tab_statistics
where 
owner = 'CONSINCO'
AND table_name in ('RF_NOTAITEM',
'RF_APURACAOANALITICA',
'RF_APURAPCANALITICA',
'MRL_CONTROLEQTDEESTOQUE',
'MRL_LANCTOESTOQUE',
'PDV_DOCTOITEM',
'MRL_CUSTODIA',
'RF_CUPOMITEM')
order by 
last_analyzed desc, table_name asc;
