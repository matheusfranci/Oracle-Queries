select to_char(creation_time, 'RRRR Month') "Month",

    sum(bytes)/1024/1024/1024 "Growth in GBs"

    from sys.v_$datafile

    where creation_time > SYSDATE-365

    group by to_char(creation_time, 'RRRR Month'), 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ;