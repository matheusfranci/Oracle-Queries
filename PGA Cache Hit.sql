SELECT

ROUND(pga_target_for_estimate /(1024*1024))pga_target_for_estimate ,

estd_pga_cache_hit_percentage ,

estd_overalloc_count 

FROM

v$pga_target_advice;