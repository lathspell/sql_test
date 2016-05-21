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
