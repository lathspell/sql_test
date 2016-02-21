CREATE OR REPLACE FUNCTION assert(x boolean, msg text DEFAULT NULL) RETURNS void AS $$
BEGIN
 IF not x OR x is null THEN
   IF msg IS NULL THEN
     RAISE EXCEPTION 'Assert failed';
   ELSE
     RAISE EXCEPTION 'Assert failed: %', msg;
   END IF;
 END IF; 
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT assert(2=4);
SELECT assert(2=4, 'The Reason...');



-- Benchmarking time for function calls inside stored procedures
CREATE OR REPLACE FUNCTION bench1() RETURNS void AS $$
DECLARE sum int;
BEGIN
  sum := 0;
  FOR i IN 1 .. 1000 LOOP
    sum := sum * i;
    PERFORM assert(i>0);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT count(*) FROM (SELECT bench1() FROM generate_series(1, 1000)) tmp1; -- 7s

CREATE OR REPLACE FUNCTION bench2() RETURNS void AS $$
DECLARE sum int;
BEGIN
  sum := 0;
  FOR i IN 1 .. 1000 LOOP
    sum := sum * i;
    
    IF not i > 0 OR i is null THEN
      IF msg IS NULL THEN
        RAISE EXCEPTION 'Assert failed';
      ELSE
        RAISE EXCEPTION 'Assert failed: %', 'Foo';
      END IF;
    END IF; 
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT count(*) FROM (SELECT bench2() FROM generate_series(1, 1000)) tmp1; -- 1s

SELECT bench2();
