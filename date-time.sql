-- PostgreSQL 9.2 will have a tsrange data type!

DROP TABLE IF EXISTS cheap_tariff;
CREATE TABLE cheap_tariff (
    id      serial not null primary key,
    --
    doy     date default null,
    dow     int default null,
    t0      time without time zone not null,
    t1      time without time zone not null
);

ALTER TABLE cheap_tariff ADD CHECK(dow in (1,2,3,4,5,6,7));
ALTER TABLE cheap_tariff ADD CHECK(t1 > t0);
ALTER TABLE cheap_tariff ADD CHECK(not (doy is not null and dow is not null));
CREATE UNIQUE INDEX ON cheap_tariff (doy, t0);
CREATE UNIQUE INDEX ON cheap_tariff (dow, t0);
CREATE INDEX ON cheap_tariff (t0);
CREATE INDEX ON cheap_tariff (t1);

DELETE FROM cheap_tariff;
INSERT INTO cheap_tariff (id, doy, dow, t0, t1) VALUES
  (1, null, null, '18:00:00', '23:59:59'),
  (2, null, null, '00:00:00', '05:59:59'),
  (3, null, 6, '00:00:00', '23:59:59'),
  (4, null, 7, '00:00:00', '23:59:59'),
  (5, '2012-12-24', null, '00:00:00', '08:59:59'),
  (6, '2012-12-24', null, '17:00:00', '23:59:59');

CREATE OR REPLACE FUNCTION is_cheap_tariff(ts timestamp without time zone) RETURNS int AS $$
  SELECT
    id
  FROM
    cheap_tariff
  WHERE
    (doy = $1::date or dow = extract(isodow from $1)::int or (doy is null and dow is null)) and
    $1::time between t0 and t1
  ORDER BY
    doy, dow, t0 -- "order by" implies "asc" and that implies "nulls last"
  ;
$$
LANGUAGE SQL VOLATILE SECURITY DEFINER;

CREATE OR REPLACE VIEW view_cheap_tariff AS
  SELECT ts, is_cheap_tariff(ts) FROM
    (SELECT generate_series('2012-01-01'::timestamp, '2012-12-31 23:59:59', interval '1' hour) as ts) tmp;

set search_path to public,test;

SELECT plan(11);
SELECT throws_ok('INSERT INTO cheap_tariff (t0, t1) VALUES (''12:00:00'', ''10:00:00'')', 23514); -- check_violation
SELECT throws_ok('INSERT INTO cheap_tariff (doy, dow, t0, t1) VALUES (''2012-10-01'', 4, ''00:00:00'', ''23:59:59'')', 23514); -- check_violation
SELECT is(is_cheap_tariff('2012-10-01 14:30:42'), null);
SELECT is(is_cheap_tariff('2012-10-01 19:30:42'), 1);
SELECT is(is_cheap_tariff('2012-10-02 01:30:42'), 2);
SELECT is(is_cheap_tariff('2012-10-06 11:11:11'), 3);
SELECT is(is_cheap_tariff('2012-10-07 11:11:11'), 4);
SELECT is(is_cheap_tariff('2012-12-24 11:11:11'), null);
SELECT is(is_cheap_tariff('2012-12-24 01:01:01'), 5);
SELECT is(is_cheap_tariff('2012-12-24 18:18:18'), 6);
SELECT is(count(*), 8784::bigint) FROM view_cheap_tariff WHERE ts::text like '2012%';
SELECT * FROM finish();
