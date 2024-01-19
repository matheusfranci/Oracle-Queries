COLUMN day FORMAT A12
COLUMN "00" FORMAT 999
COLUMN "01" FORMAT 999
COLUMN "02" FORMAT 999
COLUMN "03" FORMAT 999
COLUMN "04" FORMAT 999
COLUMN "05" FORMAT 999
COLUMN "06" FORMAT 999
COLUMN "07" FORMAT 999
COLUMN "08" FORMAT 999
COLUMN "09" FORMAT 999
COLUMN "10" FORMAT 999
COLUMN "11" FORMAT 999
COLUMN "12" FORMAT 999
COLUMN "13" FORMAT 999
COLUMN "14" FORMAT 999
COLUMN "15" FORMAT 999
COLUMN "16" FORMAT 999
COLUMN "17" FORMAT 999
COLUMN "18" FORMAT 999
COLUMN "19" FORMAT 999
COLUMN "20" FORMAT 999
COLUMN "21" FORMAT 999
COLUMN "22" FORMAT 999
COLUMN "23" FORMAT 999
SELECT TO_CHAR(first_time, 'YYYY-MM-DD') AS day,
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '00', 1, 0)), '999') AS "00",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '01', 1, 0)), '999') AS "01",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '02', 1, 0)), '999') AS "02",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '03', 1, 0)), '999') AS "03",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '04', 1, 0)), '999') AS "04",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '05', 1, 0)), '999') AS "05",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '06', 1, 0)), '999') AS "06",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '07', 1, 0)), '999') AS "07",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '08', 1, 0)), '999') AS "08",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '09', 1, 0)), '999') AS "09",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '10', 1, 0)), '999') AS "10",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '11', 1, 0)), '999') AS "11",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '12', 1, 0)), '999') AS "12",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '13', 1, 0)), '999') AS "13",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '14', 1, 0)), '999') AS "14",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '15', 1, 0)), '999') AS "15",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '16', 1, 0)), '999') AS "16",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '17', 1, 0)), '999') AS "17",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '18', 1, 0)), '999') AS "18",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '19', 1, 0)), '999') AS "19",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '20', 1, 0)), '999') AS "20",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '21', 1, 0)), '999') AS "21",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '22', 1, 0)), '999') AS "22",
       TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'HH24'), 1, 2), '23', 1, 0)), '999') AS "23"
FROM v$log_history
WHERE first_time >= SYSDATE - INTERVAL '10' DAY
GROUP BY TO_CHAR(first_time, 'YYYY-MM-DD')
ORDER BY day DESC;
