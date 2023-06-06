-- Verificando processos que nao estão em idle
top -i

-- Vrificando processos de um usuário 
top -i -U oracle

-- Verificando os processos com PID process linux
SELECT s.sid,
s.serial#,
s.username,
s.osuser,
p.spid,
s.machine,
p.terminal,
s.program,
s.module,
s.status,
s.type,
s.wait_class,
FROM v$session s, v$process p,
WHERE s.paddr = p.addr
AND SPID IN (290601, 270847, 175035, 245131, 158325);
