CREATE EXTENSION prefix;

DROP TABLE IF EXISTS number;
CREATE TABLE number (
    id      serial not null primary key,
    nr      prefix_range not null,
    prefix  text not null
);

CREATE INDEX ON number (nr);
CREATE INDEX ON number (length(nr));
CREATE INDEX ON number (prefix);

INSERT INTO number (nr, prefix) VALUES
    ('4910', 'a'),
    ('4920', 'b'),
    ('4930', 'c')
;

CREATE OR REPLACE FUNCTION my_find(a text) RETURNS text AS $$
DECLARE
  result text;
  my_row number%ROWTYPE;
BEGIN
  -- Query
    SELECT
      *
    INTO
      my_row
    FROM
      number
    WHERE
      a <@ nr
    ORDER BY
      length(nr) desc
    LIMIT
      1
    ;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No entry for %', a USING HINT = 'Did you RTFM?';
    RETURN null;
  END IF;

  result := my_row.prefix;

  -- Return final result
  RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT my_find('49206');
