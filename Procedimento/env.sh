
## By DBA 09/02/23
#export  PS1='\[\e[0;31m\](\h)\e[36;1m(\u@\e[0;31m${ORACLE_SID}\[\e[36;1m\]):\W>\[\e[0m\] '
#export PS1='[\h:\u@${ORACLE_SID} \W]$ '
export NLS_LANG="AMERICAN_AMERICA.WE8MSWIN1252"
export CLI=AZRM
export PS1='${CLI}-\e[0;36m(\h)(\u@\e[0;31m${ORACLE_SID}\e[0;36m):\W>\e[0;0m '
export NLS_DATE_FORMAT='dd-mm-yyyy hh24:mi:ss'
export EDITOR=vi
export DISPLAY=10.0.0.10:0.0
export CV_ASSUME_DISTID='OL7'
alias sql="sqlplus '/ as sysdba'"
alias oh="cd ${ORACLE_HOME}"
alias dbs="cd ${ORACLE_HOME}/dbs"
alias dba="cd ~/scripts/dba"
alias tns="cd ${ORACLE_HOME}/network/admin"

alias RM="export ORACLE_SID=RM;export ORACLE_HOME=/app/oracle/product/19.3.0/dbhome_1;alias sql=\"sqlplus / as sysdba\""
alias m="echo \"
Menu de atalhos <m>:

              RM = RM /app/oracle/product/19.3.0/dbhome_1

              sql = sqlplus '/ as sysdba'
\"
"

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:${ORACLE_HOME}/bin:${ORACLE_HOME}/OPatch
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
#export TNS_ADMIN=${ORACLE_HOME}/network/admin

# Executa alias <m>
# Executa alias <m>

m

-- para entrar basta digitar de dentro da basta do arquivo o . env.sh
