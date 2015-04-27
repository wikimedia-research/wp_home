USE wmf;
SELECT referer, uri_path, uri_query, user_agent, geocoded_data['country_code'] AS country_iso,
geocoded_data['country'] AS country_name, agent_type, COUNT(*) AS requests
FROM webrequest
WHERE year = 2015
AND month = 04
AND ((day = 20 AND hour = 3) OR (day = 21 AND hour = 9) OR (day = 23 AND hour = 23) OR (day = 25 AND hour = 15)
OR (day = 25 AND hour = 18))
AND webrequest_source IN('text','mobile')
AND content_type IN('text/html\; charset=ISO-8859-1',
                    'text/html',
                    'text/html\; charset=utf-8',
                    'text/html\; charset=UTF-8')
AND http_status IN('200','304')
AND uri_host IN('www.wikipedia.org','www.m.wikipedia.org')
GROUP BY referer, uri_path, uri_query, user_agent, geocoded_data['country_code'],
geocoded_data['country'], agent_type;