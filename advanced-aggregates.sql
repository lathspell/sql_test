--
-- Advanced aggregate functions
--
-- * count with "FILTER"
-- * mode() 
--
-- Ideas from http://www.databasesoup.com/2015/04/expressions-vs-advanced-aggregates.html/

/*
  SELECT
        device_id,
        count(*)::INT as present,
        (count(*) FILTER (WHERE valid))::INT as valid_count,
        (mode() WITHIN GROUP (order by val))::INT as mode,
        (percentile_disc(0.5) WITHIN GROUP (order by val))::INT
           as median
    FROM dataflow_0913
    GROUP BY device_id
    ORDER BY device_id;
*/

DROP TABLE IF EXISTS adv_agg;
CREATE TABLE adv_agg (
    id serial   not null primary key,
    --
    device_id   int not null,
    v           double precision not null,
    valid       boolean not null default false
);
CREATE INDEX ON adv_agg(device_id, v);

INSERT INTO adv_agg (device_id, v, valid) VALUES
    (1,10, false),
    (2,23, false),
    (2,23, true),
    (2,24, true),
    (3,40, true),
    (4,50, true),
    (4,40, true),
    (4,40, true),
    (2,4, true),
    (2,10, true),
    (2,15, true),
    (2,20, true);
SELECT * FROM adv_agg ORDER BY device_id, v;

SELECT 
  device_id, 
  count(*) as c,
  count(*) filter (where valid) as valid_c,      -- Only counts rows with valid=true
  mode() within group (order by v) as mode_of_v, -- Most used value of v within the current device_id group
  percent_rank(15.0) within group (order by v) as pctl_rank_v_15, -- Only 2 of 7 rows or 28% have v<15
  percentile_disc(0.70) within group (order by v) as pctl_disc_v_70 -- First value (23) which position is over 70%
FROM
  adv_agg
GROUP BY 
  device_id
ORDER BY
  device_id
;

CREATE EXTENSION IF NOT EXISTS pgtap;
set search_path to public,test;

SELECT plan(6);
-- Table filled?
SELECT is(count(*), 12::bigint) FROM adv_agg;
-- Count can now have a filter
SELECT is(count(*),                      7::bigint) FROM adv_agg WHERE device_id=2;
SELECT is(count(*) filter (where valid), 6::bigint) FROM adv_agg WHERE device_id=2;
-- mode() gives the most used value of v within the current device_id group
SELECT is(mode() within group (order by v), 23::double precision) FROM adv_agg WHERE device_id=2 GROUP BY device_id;
-- Only 2 of 7 rows or ~29% have v<15
SELECT is(round(percent_rank(15.0) within group (order by v)*100)::int, 29)  FROM adv_agg WHERE device_id=2 GROUP BY device_id;
-- First value (23) which position is over 70%
SELECT is(percentile_disc(0.70) within group (order by v), 23::double precision) FROM adv_agg WHERE device_id=2 GROUP BY device_id;
SELECT * FROM finish();
