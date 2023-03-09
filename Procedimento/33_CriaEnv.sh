#---------------------
# Cria env.sh
#---------------------

export CLI=NOTSET

cat > env.sh <<EOF

## By DBA `date +'%d/%m/%y'`
#export  PS1='\[\e[0;31m\](\h)\e[36;1m(\u@\e[0;31m\${ORACLE_SID}\[\e[36;1m\]):\W>\[\e[0m\] '
#export PS1='[\h:\u@\${ORACLE_SID} \W]\$ '
#export NLS_LANG="AMERICAN_AMERICA.WE8MSWIN1252"
export CLI=$nomedocliente
export PS1='\${CLI}-\e[0;36m(\h)(\u@\e[0;31m\${ORACLE_SID}\e[0;36m):\W>\e[0;0m '
export NLS_DATE_format='dd-mm-yyyy hh24:mi:ss'
export EDITOR=vi
alias sql="rlwrap sqlplus '/ as sysdba'"
alias oh="cd \${ORACLE_HOME}"
alias dbs="cd \${ORACLE_HOME}/dbs"
alias dba="cd ~/scripts/dba"
alias tns="cd \${ORACLE_HOME}/network/admin"
EOF

#---------------------
# Cria ATALHOS no BASH_PROFILE para setar SID
#---------------------

echo >> env.sh
for sid in `ps -ef | grep _smon_ | grep ^$USER | grep -v grep | sed 's/_/ /g' | awk '{print \$NF}'`
do
   asid=`echo $sid | cut -c1-3 | tr '[:upper:]' '[:lower:]'`
   echo "alias $asid=\"export ORACLE_SID=$sid;export ORACLE_HOME=$ORACLE_HOME;alias sql=\\\"sqlplus / as sysdba\\\"\"" >> env.sh
done

# Cria alias Menu <m>
cat >> env.sh<<EOF
alias m="echo \\"
Menu de atalhos <m>:

`for sid in \`ps -ef | grep _smon_ | grep ^\$USER | grep -v grep | sed 's/_/ /g' | awk '{print \$NF}'\`
do
   echo "              \`echo \$sid | tr '[:upper:]' '[:lower:]' | cut -c1-3\` = \$sid $ORACLE_HOME"
done`

              sql = sqlplus '/ as sysdba'
\\"
"

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:\${ORACLE_HOME}/bin:\${ORACLE_HOME}/OPatch
export LD_LIBRARY_PATH=\${ORACLE_HOME}/lib
#export TNS_ADMIN=\${ORACLE_HOME}/network/admin

EOF
echo "# Executa alias <m>" >> env.sh
echo >> env.sh 
echo m >> env.sh
