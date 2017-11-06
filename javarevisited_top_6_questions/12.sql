-- 12. There exists an Order table and a Customer table, find all Customers who have never ordered

SELECT
  c.name
FROM
  customers c
  left outer join orders o on (c.id = o.customer_id)
WHERE
  o.id is null
;

-- Alternatives:
SELECT
  c.name
FROM
  customers c
WHERE
  c.id not in (SELECT DISTINCT o.customer_id FROM orders o)
;

-- co-related subquery (slow)
SELECT
  c.name
FROM
  customers c
WHERE
  not exists (SELECT 1 FROM orders o WHERE c.id = o.customer_id)
;
