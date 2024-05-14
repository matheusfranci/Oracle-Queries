----------------Ferramentas de monitoria do servidor-----------------------
-- Instalando o HTOP
yum install htop

-- Instalando o gtop
yum install nodejs
yum install npm
npm install -g gtop

-----------------Instalação do oracle database de fato---------------------
-- Instalando os requisitos do oracle database
yum install oracle-database-preinstall-19c

-- Adicionando ip, host com domínio e hostname no arquivo abaixo
vim /etc/hosts

-- Adicionar o ip e alterar BOOTPROTO para static
vim /etc/sysconfig/network-scripts/ifcfg-enp0s3
BOOTPROTO="static"
IPADDR=192.xxx.x.xx

-- configurar senha usuario oracle
passwd oracle
Insira a senha

-- Desabilitar o selinux
vim /etc/selinux/config
SELINUX=disable

Editar a configuração do SSH:
# vi /etc/ssh/ssh_config
X11Forwarding yes
X11UseLocalhost no
TCPKeepAlive yes

systemctl restart sshd


-- Parar e desabilitar o firewall
systemctl stop firewalld
systemctl disable firewalld

-- Criar o ORACLE_HOME e ORACLE_BASE 
mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1
mkdir -p /u02/oradata

-- Conceder permissão ao grupo oracle e ao usuário
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02

-- Entrar diretamento com o usuário oracle no MobaXterm, caso contrário não funcionará
-- Declaração das variáveis e entrada no diretório de descompactação do arquivo zippado
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
cd /u01/app/oracle/product/19.0.0/dbhome_1
unzip -oq /home/oracle/LINUX.X64_193000_db_home.zip

-- Instalaçao em silent mode
mkdir /home/oracle/scripts

cat > /home/oracle/scripts/setEnv.sh <<EOF
# Oracle Settings
export TMP=/tmp
export TMPDIR=\$TMP

export ORACLE_HOSTNAME=ol8-19.localdomain
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/19.0.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=cdb1
export PDB_NAME=pdb1
export DATA_DIR=/u02/oradata

export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=\$ORACLE_HOME/bin:\$PATH

export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
EOF

echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

cat > /home/oracle/scripts/start_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbstart \$ORACLE_HOME
EOF


cat > /home/oracle/scripts/stop_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbshut \$ORACLE_HOME
EOF

chown -R oracle:oinstall /home/oracle/scripts
chmod u+x /home/oracle/scripts/*.sh

# Silent mode.
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME}                                         \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=${ORA_INVENTORY}                                        \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=EE                                        \
    oracle.install.db.OSDBA_GROUP=dba                                          \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
    oracle.install.db.OSDGDBA_GROUP=dba                                        \
    oracle.install.db.OSKMDBA_GROUP=dba                                        \
    oracle.install.db.OSRACDBA_GROUP=dba                                       \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true
