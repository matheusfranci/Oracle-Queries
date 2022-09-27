--Exclusão de redo
ALTER DATABASE DROP LOGFILE GROUP 2;

--Adição de grupo de redo
ALTER DATABASE
ADD LOGFILE GROUP 2 ('D:\oracle\oradata\DB10\log\REDO02.LOG',
                     'D:\oracle\oradata\DB10\log\REDO12.LOG') SIZE 10M;
                     
--Adiação de membro em grupo existente
ALTER DATABASE ADD LOGFILE MEMBER
/DISK4/log1b.rdo' TO GROUP 1,
'/DISK4/log2b.rdo' TO GROUP 2;

--Excluindo membro de redo group
ALTER DATABASE DROP LOGFILE MEMBER
'/DISK4/log2b.dbf';

--Checkpoint antes de alternar o redo
alter system checkpoint global;

--Alternância de redo
alter system switch logfile ;
