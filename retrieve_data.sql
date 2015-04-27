USE wmf;
SELECT referer, uri_path, uri_query, user_agent, geocoded_data['country_code'] AS country_iso,
geocoded_data['country'] AS country_name, agent_type
FROM webrequest
WHERE year = 2015
AND month = 04
AND day = 19
AND hour = 3
AND webrequest_source IN('text','mobile')
AND content_type IN('text/html\; charset=ISO-8859-1',
                    'text/html',
                    'text/html\; charset=utf-8',
                    'text/html\; charset=UTF-8')
AND http_status IN('200','304')
AND uri_host IN('www.wikipedia.org','www.m.wikipedia.org');