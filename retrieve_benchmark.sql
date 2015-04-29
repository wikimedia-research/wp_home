USE wmf;
SELECT geocoded_data['country_code'] AS country_iso, COUNT(*) AS pageviews
FROM webrequest
WHERE year = 2015
AND month = 04
AND ((day = 20 AND hour = 3) OR (day = 21 AND hour = 9) OR (day = 23 AND hour = 23) OR (day = 25 AND hour = 15)
OR (day = 25 AND hour = 18))
AND is_pageview=true
AND uri_host LIKE('%wikipedia%')
GROUP BY geocoded_data['country_code'];