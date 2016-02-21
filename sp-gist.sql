-- https://docs.google.com/viewer?a=v&q=cache:eGIFlVK9a4kJ:pgexperts.com/document.html%3Fid%3D55+&hl=de&gl=de&pid=bl&srcid=ADGEESjv4PfuCH0aZ3OZehkmZWQxo5OdVev9kWTVrltH_ipOc087xiDyTQ2Ek30oyC5tJxaPs4WUYt5TEPh4Ft-Wa1woUcosTdYKRpeBSqzMbBPe2U_emeMTd48l3ZbDCat_21xDkNZO&sig=AHIEtbQvzVOhkQ_oIF6NtR_-26KvZl3ctA

DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t3;
DROP TABLE IF EXISTS t4;

CREATE TABLE t1 (
    nr  text
);
CREATE INDEX t1_btree ON t1 USING btree (nr);

CREATE TABLE t2 (
    nr  prefix_range
);
CREATE INDEX t2_gist ON t2 USING gist (nr);

CREATE TABLE t3 (
    nr  text
);
CREATE INDEX t3_spgist ON t3 USING spgist (nr);

INSERT INTO t1 (nr) SELECT trim(to_char(i, '00000')) FROM generate_series(1, 100000) as t(i);
INSERT INTO t2 SELECT * FROM t1;
INSERT INTO t3 SELECT * FROM t1;

DROP OPERATOR CLASS spgist_prefix_range_ops USING spgist ;

CREATE OPERATOR CLASS spgist_prefix_range_ops
DEFAULT FOR TYPE prefix_range USING spgist
AS
	OPERATOR	1	@>,
	OPERATOR	2	<@,
	OPERATOR	3	=,
	OPERATOR	4	&&,
	FUNCTION	1	gpr_consistent (internal, prefix_range, smallint, oid, internal),
	FUNCTION	2	gpr_union (internal, internal),
	FUNCTION	3	gpr_compress (internal),
	FUNCTION	4	gpr_decompress (internal);
	-- crash FUNCTION	5	gpr_penalty (internal, internal, internal);
	-- FUNCTION	6	gpr_picksplit (internal, internal),
	-- FUNCTION	7	gpr_same (prefix_range, prefix_range, internal);


CREATE TABLE road (
        name            text,
        thepath         path
);
COPY road FROM '/srv/home/james/tmp/postgresql-9.2-9.2.1/src/test/regress/data/streets.data';


CREATE TABLE suffix_text_tbl AS
    SELECT name AS t FROM road WHERE name !~ '^[0-9]';

INSERT INTO suffix_text_tbl
    SELECT 'P0123456789abcdef' FROM generate_series(1,1000);
INSERT INTO suffix_text_tbl VALUES ('P0123456789abcde');
INSERT INTO suffix_text_tbl VALUES ('P0123456789abcdefF');

CREATE INDEX sp_suff_ind ON suffix_text_tbl USING spgist (t);

SELECT count(*) FROM suffix_text_tbl WHERE t = 'P0123456789abcdef';
SELECT count(*) FROM suffix_text_tbl WHERE t = 'P0123456789abcde';
SELECT count(*) FROM suffix_text_tbl WHERE t = 'P0123456789abcdefF';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t <    'Aztec                         Ct  ';
SELECT count(*) FROM suffix_text_tbl WHERE t <    'Aztec                         Ct  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';
SELECT count(*) FROM suffix_text_tbl WHERE t ~<~  'Aztec                         Ct  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t <=   'Aztec                         Ct  ';
SELECT count(*) FROM suffix_text_tbl WHERE t <=   'Aztec                         Ct  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';
SELECT count(*) FROM suffix_text_tbl WHERE t ~<=~ 'Aztec                         Ct  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t =    'Aztec                         Ct  ';
SELECT count(*) FROM suffix_text_tbl WHERE t =    'Aztec                         Ct  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t =    'Worth                         St  ';
SELECT count(*) FROM suffix_text_tbl WHERE t =    'Worth                         St  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t >=   'Worth                         St  ';
SELECT count(*) FROM suffix_text_tbl WHERE t >=   'Worth                         St  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t ~>=~ 'Worth                         St  ';
SELECT count(*) FROM suffix_text_tbl WHERE t ~>=~ 'Worth                         St  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t >    'Worth                         St  ';
SELECT count(*) FROM suffix_text_tbl WHERE t >    'Worth                         St  ';

EXPLAIN (COSTS OFF)
SELECT count(*) FROM suffix_text_tbl WHERE t ~>~  'Worth                         St  ';
SELECT count(*) FROM suffix_text_tbl WHERE t ~>~  'Worth                         St  ';
