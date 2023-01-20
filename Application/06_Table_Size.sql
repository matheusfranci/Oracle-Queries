select segment_name,segment_type,bytes/1024/1024 MB
from dba_segments
where segment_type='TABLE' AND segment_name in (
'RF_NOTAITEM', 
'RF_APURACAOANALITICA',
'RF_APURAPCANALITICA',
'MRL_CONTROLEQTDEESTOQUE',
'MRL_LANCTOESTOQUE',
'PDV_DOCTOITEM',
'MRL_CUSTODIA',
'RF_CUPOMITEM');
