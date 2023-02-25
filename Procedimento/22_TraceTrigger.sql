-- Fixa o trace a cada efento de logon
CREATE OR REPLACE TRIGGER user_logon after logon on database

declare
  v_user varchar2(30);
  v_machine varchar2(50);
  v_program varchar2(80);
  v_sid number;
  v_serial number;

begin

  select trim(username), trim(machine), trim(program), sid, serial#
  into v_user, v_machine, v_program, v_sid, v_serial
  from gv$session
  where sid in (select distinct sid from gv$mystat);

  --if v_program like '%316%'  then
--  if v_machine = 'lab01.ccg.com.br'  then
   execute immediate 'alter session set tracefile_identifier = TRACE_TUDO';
   execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
  --end if;

end;
/

-- Finaliza o trace a cada evento de logoff
CREATE OR REPLACE TRIGGER user_logoff before logoff on database

declare
  v_user varchar2(30);
  v_machine varchar2(30);
  v_sid number;
  v_serial number;

begin

  select trim(username),trim(machine), sid, serial#
  into v_user, v_machine, v_sid, v_serial
  from v$session
  where sid in (select distinct sid from v$mystat);

  --if v_user = 'SAP_IN'  then
 -- if v_machine = '128.0.5.161'   then

  execute immediate 'alter system set events ''10046 trace name context off''';
  ----end if;

end;
/

