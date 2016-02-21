--
-- Creates a backup of a specific table.
--
-- Useful if a regular dump would take too long to restore.
--
-- The backup table are created with all the indexes of the master table but
-- store them as e.g. table_backup_nightly1_idx so that they are also
-- immideately available. 
--
-- Foreign table references, including that to the primary key sequence are
-- preserved so that there will be no id conflict if some rows are later copied
-- back from the corrupted old master table to the currently active one.
--
-- Copying the data only holds a very light lock so that both INSERTs and 
-- SELECTs are possible meanwhile.
--
-- Restoring is very simple:
--   BEGIN
--   ALTER TABLE table_backup_master RENAME TO table_backup_corrupt;
--   ALTER TABLE table_backup_nightly1 RENAME TO table_backup;
--   COMMIT;
--

BEGIN;
DROP TABLE table_backup_nightly3;
ALTER TABLE table_backup_nightly2 RENAME TO table_backup_nightly3;
ALTER TABLE table_backup_nightly1 RENAME TO table_backup_nightly2;
CREATE TABLE table_backup_nightly1 (LIKE table_backup_master INCLUDING ALL);
INSERT INTO table_backup_nightly1 SELECT * FROM table_backup_master;
COMMIT;
