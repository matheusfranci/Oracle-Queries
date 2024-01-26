-- Adicionando ip, host com domínio e hostname no arquivo abaixo
vim /etc/hosts
[root@ASMLAB /]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.11    ASMLAB.localdomain      ASMLAB

-- Adicionar o ip e alterar BOOTPROTO para static
vim /etc/sysconfig/network-scripts/ifcfg-enp0s3
BOOTPROTO="static"
IPADDR=192.xxx.x.xx

-- Desabilitar o selinux
vim /etc/selinux/config
SELINUX=disable

-- Editar a configuração do SSH:
vi /etc/ssh/ssh_config
X11Forwarding yes
X11UseLocalhost no
TCPKeepAlive yes

-- Reiniciando o arquivo recentemente alterado para subir as alterações
systemctl restart sshd


-- Parar e desabilitar o firewall
systemctl stop firewalld
systemctl disable firewalld

-- instalação dos pacotes de Sistema Operacional Pré-requisitos das instalações
yum update -y
yum install -y oracle-database-preinstall-19c.x86_64
yum install oracleasm-support -y
yum install bind* -y
sysctl -p -- Execute esse apenas se o bind for instalado sem problemas, se não execute o procedimento abaixo

-- Problema de instalação do bind* resolvido assim:
yum --enablerepo=ol7_optional_latest install bind-devel
yum --enablerepo=ol7_optional_latest install bind-export-devel
yum --enablerepo=ol7_optional_latest install bind-export-devel-32:9.11.4-16.P2.el7_8.3.x86_64
sysctl -p

-- Adição dos grupos
groupadd -g 54327 asmdba
groupadd -g 54328 asmoper
groupadd -g 54329 asmadmin

-- Adição dos usuários
useradd -m -u 54341 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash grid
usermod -G asmdba,asmoper,asmadmin oracle

-- Alteração das senhas dos usuários oracle e grid
# passwd oracle
# passwd grid

-- Criação e permissionamento nos diretórios criados
mkdir -p /u01/app/19.0.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle/product/19.0.0/db_1
chown -R grid:oinstall /u01/app
chown oracle:oinstall -R /u01/app/oracle
chmod -R 775 /u01/

-- Configuração dos bash profiles
-- Usuário oracle
# vi /home/oracle/.bash_profile
# Oracle Settings
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_BASE=/u01/app/oracle
export GRID_HOME=/u01/app/19.0.0/grid
export DB_HOME=$ORACLE_BASE/product/19.0.0/db_1
export ORACLE_HOME=$DB_HOME
export ORACLE_SID=orcl
export ORACLE_TERM=xterm
export BASE_PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$BASE_PATH:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

-- Usuário GRID
vi /home/grid/.bash_profile
export ORACLE_SID=+ASM
export GRID_HOME=/u01/app/19.0.0/grid
export ORACLE_HOME=$GRID_HOME
export PATH=$ORACLE_HOME/bin:$BASE_PATH:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

-- Listando os discos anexados a vm no oracle virtual box
fdisk -l

-- Listando apenas os discos anexados para esse fim
fdisk -l /dev/sdf /dev/sdg /dev/sdb /dev/sdc /dev/sde /dev/sdh /dev/sdd 

-- Formando o disco, exemplo:
[root@ASMLAB ~]# fdisk /dev/sdf
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0xe8bcc2ca.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039):
Using default value 41943039
Partition 1 of type Linux and of size 20 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

-- Sequência é n, p, 1, enter duas vezes e w por último
fdisk /dev/sdg 
fdisk /dev/sdb 
fdisk /dev/sdc 
fdisk /dev/sde 
fdisk /dev/sdh 
fdisk /dev/sdd 

-- Configurando o asm
/usr/sbin/oracleasm configure -i

-- Respostas
grid
asmadmin
y
y

-- Verificando as configurações
/usr/sbin/oracleasm configure

-- Iniciando
/usr/sbin/oracleasm init
systemctl enable oracleasm

-- Criando os discos do ASM
oracleasm createdisk ASM1 /dev/sdf1
oracleasm createdisk ASM2 /dev/sdg1
oracleasm createdisk ASM3 /dev/sdb1
oracleasm createdisk ASM4 /dev/sdc1
oracleasm createdisk ASM5 /dev/sde1
oracleasm createdisk ASM6 /dev/sdh1
oracleasm createdisk ASM7 /dev/sdd1

-- Verificando os discos montados
oracleasm listdisks

-- Iniciando a instalação do grid
mv /home/matheus/LINUX.X64_193000_grid_home.zip /u01/app/19.0.0/grid

-- Permissão para o grid executar
chown grid:oinstall /u01/app/19.0.0/grid/LINUX.X64_193000_grid_home.zip

-- Autenticando o grid
sudo su - grid

-- Acessando a pasta onde está o instalador
cd /u01/app/19.0.0/grid

-- Descompactando o pacote com o instalador
unzip LINUX.X64_193000_grid_home.zip

-- Removendo a pasta
rm LINUX.X64_193000_grid_home.zip

-- Chamando a tela interativa
./gridSetup.sh

-- Verificando status do asm no usuário grid
srvctl status asm

-- Verificando 
sqlplus / as sysasm
set lines 9999
set pages 9999
COLUMN HEADER_STATUS FORMAT A20
COLUMN NAME FORMAT A30
COLUMN PATH FORMAT A50
COLUMN MOUNT_STATUS FORMAT A15
COLUMN STATE FORMAT A15
SELECT HEADER_STATUS, NAME, PATH, MOUNT_STATUS, STATE, HEADER_STATUS, TOTAL_MB
FROM V$ASM_DISK;

-- Criando novos disks groups com base nas recomendações abaixo:
https://infohub.delltechnologies.com/l/design-guide-modernize-your-oracle-database-server-platform-and-accelerate-deployments-1/storage-best-practices-2/

-- Criação dos Disk Groups
CREATE DISKGROUP TEMP EXTERNAL REDUNDANCY disk '/dev/oracleasm/disks/ASM2' NAME TEMP_0001;
CREATE DISKGROUP REDO EXTERNAL REDUNDANCY disk '/dev/oracleasm/disks/ASM6' NAME REDO_0001;
CREATE DISKGROUP FRA EXTERNAL REDUNDANCY disk '/dev/oracleasm/disks/ASM5' NAME FRA_0001;
CREATE DISKGROUP FRA EXTERNAL REDUNDANCY disk '/dev/oracleasm/disks/ASM7' NAME FRA_0002;

-- Adicionando mais 1 no FRA
ALTER DISKGROUP FRA ADD DISK '//dev/oracleasm/disks/ASM7' NAME FRA_0002;
