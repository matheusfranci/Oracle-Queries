sed -i 's/^column value_col_plus_show_param format a30 HEADING VALUE/--column value_col_plus_show_param format a60 HEADING VALUE/g' $ORACLE_HOME/sqlplus/admin/glogin.sql

cat >> $ORACLE_HOME/sqlplus/admin/glogin.sql<<EOF

-- By DBA `date +'%d/%m/%y'`
set LINES 250 PAGES 100 NUMFORMAT 9999999999999
set SQLPROMPT "_user'@'_CONNECT_IDENTIFIER SQL> "
column TYPE_COL_PLUS_SHOW_PARAM format A15
column NAME_COL_PLUS_SHOW_PARAM format A40
column SEGMENT_NAME             format a30
column column_NAME              format a30
column DATA_TYPE                format a20
column TYPE                     format a20
column OWNER                    format a25
column MACHINE                  format A30
column OSUSER                   format A20
column USERNAME                 format A20
column PROGRAM                  format A40
column OWNER                    format A20
column OBJECT_NAME              format A50
column DIRECTORY_NAME           format A40
column DIRECTORY_PATH           format A70
column DATAFILE                 format A50
EOF
echo 
cat $ORACLE_HOME/sqlplus/admin/glogin.sql
