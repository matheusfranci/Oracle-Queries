/etc/rc.d/init.d/dbora

#! /bin/sh
#chkconfig: 345 99 10
# description: Oracle auto start-stop script.
#
# Set ORA_HOME to be equivalent to the $ORACLE_HOME
# from which you wish to execute dbstart and dbshut;
#
# Set ORA_OWNER to the user id of the owner of the
# Oracle database in ORACLE_HOME.

ORATAB=/etc/oratab
ORA_HOME=/u01/app/oracle/product/11.2.0.4/db_1
ORA_OWNER=oracle
export ORACLE_SID=rmhml

case "$1" in

      start)
            # Inicia o banco de dados Oracle:
            echo -n "Iniciando o oracle: "
            # Iniciando o LISTENER
            su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl start"
            sleep 2s
            # Iniciando o banco
            su - $ORA_OWNER -c $ORA_HOME/bin/dbstart
            # Iniciando o EM
            su - $ORA_OWNER -c "$ORA_HOME/bin/emctl start dbconsole"
            touch /var/lock/subsys/oracle
      ;;

      stop)
            # Para o banco de dados Oracle:
            echo -n "Parando o oracle: "
            # Parando o EM
            su - $ORA_OWNER -c "$ORA_HOME/bin/emctl stop dbconsole"
            # Parando o LISTENER
            su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl stop"
            # Parando o banco
            su - $ORA_OWNER -c $ORA_HOME/bin/dbshut
            rm -f /var/lock/subsys/oracle
            echo
      ;;
      
      
      restart)
                # Reiniciando o banco de dados Oracle:
                echo -n "Reiniciando o oracle: "
                $0 stop
                sleep 5s
                $0 start
                echo
      ;;

      status)
                cat $ORATAB | while read LINE
                do
                    case $LINE in
                        \#*)                ;;        #comment-line in oratab
                        *)
                #       Proceed only if last field is 'Y'.
                #       Entries whose last field is not Y or N are not DB entry, ignore them.
                        if [ "`echo $LINE | awk -F: '{print $NF}' -`" = "Y" ] ; then
                            ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
                            if [ "$ORACLE_SID" != '*' ] ; then
                                status "ora_pmon_$ORACLE_SID"
                            fi
                        fi
                        ;;
                    esac
                done
      ;;

      *)
                echo "Usage: oracle { start | stop | restart |status}"
                exit 1
      ;;

esac

