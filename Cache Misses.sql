select



to_char(snap_time,'yyyy-mm-dd HH24') mydate,



sum(new.pins-old.pins) ,



sum(new.reloads-old.reloads) ,



sum(new.reloads-old.reloads)/



sum(new.pins-old.pins) library_cache_miss_ratio



from



stats$librarycache old,



stats$librarycache new,



stats$snapshot sn



where



new.snap_id = sn.snap_id



and



old.snap_id = new.snap_id-



(select distinct (



(select max(snap_id) from stats$snapshot , v$database) -



(select max(snap_id) from stats$snapshot, v$database WHERE snap_id <



(select max(snap_id) from stats$snapshot, v$database ))) as "Diferença entre snap_shots"



from stats$snapshot , v$database)



and



old.namespace = new.namespace



group by



to_char(snap_time,'yyyy-mm-dd HH24')



order by mydate ;