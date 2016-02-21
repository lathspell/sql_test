CREATE OR REPLACE FUNCTION big(i int) RETURNS text AS $$
DECLARE
  tmp int;
  result int;
BEGIN
  raise notice 'big(%) called', i;

  if (i < 5) then
    SELECT sum(test2.i) INTO tmp FROM test2 ORDER BY random() LIMIT 10;
  elsif (i < 10) then
    SELECT sum(test2.i * test2.i) INTO tmp FROM test2 ORDER BY random() LIMIT 10;
  else
    raise exception 'Parameter i=% is too big!', i;
  end if;
  raise notice 'tmp=%', tmp;

  DELETE FROM test2 WHERE test2.i >= 1000;
  INSERT INTO test2 (i, t) VALUES (1000, tmp);
  
  if ((i % 2) = 0) then
    raise notice 'altering';
    UPDATE test2 SET t = t || '!' WHERE test2.i >= 1000;
  end if;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT big(2);
SELECT * FROM test2 WHERE i >= 1000;

SELECT big(3);
SELECT * FROM test2 WHERE i >= 1000;

SELECT big(8);
SELECT * FROM test2 WHERE i >= 1000;

SELECT big(random()::int % 9) FROM generate_series(1, 20); -- 524ms without logging
SELECT big(random()::int % 9) FROM generate_series(1, 20); -- 504ms with logging at debug
SELECT big(random()::int % 9) FROM generate_series(1, 20); -- 972ms with logging at info
SELECT big(random()::int % 9) FROM generate_series(1, 20); -- 1033ms with logging at notice