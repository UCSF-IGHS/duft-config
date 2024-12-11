-- Active: 1724568976842@@127.0.0.1@3306
SELECT COUNT(hiv_diagnosis_date) AS value FROM fact_sentinel_event WHERE SUBSTR(hiv_diagnosis_date, -4) = '2022'