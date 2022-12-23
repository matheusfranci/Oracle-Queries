/*O profile é um recurso que possui a capacidade de limitar a utilização de alguns recursos do banco de dados. Você associa um
profile a um usuário e desta forma garante que ele não ultrapasse estes limites.
Em ambientes multitentant, diferentes profiles podem ser associados a um usuário comum em um container root ou PDB.
Quando um usuário comum se conecta em um PDB, um profile no qual ele está associado vai aplicar-se dependendo se está
relacionado a configurações de senha ou de recursos.

SESSIONS_PER_USER: especifica o número de sessões concorrentes para o qual você quer limitar o usuário.
Ø CPU_PER_SESSION: especifica o tempo limite de CPU para uma sessão, expressada em centésimos de
segundos.
Ø CPU_PER_CALL: especifica o tempo limite para uma chamada(um parse, execute ou fetch), expressado em
centésimos de segundos.
Ø CONNECT_TIME: especifica o tempo total decorrido para uma sessão, expressado em minutos.
Ø IDLE_TIME: especifica o período permitido de tempo inativo contínuo durante uma sessão, expressada em
minutos. Queries longas e outras operações não estão sujeitas a este limite. Quando você configura idle
timeout de X minutos, note que a sessão levará alguns minutos adicionais para ser finalizada. No lado cliente,
da aplicação, uma mensagem de erro aparece somente na próxima vez, quando o client inativo tenta emitir
um novo comando.
Profile
Parâmetros de Recursos
Ø LOGICAL_READS_PER_SESSION: especifica o número permitido de data blocks lidos em uma sessão, incluindo
blocos lidos da memória e do disco.
Ø LOGICAL_READS_PER_CALL: especifica o número permitido de data blocks lidos para uma chamada de
processo a um comando SQL(um parse, execute ou fetch).
Ø PRIVATE_SGA: especifica o montante de espaço privado uma sessão pode alocar na shared pool da System
Global Area(SGA). Este item aplica-se somente se você estiver utilizando a arquitetura shared server. O espaço
privado para uma sessão na SGA inclui áreas privadas de SQL e PL/SQL, mas não para áreas compartilhadas de
SQL e PL/SQL.
Ø COMPOSITE_LIMIT: especifica o custo total de recurso para uma sessão, expressado em unidades de serviço.
Oracle Database calcula as unidades totais de serviço como uma soma ponderada de CPU_PER_SESSION,
CONNECT_TIME, LOGICAL_READS_PER_SESSION e PRIVATE_SGA.*/


-- Criando usuário comum para o root e todos os pdbs
CREATE USER C##matheusadmin IDENTIFIED BY oracle CONTAINER=ALL;

-- COMMON  GRANT
GRANT CREATE SESSION TO C##matheusadmin CONTAINER=ALL;

-- CRIANDO PROFILE
CREATE PROFILE c##prof LIMIT
SESSIONS_PER_USER UNLIMITED
CPU_PER_SESSION UNLIMITED
CPU_PER_CALL 3000
CONNECT_TIME 45
LOGICAL_READS_PER_SESSION DEFAULT
LOGICAL_READS_PER_CALL 1000
PRIVATE_SGA 15K
COMPOSITE_LIMIT 5000000
FAILED_LOGIN_ATTEMPTS 1
CONTAINER=ALL;

-- Atribuindo um profile para um usuário
ALTER USER c##matheusadmin PROFILE c##prof CONTAINER=ALL;

-- Verificando se o usuário possui um profile//SEMPRE EM MAIUSCULO O NOME DO USUÁRIO
SELECT PROFILE FROM DBA_USERS WHERE USERNAME='C##MATHEUSADMIN';


