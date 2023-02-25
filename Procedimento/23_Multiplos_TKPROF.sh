-- Execução sh tkp.sh na pasta onde encontra-se

echo -e "\nInforme o diretório de traces: \c "
read dirtrc
echo -e "\nInforme parte do nome dos traces: \c "
read nametrc

cd $dirtrc

echo
echo Lista de traces:
ls *$nametrc*.trc
ls *$nametrc*.trc > /tmp/tkptrc.lst
echo

echo "Trace gerado em:" > /tmp/tkplst.lst
for trc in `cat /tmp/tkptrc.lst`
do
   type="`head -1 $trc | grep "Trace file"`"
   if [ "$type" = "" ]; then
      echo
          echo $trc nao é um arquivo de trace
          echo
   else
      trace=`echo $trc | cut -d"." -f1`
      echo tkprof ${trace}.trc ${trace}.txt table=sys.plan_table sys=no sort=fchela,execpu,fchcpu
           tkprof ${trace}.trc ${trace}.txt table=sys.plan_table sys=no sort=fchela,execpu,fchcpu > /dev/null
      echo "   $dirtrc/${trace}.txt" >> /tmp/tkplst.lst
   fi
done
echo
cat /tmp/tkplst.lst
echo
