-- Prepare test table
DROP TABLE IF EXISTS test2 CASCADE;
CREATE TABLE test2 (
    id serial not null unique primary key,
    i int not null default 0,
    t text not null default ''
);
CREATE INDEX ON test2 (i);
CREATE INDEX ON test2 (t);

INSERT INTO test2 (i, t) SELECT generate_series(1,10), 'Foo';

-- Dropping needs the exact function <what was that word again>
DROP FUNCTION IF EXISTS my_sum(a int, b int);

-- Simple function
CREATE OR REPLACE FUNCTION my_sum(a int, b int) RETURNS int AS $$
BEGIN
  RETURN a + b;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

SELECT my_sum(2, 5);

-- Returns the result of a query.
CREATE OR REPLACE FUNCTION my_count_rows() RETURNS int AS $$
DECLARE num int;
BEGIN
  SELECT count(*) INTO num FROM test2;
  RETURN num;
END;
$$ LANGUAGE plpgsql;

SELECT my_count_rows();

-- Returns the result of a query or null if that query failed.
CREATE OR REPLACE FUNCTION my_first_value_doubled() RETURNS int AS $$
DECLARE v int;
BEGIN
  SELECT i INTO v FROM test2 ORDER BY id asc LIMIT 1;
  IF FOUND THEN
    RETURN v * 2;
  ELSE
    RETURN null;
  END IF;
END
$$ LANGUAGE plpgsql;

SELECT i, my_first_value_doubled() FROM test2 ORDER BY id LIMIT 1;

-- Sometimes the exact parameter type is irrelevant.
CREATE OR REPLACE FUNCTION my_add_anything(a anyelement, b anyelement) RETURNS anyelement AS $$
BEGIN
  RETURN a+b;
END;
$$ LANGUAGE plpgsql;

SELECT my_add_anything(2.4, 1.1);

-- Return an anonymous table of two columns.
CREATE OR REPLACE FUNCTION my_get_two_values() RETURNS TABLE(t text, i int) AS $$
BEGIN
  RETURN QUERY SELECT lower(test2.t), test2.i*2 FROM test2 LIMIT 1;
END;
$$ LANGUAGE plpgsql;

SELECT t, i FROM my_get_two_values();

CREATE OR REPLACE FUNCTION my_get_two_values2() RETURNS TABLE(t text, i int) AS $$
BEGIN
  t := 'foo';
  i := 42;
  return next;
END;
$$ LANGUAGE plpgsql;

SELECT t, i FROM my_get_two_values2();


-- Returns a record with different syntax
CREATE OR REPLACE FUNCTION my_get_first_id(m int) RETURNS int AS $$
DECLARE
  result int;
BEGIN
  SELECT * INTO STRICT result FROM test2 WHERE id < m ORDER BY id asc LIMIT 1;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Nothing found';
  ELSE
    RETURN result;
  END IF;
END;
$$ LANGUAGE plpgsql;

SELECT my_get_first_id(2);
SELECT my_get_first_id(-1);

-- Create queries dynamically
-- Only values can be accessed with $n, identifiers have to be inserted as written below!
CREATE OR REPLACE FUNCTION my_get_that_t_from_table(tablename text, id int) RETURNS text AS $$
DECLARE
  result text;
BEGIN
  EXECUTE 'SELECT t FROM ' || tablename::regclass || '  WHERE id = $1' INTO result USING id;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT my_get_that_t_from_table('test2', 2);

-- The same using format()
CREATE OR REPLACE FUNCTION my_get_that_t_from_table2(tablename text, id int) RETURNS text AS $$
DECLARE
  result text;
BEGIN
  EXECUTE format('SELECT t FROM %I WHERE id = %L', tablename, id) INTO result USING id;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT my_get_that_t_from_table2('test2', 2);

-- Diagnostics
CREATE OR REPLACE FUNCTION my_get_diags(tablename text) RETURNS int AS $$
DECLARE
  row_count int;
BEGIN
  EXECUTE format('UPDATE %I SET id = id WHERE id < 3', tablename);
  GET DIAGNOSTICS row_count = ROW_COUNT;
  RAISE NOTICE 'My affected rows: %', row_count;
  RETURN row_count;
END;
$$ LANGUAGE plpgsql;

SELECT my_get_diags('test2');

-- Ignore errors
CREATE OR REPLACE FUNCTION my_ignore_error() RETURNS void AS $$
DECLARE
  y int;
BEGIN
  y := 1/0;
EXCEPTION
  WHEN division_by_zero THEN
    RAISE NOTICE 'There was a division_by_zero but it has been ignored!';
    NULL; -- Make it clear that nothing should be done.
END;
$$ LANGUAGE plpgsql;

SELECT my_ignore_error();

-- Control structures 1
CREATE OR REPLACE FUNCTION my_test_conditionals(x int) RETURNS void AS $$
DECLARE
  result text;
BEGIN
  -- if
  RAISE NOTICE 'if with x=%', x;
  IF x < 4 THEN
    result := 'small';
  ELSEIF x < 10 THEN
    result := 'medium';
  ELSE
    result := 'large';
  END IF;
  RAISE NOTICE 'if yielded to %', result;

  -- case
  RAISE NOTICE 'case with x=%', x;
  CASE x
    WHEN 2 THEN result := 'two';
    WHEN 5 THEN result := 'five';
    ELSE result := 'other';
  END CASE;
  RAISE NOTICE 'case yielded to %', result;

  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT my_test_conditionals(5);

-- Control structures 2
-- Labels are also supported.
CREATE OR REPLACE FUNCTION my_test_loops() RETURNS void AS $$
DECLARE i int;
BEGIN
  -- loop
  i := 0;
  LOOP
    RAISE NOTICE 'loop with i=%', i;
    IF i > 10 THEN
       RAISE NOTICE 'loop exited at i=%', i;
       EXIT;
    END IF;

    i := i + 1;
  END LOOP;

  -- while
  i := 0;
  WHILE i < 10 LOOP
    RAISE NOTICE 'while loop with i=%', i;
    i := i + 1;
  END LOOP;

  -- for
  FOR ii IN REVERSE 20..10 BY 2 LOOP
    RAISE NOTICE 'for loop with ii=%', ii;
  END LOOP;

  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT my_test_loops();

-- Loops over a result set
CREATE OR REPLACE FUNCTION my_iterate_over_rows() RETURNS void AS $$
DECLARE row test2%ROWTYPE;
BEGIN
  FOR row IN 
    SELECT * FROM test2 WHERE id between 5 and 7 ORDER BY id 
  LOOP
    RAISE NOTICE 'Found row with id=% and i=%', row.id, row.i;
  END LOOP;
END
$$ LANGUAGE plpgsql;

SELECT my_iterate_over_rows();

-- Check for unique violation
CREATE OR REPLACE FUNCTION my_check_unique_error(id int, i int, t text) RETURNS void AS $$
BEGIN
  INSERT INTO test2 (id, i, t) VALUES (id, i, t);
  RETURN;
EXCEPTION
  WHEN unique_violation THEN
     RAISE NOTICE 'Ignoring unique error for i=%, t=%', i, t;
END;
$$ LANGUAGE plpgsql;

SELECT my_check_unique_error(1, 111, 'foo');

-- Fun with cursors
CREATE OR REPLACE FUNCTION my_cursors() RETURNS SETOF test2 AS $$
DECLARE
  tmp test2%ROWTYPE;
  c refcursor;
  c2 CURSOR (query_id int) IS SELECT * FROM test2 WHERE id >= query_id ORDER BY id desc;
BEGIN
  OPEN c FOR SELECT * FROM test2 ORDER BY id;
  FETCH NEXT FROM c INTO tmp;
  RETURN NEXT tmp;

  MOVE ABSOLUTE 5 FROM c;
  FETCH c INTO tmp; -- The one after row 5 is row 6!
  RETURN NEXT tmp;
  
  MOVE ABSOLUTE 5 FROM c;
  MOVE FORWARD 2 FROM c;
  FETCH c INTO tmp; -- This is row 8 after row (5+2)!
  RETURN NEXT tmp;

  MOVE ABSOLUTE 5 FROM c;
  MOVE RELATIVE +2 FROM c;
  FETCH c INTO tmp; -- This is also row 8!
  RETURN NEXT tmp;

  FETCH LAST FROM c INTO tmp;
  RETURN NEXT tmp;

  MOVE ABSOLUTE 3 FROM c;
  -- does not work: FOR row IN c LOOP
  FOR row IN c2(8) LOOP
    row.t := 'Bar';
    RETURN NEXT row;
    IF (row.id < 5) THEN
      EXIT;
    END IF;
  END LOOP;

  CLOSE c;
  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM my_cursors();

-- Returns a row of a pre-defined type.
CREATE OR REPLACE FUNCTION my_get_that_row(id int) RETURNS SETOF test2 AS $$
DECLARE
  result test2%ROWTYPE;
BEGIN
  SELECT * INTO result FROM test2 WHERE test2.id = my_get_that_row.id;
  IF FOUND THEN
    RETURN NEXT result;
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM my_get_that_row(5);
SELECT * FROM my_get_that_row(-1);

-- Will never succeed :)
CREATE OR REPLACE FUNCTION my_error(i int) RETURNS void AS $$
BEGIN
  PERFORM 1 / i;
  RAISE SQLSTATE '12345';
EXCEPTION
  WHEN division_by_zero THEN
    RAISE NOTICE 'There was a division by zero in function my_error(%)!', i;
    RAISE; -- re-throw exception
END;
$$ LANGUAGE plpgsql;

SELECT my_error(1);
SELECT my_error(0);

-- Auditing
CREATE OR REPLACE FUNCTION test2_audit() RETURNS TRIGGER AS $$
DECLARE
  msg text;
BEGIN
  CASE TG_OP
    WHEN 'INSERT' THEN
      RAISE NOTICE 'user=% op=% old=N/A new=%', user, TG_OP, NEW;
      RETURN NEW;
    WHEN 'UPDATE' THEN
      RAISE NOTICE 'user=% op=% old=% new=%', user, TG_OP, OLD, NEW;
      RETURN NEW;
    WHEN 'DELETE' THEN
      RAISE NOTICE 'user=% op=% old=% new=N/A', user, TG_OP, OLD;
      RETURN OLD;
  END CASE;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER test2_audit_trg
  AFTER INSERT OR UPDATE OR DELETE ON test2
  FOR EACH ROW EXECUTE PROCEDURE test2_audit()
;

INSERT INTO test2 (i, t) VALUES (100, 'trg_test');
UPDATE test2 SET i=101 WHERE i=100;
DELETE FROM test2 WHERE i=101;

