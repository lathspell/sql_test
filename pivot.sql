CREATE EXTENSION tablefunc;

DROP TABLE IF EXISTS pivot;
CREATE TABLE pivot (
    day         date,
    salesman    text,
    region      text,
    product     text,
    price       decimal(8,2) not null default 0
);

INSERT INTO pivot VALUES
 ('2012-01-01', 'Alice',    'West',     'Pro',        13),
 ('2012-02-01', 'Dan',      'South',    'Basic',       4),
 ('2012-03-01', 'Alice',    'South',    'Basic',      16),
 ('2012-03-01', 'Bob',      'South',    'Pro',         9),
 ('2012-04-01', 'Dan',      'East',     'Medium',     20),
 ('2012-05-01', 'Bob',      'North',    'Medium',     42);

/* Ausgabe:

  area  | basic | medium |  pro  | total  
 -------+-------+--------+-------+--------
  North |     0 |  42.00 |     0 |  42.00
  West  |     0 |      0 | 13.00 |  13.00
  South | 20.00 |      0 |  9.00 |  29.00
  East  |     0 |  20.00 |     0 |  20.00
  total | 20.00 |  62.00 | 22.00 | 104.00

*/
SELECT
  area, basic, medium, pro, total
FROM
  (
    WITH tmp_crosstab0 AS
      (
        SELECT
          area,
          coalesce(raw_basic, 0) as basic, 
          coalesce(raw_medium, 0) as medium,
          coalesce(raw_pro, 0) as pro
        FROM
          crosstab(
            'SELECT
               region,
               product,
               sum(price)
             FROM
               pivot
             GROUP BY
               1, 2 
             ORDER BY
               1, 2',
            'SELECT product FROM pivot GROUP BY 1 ORDER BY 1'
          ) as tmp_crosstab(area text, raw_basic decimal, raw_medium decimal, raw_pro decimal)
      )
    (
      SELECT
        1 as internal_order,
        area,
        basic,
        medium,
        pro,
        basic + medium + pro as total
      FROM
        tmp_crosstab0
      GROUP BY
        area, basic, medium, pro
      ORDER BY
        area
    ) 
    UNION 
    (
      SELECT
        2 as internal_order,
        'total',
        sum(basic),
        sum(medium),
        sum(pro),
        sum(basic + medium + pro)
      FROM
        tmp_crosstab0
    )
  ) as tmp_both
ORDER BY internal_order;
