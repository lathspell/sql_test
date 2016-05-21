CREATE TABLE transactions (
  id          int serial not null primary_key,
  account_id  integer not null,
  ts          timestamp without time zone not null,
  amount      money not null
);
COMMENT ON TABLE transactions IS 'Table for bank account transactions';

INSERT INTO transactions (account_id, ts, amount, id) VALUES (2, '2016-05-21 21:58:16.577854', '$3.12', 1);
INSERT INTO transactions (account_id, ts, amount, id) VALUES (2, '2016-05-21 21:58:49.235718', '$4.12', 2);
INSERT INTO transactions (account_id, ts, amount, id) VALUES (4, '2016-05-21 21:58:58.652055', '$5.00', 3);
INSERT INTO transactions (account_id, ts, amount, id) VALUES (6, '2016-05-21 21:59:04.91565', '$24.00', 4);
INSERT INTO transactions (account_id, ts, amount, id) VALUES (2, '2016-05-21 21:59:13.188133', '$22.00', 5);
INSERT INTO transactions (account_id, ts, amount, id) VALUES (2, '2016-05-21 22:04:06.957385', '-$7.00', 6);

/**
 * VIEW with running total using Window Functions.
 *
 * Add new column `balance` with the sum of the `amount` of all preceding rows
 * up to and including the current row.
 *
 * The "OVER ... PARTITION BY" construct is not a "sub query" but a "window function"
 * which is far more efficient for this case.
 */
CREATE OR REPLACE VIEW view_transactions_with_balance AS
SELECT
  tx.account_id,
  tx.id,
  tx.ts,
  tx.amount,
  sum(tx.amount) OVER (
    PARTITION BY tx.account_id
    ORDER BY tx.ts, tx.id
    ROWS between unbounded preceding and 0 preceding
  ) as balance
FROM
  transactions tx
ORDER BY
  tx.ts,
  tx.id
;

SELECT * FROM view_transactions_with_balance WHERE account_id=2;

/**
 * VIEW with running total using subselects.
 *
 * --> DO NOT USE, see view with window function!
 */
CREATE OR REPLACE VIEW view_transactions_with_balance_subquery AS
SELECT
  tx.account_id,
  tx.id,
  tx.ts,
  tx.amount,
  /* Add new column `balance` with the sum of the `amount` of all preceding rows
     up to and including the current row.
     The "OVER ... PARTITION BY" construct is not a "sub query" but a "window function"
     which is far more efficient for this case.
   */
  (SELECT sum(tmp.amount)
   FROM transactions tmp
   WHERE tmp.account_id = tx.account_id and tmp.id <= tx.id
  ) as balance
FROM
  transactions tx
ORDER BY
  tx.ts,
  tx.id
;

SELECT * FROM view_transactions_with_balance_subquery WHERE account_id=2;
