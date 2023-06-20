-- The total rows count of the table: 21310 row //-

SELECT COUNT(*) FROM `data-analysis-practice-314303.getaround.getaround` 

SELECT rental_id, car_id, checkin_type,state, delay_at_checkout_in_minutes,
    previous_ended_rental_id, 
    time_delta_with_previous_rental_in_minutes 
FROM `data-analysis-practice-314303.getaround.getaround` 
LIMIT 1000

-- Shared Cars Id count
WITH car_id_count AS (
    SELECT car_id, COUNT(*) AS total
        FROM `data-analysis-practice-314303.getaround.getaround` 
        GROUP BY car_id
        ORDER BY total DESC
) 
SELECT * FROM car_id_count
WHERE total > 1


WITH main_table AS (
    SELECT rental_id, car_id, checkin_type, state, delay_at_checkout_in_minutes,
    previous_ended_rental_id, time_delta_with_previous_rental_in_minutes 
    FROM `data-analysis-practice-314303.getaround.getaround` 
)
SELECT * FROM main_table
WHERE delay_at_checkout_in_minutes IS NOT NULL
AND delay_at_checkout_in_minutes > 10
AND time_delta_with_previous_rental_in_minutes IS NOT NULL

-- State canceld(3265), ended (18045)
SELECT state, COUNT(*) AS total
FROM `data-analysis-practice-314303.getaround.getaround` 
GROUP BY state

-- Checkin type: mobile(17003), connect(4307)
SELECT checkin_type, COUNT(*) AS checkin_type_total
FROM `data-analysis-practice-314303.getaround.getaround` 
GROUP BY checkin_type

SELECT rental_id, car_id,checkin_type, state, delay_at_checkout_in_minutes,
previous_ended_rental_id, time_delta_with_previous_rental_in_minutes,
time_delta_with_previous_rental_in_minutes/60 AS rental_in_hours
FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE time_delta_with_previous_rental_in_minutes IS NOT NULL
ORDER BY time_delta_with_previous_rental_in_minutes DESC

-- rental time above 12 hours: 19469
SELECT COUNT(*) AS rental_time_above_12hours

FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE time_delta_with_previous_rental_in_minutes IS NULL

-- rental time total: 21310
SELECT 
COUNT (*) AS total_rental
FROM `data-analysis-practice-314303.getaround.getaround` 


-- mobile checkin distribution: avg(224.14, if min > 0  or 86.68 ), max(71084), min(-22433 or 0) --> the min delay reveals in negative value.. what is this supposed to mean?
SELECT 
ROUND(AVG(delay_at_checkout_in_minutes), 2) AS avg_dealy,
MAX(delay_at_checkout_in_minutes) AS max_dealy,
MIN(delay_at_checkout_in_minutes) AS min_dealy
FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE checkin_type = 'mobile'
AND delay_at_checkout_in_minutes IS NOT NULL 

-- Connect checkin distribution: avg(78.76 if min >= 0, or -43.63 ), max(1466), min(-4276 or 0) --> the min delay reveals in negative value.. what is this supposed to mean?
SELECT 
ROUND(AVG(delay_at_checkout_in_minutes), 2) AS avg_dealy,
MAX(delay_at_checkout_in_minutes) AS max_dealy,
MIN(delay_at_checkout_in_minutes) AS min_dealy
FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE checkin_type = 'connect'
AND delay_at_checkout_in_minutes IS NOT NULL
AND  delay_at_checkout_in_minutes >= 0

-- 'Connect'reveals the shorter dealy as a 78.76 mins wherease 'mobile' as 224.14 mins.
-- This is becase probably the connect user are likely to need car nearby their location and shorter-distance.
-- On the contrary, 'Mobile' user is likely to use car for the longer distance. And the estimate of the time for return are might be wrong more frequetly due to various reasons. 

--What about the ones who rented a car in previous?
-- total count of preveous rental (1841)
SELECT  COUNT(*) previous_rental_total
FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE previous_ended_rental_id IS NOT NULL

SELECT * FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE previous_ended_rental_id IS NOT NULL


SELECT car_id, checkin_type, COUNT(car_id) AS total
FROM `data-analysis-practice-314303.getaround.getaround` 
GROUP BY car_id, checkin_type
ORDER BY total DESC

WITH previous_rental AS (
    SELECT * FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE previous_ended_rental_id IS NOT NULL
),
main AS(
    SELECT *
    FROM `data-analysis-practice-314303.getaround.getaround` 
)
SELECT *
FROM main
WHERE rental_id = 537298

WITH car_total AS (
    SELECT car_id, COUNT(*) AS total
    FROM `data-analysis-practice-314303.getaround.getaround` 
    GROUP BY car_id
    ORDER BY total DESC
)
SELECT *
FROM car_total
WHERE total >1


WITH table_one AS (
    SELECT previous_ended_rental_id AS rental_id, 
    time_delta_with_previous_rental_in_minutes
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE previous_ended_rental_id IS NOT NULL
    ORDER BY previous_ended_rental_id
),
table_two AS (
    SELECT rental_id, car_id,checkin_type,state, 
    delay_at_checkout_in_minutes,previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE rental_id IN
    (
    SELECT previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround`
    )
    ORDER BY rental_id
),
table_join AS (
    SELECT table_two.rental_id, table_two.car_id, table_two.checkin_type,table_two.state, 
    table_two.delay_at_checkout_in_minutes,table_one.time_delta_with_previous_rental_in_minutes,
    (table_one.time_delta_with_previous_rental_in_minutes-table_two.delay_at_checkout_in_minutes) AS time_delta_minus_delay
    FROM table_two
    RIGHT JOIN table_one ON table_two.rental_id = table_one.rental_id
),
blacklist AS (
    SELECT *
    FROM table_join
    WHERE time_delta_minus_delay < 0
),
blacklist_a AS (
    SELECT rental_id,car_id, checkin_type, state, ABS(time_delta_minus_delay) AS abs_time_delta_minus_delay
    FROM blacklist
    ORDER BY abs_time_delta_minus_delay DESC    
)
SELECT *
FROM blacklist_a

SELECT ROUND(AVG(abs_time_delta_minus_delay) ,2) AS Average
FROM blacklist_a
WHERE checkin_type = 'mobile'
SELECT
ROUND(AVG(abs_time_delta_minus_delay) ,2) AS Average
FROM blacklist_a
WHERE checkin_type = 'connect'


--********THIS IS THE CASE THAT CAUSE THE TIME FRICTION!!!!********
-- THIS 218 CARS ARE THE CAUSE OF THE PROBLEM...!!

WITH table_one AS (
    SELECT previous_ended_rental_id AS rental_id, 
    time_delta_with_previous_rental_in_minutes
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE previous_ended_rental_id IS NOT NULL
    ORDER BY previous_ended_rental_id
),
table_two AS (
    SELECT rental_id, 
    car_id,
    checkin_type, 
    state, 
    delay_at_checkout_in_minutes,
    previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE rental_id IN
    (
    SELECT previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround`
    )
    ORDER BY rental_id
),
table_join AS (
    SELECT table_two.rental_id, 
    table_two.car_id, 
    table_two.checkin_type,table_two.state, 
    table_two.delay_at_checkout_in_minutes,
    table_one.time_delta_with_previous_rental_in_minutes,
    (table_one.time_delta_with_previous_rental_in_minutes-table_two.delay_at_checkout_in_minutes) AS time_delta_minus_delay
    FROM table_two
    RIGHT JOIN table_one ON table_two.rental_id = table_one.rental_id
),
blacklist AS (
    SELECT *
    FROM table_join
    WHERE time_delta_minus_delay < 0
),
blacklist_a AS (
    SELECT rental_id,car_id, checkin_type, state, ABS(time_delta_minus_delay) AS abs_time_delta_minus_delay
    FROM blacklist
    ORDER BY abs_time_delta_minus_delay DESC    
)
SELECT
    CASE
        WHEN abs_time_delta_minus_delay >= 1 AND abs_time_delta_minus_delay <=10 THEN '1m-10m'
        WHEN abs_time_delta_minus_delay >= 11 AND abs_time_delta_minus_delay <=20 THEN '11m-20m'
        WHEN abs_time_delta_minus_delay >= 21 AND abs_time_delta_minus_delay <=30 THEN '21m-30m'
        WHEN abs_time_delta_minus_delay >= 31 AND abs_time_delta_minus_delay <=40 THEN '31m-40m'
        WHEN abs_time_delta_minus_delay >= 41 AND abs_time_delta_minus_delay <=50 THEN '41m-50m'
        WHEN abs_time_delta_minus_delay >= 51 AND abs_time_delta_minus_delay <=60 THEN '51m-60m'
        WHEN abs_time_delta_minus_delay >= 61 AND abs_time_delta_minus_delay <=120 THEN '60m-120m'
        WHEN abs_time_delta_minus_delay >= 121 AND abs_time_delta_minus_delay <=180 THEN '2h-3h'
        WHEN abs_time_delta_minus_delay >= 181 AND abs_time_delta_minus_delay <=240 THEN '3h-4h'
        WHEN abs_time_delta_minus_delay >= 241 AND abs_time_delta_minus_delay <=300 THEN '4h-5h'
        WHEN abs_time_delta_minus_delay >= 301 AND abs_time_delta_minus_delay <=360 THEN '5h-6h'
        WHEN abs_time_delta_minus_delay >= 361 AND abs_time_delta_minus_delay <=420 THEN '6h-7h'
        WHEN abs_time_delta_minus_delay >= 421 AND abs_time_delta_minus_delay <=480 THEN '7h-8h'
        WHEN abs_time_delta_minus_delay >= 481 AND abs_time_delta_minus_delay <=540 THEN '8h-9h'
        WHEN abs_time_delta_minus_delay >= 541 AND abs_time_delta_minus_delay <=600 THEN '9h-10h'
        WHEN abs_time_delta_minus_delay >= 601 AND abs_time_delta_minus_delay <=660 THEN '10h-11h'
        WHEN abs_time_delta_minus_delay >= 661 AND abs_time_delta_minus_delay <=720 THEN '11h-12h'
        ELSE 'above 12h'
        END AS delay_time_mark,
        COUNT(*) AS total
FROM blacklist_a
GROUP BY delay_time_mark
ORDER BY total DESC



-- *****Delay time mark *****

WITH table_one AS (
    SELECT previous_ended_rental_id AS rental_id, 
    time_delta_with_previous_rental_in_minutes
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE previous_ended_rental_id IS NOT NULL
    ORDER BY previous_ended_rental_id
),
table_two AS (
    SELECT rental_id, 
    car_id,
    checkin_type, 
    state, 
    delay_at_checkout_in_minutes,
    previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE rental_id IN
    (
    SELECT previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround`
    )
    ORDER BY rental_id
),
table_join AS (
    SELECT table_two.rental_id, 
    table_two.car_id, 
    table_two.checkin_type,table_two.state, 
    table_two.delay_at_checkout_in_minutes,
    table_one.time_delta_with_previous_rental_in_minutes,
    (table_one.time_delta_with_previous_rental_in_minutes-table_two.delay_at_checkout_in_minutes) AS time_delta_minus_delay
    FROM table_two
    RIGHT JOIN table_one ON table_two.rental_id = table_one.rental_id
),
blacklist AS (
    SELECT *
    FROM table_join
    WHERE time_delta_minus_delay < 0
),
blacklist_a AS (
    SELECT rental_id,car_id, checkin_type, state, ABS(time_delta_minus_delay) AS abs_time_delta_minus_delay
    FROM blacklist
    ORDER BY abs_time_delta_minus_delay DESC    
)
SELECT
    CASE
        WHEN abs_time_delta_minus_delay >= 1 AND abs_time_delta_minus_delay <=60 THEN '0-1h'
        WHEN abs_time_delta_minus_delay >= 61 AND abs_time_delta_minus_delay <=120 THEN '1h-2h'
        WHEN abs_time_delta_minus_delay >= 121 AND abs_time_delta_minus_delay <=180 THEN '2h-3h'
        WHEN abs_time_delta_minus_delay >= 181 AND abs_time_delta_minus_delay <=240 THEN '3h-4h'
        WHEN abs_time_delta_minus_delay >= 241 AND abs_time_delta_minus_delay <=300 THEN '4h-5h'
        WHEN abs_time_delta_minus_delay >= 301 AND abs_time_delta_minus_delay <=360 THEN '5h-6h'
        WHEN abs_time_delta_minus_delay >= 361 AND abs_time_delta_minus_delay <=420 THEN '6h-7h'
        WHEN abs_time_delta_minus_delay >= 421 AND abs_time_delta_minus_delay <=480 THEN '7h-8h'
        WHEN abs_time_delta_minus_delay >= 481 AND abs_time_delta_minus_delay <=540 THEN '8h-9h'
        WHEN abs_time_delta_minus_delay >= 541 AND abs_time_delta_minus_delay <=600 THEN '9h-10h'
        WHEN abs_time_delta_minus_delay >= 601 AND abs_time_delta_minus_delay <=660 THEN '10h-11h'
        WHEN abs_time_delta_minus_delay >= 661 AND abs_time_delta_minus_delay <=720 THEN '11h-12h'
        ELSE 'Over 12h'
        END AS delay_time_mark,
        COUNT(*) AS total
FROM blacklist_a
GROUP BY delay_time_mark
ORDER BY delay_time_mark ASC



SELECT rental_id, car_id, checkin_type, state, delay_at_checkout_in_minutes, previous_ended_rental_id 
FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE rental_id IN (
SELECT previous_ended_rental_id 
FROM `data-analysis-practice-314303.getaround.getaround`
) 
ORDER BY rental_id


SELECT * FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE state = 'canceled'
AND previous_ended_rental_id IS NOT NULL
ORDER BY previous_ended_rental_id DESC



---** the previous rental which is canceled by the next driver ** --
-- 37 out of 218 (the total number of previous driver who cause the time conflict) canceled their rental plan becasue of (presumably) the delayed return from the previous driver.
-- This means that most of drivers do not cancel their plan reagrdless of the waiting...?

WITH table_a AS (
    SELECT * FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE state = 'canceled'
    AND previous_ended_rental_id IS NOT NULL
    ORDER BY previous_ended_rental_id DESC
),
table_b AS (
    SELECT rental_id, car_id, checkin_type, state, delay_at_checkout_in_minutes, previous_ended_rental_id
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE rental_id IN (
        SELECT previous_ended_rental_id
        FROM table_a
    )
    AND delay_at_checkout_in_minutes IS NOT NULL
    ORDER BY rental_id DESC
),
table_c AS (
    SELECT previous_ended_rental_id AS rental_id, time_delta_with_previous_rental_in_minutes	
    FROM table_a
), 
table_join AS (
    SELECT table_b.rental_id, table_b.car_id, table_b.checkin_type, table_b.state, table_b.delay_at_checkout_in_minutes, table_c.time_delta_with_previous_rental_in_minutes,
    (time_delta_with_previous_rental_in_minutes - delay_at_checkout_in_minutes) AS time_delta_minus_delay
    FROM table_b
    LEFT JOIN table_c ON table_b.rental_id = table_c.rental_id
)
SELECT COUNT(*) AS count_cancellation_of_frction_cases
FROM table_join
WHERE time_delta_minus_delay < 0



-- When car is delayed more than 60mins, it's highly likely that the next driver cancel their plan.
WITH table_a AS (
SELECT * FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE state = 'canceled'
AND previous_ended_rental_id IS NOT NULL
ORDER BY previous_ended_rental_id DESC
),
table_b AS (
    SELECT rental_id, car_id, checkin_type, state, delay_at_checkout_in_minutes, previous_ended_rental_id
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE rental_id IN (
    SELECT previous_ended_rental_id
    FROM table_a
    )
    AND delay_at_checkout_in_minutes IS NOT NULL
    ORDER BY rental_id DESC
),
table_c AS (
    SELECT previous_ended_rental_id AS rental_id, time_delta_with_previous_rental_in_minutes	
    FROM table_a
), 
table_join AS (
    SELECT table_b.rental_id, table_b.car_id, table_b.checkin_type, table_b.state, table_b.delay_at_checkout_in_minutes, table_c.time_delta_with_previous_rental_in_minutes,
    (time_delta_with_previous_rental_in_minutes - delay_at_checkout_in_minutes) AS time_delta_minus_delay
    FROM table_b
    LEFT JOIN table_c ON table_b.rental_id = table_c.rental_id
),
table_d AS (
    SELECT *
    FROM table_join
    WHERE time_delta_minus_delay < 0
),
table_e AS (
    SELECT *, ABS(time_delta_minus_delay) AS abs_time_delta_minus_delay
    FROM table_d
    ORDER BY abs_time_delta_minus_delay DESC
)
SELECT 
    CASE
        WHEN abs_time_delta_minus_delay >= 1 AND abs_time_delta_minus_delay <=10 THEN '0-10m'
        WHEN abs_time_delta_minus_delay >= 11 AND abs_time_delta_minus_delay <=20 THEN '10m-20m'
        WHEN abs_time_delta_minus_delay >= 21 AND abs_time_delta_minus_delay <=30 THEN '20m-30m'
        WHEN abs_time_delta_minus_delay >= 31 AND abs_time_delta_minus_delay <=40 THEN '30m-40m'
        WHEN abs_time_delta_minus_delay >= 41 AND abs_time_delta_minus_delay <=50 THEN '40m-50m'
        WHEN abs_time_delta_minus_delay >= 51 AND abs_time_delta_minus_delay <=60 THEN '50m-60m'
        ELSE 'Above 60m'
    END AS time_mark,
    COUNT (*) AS total
FROM table_e
GROUP BY time_mark
ORDER BY time_mark DESC



-- Q1. What is the distribution of the checkin_type & state?

WITH mobile_a AS (
    SELECT 
    checkin_type, COUNT(*) AS canceled_total
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE checkin_type = 'mobile'AND state = 'canceled'
    GROUP BY checkin_type, state
),
mobile_b AS (
    SELECT 
    checkin_type, COUNT(*) AS ended_total
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE checkin_type = 'mobile'AND state = 'ended'
    GROUP BY checkin_type, state
),
mobile_a_join_b AS (
    SELECT mobile_a.checkin_type, mobile_a.canceled_total, mobile_b.ended_total
    FROM mobile_a
    LEFT JOIN mobile_b ON mobile_a.checkin_type = mobile_b.checkin_type
),
connect_a AS (
    SELECT checkin_type, COUNT(*) AS canceled_total
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE checkin_type = 'connect'AND state = 'canceled'
    GROUP BY checkin_type, state
),
connect_b AS (
    SELECT checkin_type, COUNT(*) AS ended_total
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE checkin_type = 'connect'AND state = 'ended'
    GROUP BY checkin_type, state
),
connect_a_join_b AS (
    SELECT connect_a.checkin_type, connect_a.canceled_total, connect_b.ended_total
    FROM connect_a
    LEFT JOIN connect_b ON connect_a.checkin_type = connect_b.checkin_type
),
union_mobile_connect AS (
    SELECT * FROM mobile_a_join_b
    UNION ALL
    SELECT * FROM connect_a_join_b
)
SELECT *
FROM union_mobile_connect


SELECT 
ROUND(AVG(delay_at_checkout_in_minutes), 2) AS average_delay_minutes
FROM `data-analysis-practice-314303.getaround.getaround` 
WHERE delay_at_checkout_in_minutes IS NOT NULL

ORDER BY delay_at_checkout_in_minutes DESC

WITH delay AS (
    SELECT checkin_type, COUNT(*) AS count_delay
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE delay_at_checkout_in_minutes IS NOT NULL AND delay_at_checkout_in_minutes > 0
    GROUP BY checkin_type
),
ontime AS (
    SELECT checkin_type, COUNT(*) AS count_ontime_and_early
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE delay_at_checkout_in_minutes IS NOT NULL AND delay_at_checkout_in_minutes <= 0
    GROUP BY checkin_type
),
delay_join_ontime AS (
    SELECT delay.checkin_type, delay.count_delay, ontime.count_ontime_and_early
    FROM delay
    LEFT JOIN ontime ON delay.checkin_type = ontime.checkin_type
)
SELECT *
FROM delay_join_ontime


WITH table_one AS (
    SELECT previous_ended_rental_id AS rental_id, 
    time_delta_with_previous_rental_in_minutes
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE previous_ended_rental_id IS NOT NULL
    ORDER BY previous_ended_rental_id
),
table_two AS (
    SELECT rental_id, car_id, checkin_type, state, delay_at_checkout_in_minutes,
    previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround` 
    WHERE rental_id IN
    (
    SELECT previous_ended_rental_id 
    FROM `data-analysis-practice-314303.getaround.getaround`
    )
    ORDER BY rental_id
),
table_join AS (
    SELECT table_two.rental_id, table_two.car_id, table_two.checkin_type,table_two.state, 
    table_two.delay_at_checkout_in_minutes, table_one.time_delta_with_previous_rental_in_minutes,
    (table_one.time_delta_with_previous_rental_in_minutes-table_two.delay_at_checkout_in_minutes) AS time_delta_minus_delay
    FROM table_two
    RIGHT JOIN table_one ON table_two.rental_id = table_one.rental_id
),
blacklist AS (
    SELECT * FROM table_join
    WHERE time_delta_minus_delay < 0
),
overtime AS (
    SELECT checkin_type, ABS(time_delta_minus_delay) AS length_overtime
    FROM blacklist
    ORDER BY length_overtime DESC
)
SELECT checkin_type, ROUND(AVG(length_overtime), 2) AS avg_overtime
FROM overtime
GROUP BY checkin_type
