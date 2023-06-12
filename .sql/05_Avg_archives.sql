alter session set NLS_DATE_FORMAT='dd-mm-yy';
set pages 999
set linesize 200
set trimspool on
set feedback off


clear columns
Column SOMA format 9999 justify right
Column "MED/HOR" format 9999 justify right
Column "00h" format 999 justify right
Column "01h" format 999 justify right
Column "02h" format 999 justify right
Column "03h" format 999 justify right
Column "04h" format 999 justify right
Column "05h" format 999 justify right
Column "06h" format 999 justify right
Column "07h" format 999 justify right
Column "08h" format 999 justify right
Column "09h" format 999 justify right
Column "10h" format 999 justify right
Column "11h" format 999 justify right
Column "12h" format 999 justify right
Column "13h" format 999 justify right
Column "14h" format 999 justify right
Column "15h" format 999 justify right
Column "16h" format 999 justify right
Column "17h" format 999 justify right
Column "18h" format 999 justify right
Column "19h" format 999 justify right
Column "20h" format 999 justify right
Column "21h" format 999 justify right
Column "22h" format 999 justify right
Column "23h" format 999 justify right

clear breaks
clear computes
--break on trunc(first_time)  on report
break on report skip 2
compute avg label "MEDIAS"  of "SOMA" on report
break on report skip 2
compute avg of "MED/HOR" on report

PROMPT 'MEDIA DE GERACAO DE ARCHIVES POR DIA/HORA'
PROMPT
select trunc(first_time) AS "DATA",
sum(1) AS "SOMA",
sum(1)/24 AS "MED/HOR",
sum(DECODE(to_char(first_time, 'HH24'), '00', 1, 0)) AS "00h",
sum(DECODE(to_char(first_time, 'HH24'), '01', 1, 0)) AS "01h",
sum(DECODE(to_char(first_time, 'HH24'), '02', 1, 0)) AS "02h",
sum(DECODE(to_char(first_time, 'HH24'), '03', 1, 0)) AS "03h",
sum(DECODE(to_char(first_time, 'HH24'), '04', 1, 0)) AS "04h",
sum(DECODE(to_char(first_time, 'HH24'), '05', 1, 0)) AS "05h",
sum(DECODE(to_char(first_time, 'HH24'), '06', 1, 0)) AS "06h",
sum(DECODE(to_char(first_time, 'HH24'), '07', 1, 0)) AS "07h",
sum(DECODE(to_char(first_time, 'HH24'), '08', 1, 0)) AS "08h",
sum(DECODE(to_char(first_time, 'HH24'), '09', 1, 0)) AS "09h",
sum(DECODE(to_char(first_time, 'HH24'), '10', 1, 0)) AS "10h",
sum(DECODE(to_char(first_time, 'HH24'), '11', 1, 0)) AS "11h",
sum(DECODE(to_char(first_time, 'HH24'), '12', 1, 0)) AS "12h",
sum(DECODE(to_char(first_time, 'HH24'), '13', 1, 0)) AS "13h",
sum(DECODE(to_char(first_time, 'HH24'), '14', 1, 0)) AS "14h",
sum(DECODE(to_char(first_time, 'HH24'), '15', 1, 0)) AS "15h",
sum(DECODE(to_char(first_time, 'HH24'), '16', 1, 0)) AS "16h",
sum(DECODE(to_char(first_time, 'HH24'), '17', 1, 0)) AS "17h",
sum(DECODE(to_char(first_time, 'HH24'), '18', 1, 0)) AS "18h",
sum(DECODE(to_char(first_time, 'HH24'), '19', 1, 0)) AS "19h",
sum(DECODE(to_char(first_time, 'HH24'), '20', 1, 0)) AS "20h",
sum(DECODE(to_char(first_time, 'HH24'), '21', 1, 0)) AS "21h",
sum(DECODE(to_char(first_time, 'HH24'), '22', 1, 0)) AS "22h",
sum(DECODE(to_char(first_time, 'HH24'), '23', 1, 0)) AS "23h"
FROM v$log_history
GROUP BY trunc(first_time)
ORDER BY 1
/
