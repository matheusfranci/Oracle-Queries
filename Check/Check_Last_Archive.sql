select inst_id, max(fhrba_Seq) LAST_ARCH from sys.x$kcvfh
group by inst_id order by 1;
