SELECT idx.table_name, idx.index_name, SUM(bytes)/1024/1024 MB
  FROM dba_segments seg,
       dba_indexes idx
  WHERE idx.table_owner = 'CONSINCO'
    AND idx.table_name IN ('RF_NOTAITEM',
'RF_APURACAOANALITICA',
'RF_APURAPCANALITICA',
'MRL_CONTROLEQTDEESTOQUE',
'MRL_LANCTOESTOQUE',
'PDV_DOCTOITEM',
'MRL_CUSTODIA',
'RF_CUPOMITEM')
    AND idx.owner       = seg.owner
    AND idx.index_name  = seg.segment_name
    AND idx.index_name NOT IN('MRL_CUSTODIAPK', -- Clausula NOT IN
'MRL_CUSTODIAIE1')
)
