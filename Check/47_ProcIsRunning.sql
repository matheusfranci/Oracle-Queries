select 'CALLED PLSQL', vs.username, d_o.OWNER, d_o.object_name, vs.status, vs.MACHINE, vs.PROGRAM -- whatever info you need
  from dba_objects d_o
       inner join
       v$session vs
          on d_o.object_id = vs.plsql_entry_object_id
union all
select 'CURRENT PLSQL', vs.username, d_o.OWNER, d_o.object_name, vs.status, vs.MACHINE, vs.PROGRAM
  from dba_objects d_o
       inner join
       v$session vs
          on d_o.object_id = vs.plsql_object_id
