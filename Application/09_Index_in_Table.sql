select distinct
table_name,
index_name
from
dba_ind_columns
where
table_owner='CONSINCO'
AND table_name in ('RF_NOTAITEM',
'RF_APURACAOANALITICA',
'RF_APURAPCANALITICA',
'MRL_CONTROLEQTDEESTOQUE',
'MRL_LANCTOESTOQUE',
'PDV_DOCTOITEM',
'MRL_CUSTODIA',
'RF_CUPOMITEM')
order by
table_name desc;
