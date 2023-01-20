SELECT cols.table_name, cols.column_name, cols.position, cons.status, cons.owner
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name IN ('RF_NOTAITEM',
'RF_APURACAOANALITICA',
'RF_APURAPCANALITICA',
'MRL_CONTROLEQTDEESTOQUE',
'MRL_LANCTOESTOQUE',
'PDV_DOCTOITEM',
'MRL_CUSTODIA',
'RF_CUPOMITEM');
