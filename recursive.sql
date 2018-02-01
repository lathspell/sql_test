-- Examples from http://tapoueh.org/blog/2018/01/exporting-a-hierarchy-in-json-with-recursive-queries/

begin;
create table dndclasses
 (
   id         serial primary key,
   parent_id  int references dndclasses(id),
   name       text
 );
INSERT INTO dndclasses (id, parent_id, name) VALUES (1, null, 'Warrior');
INSERT INTO dndclasses (id, parent_id, name) VALUES (2, null, 'Wizard');
INSERT INTO dndclasses (id, parent_id, name) VALUES (3, null, 'Priest');
INSERT INTO dndclasses (id, parent_id, name) VALUES (4, null, 'Rogue');
INSERT INTO dndclasses (id, parent_id, name) VALUES (5, 1,       'Fighter');
INSERT INTO dndclasses (id, parent_id, name) VALUES (6, 1,       'Paladin');
INSERT INTO dndclasses (id, parent_id, name) VALUES (7, 1,       'Ranger');
INSERT INTO dndclasses (id, parent_id, name) VALUES (8, 2,       'Mage');
INSERT INTO dndclasses (id, parent_id, name) VALUES (9, 2,       'Specialist wizard');
INSERT INTO dndclasses (id, parent_id, name) VALUES (10, 2,      'Cleric');
INSERT INTO dndclasses (id, parent_id, name) VALUES (11, 3,      'Druid');
INSERT INTO dndclasses (id, parent_id, name) VALUES (12, 3,      'Priest of specific mythos');
INSERT INTO dndclasses (id, parent_id, name) VALUES (13, 4,      'Thief');
INSERT INTO dndclasses (id, parent_id, name) VALUES (14, 4,      'Bard');
INSERT INTO dndclasses (id, parent_id, name) VALUES (15, 13,         'Assassin');
commit;


--
-- Recursion's First Step
--
SELECT id, name, '{}'::int[] as parents, 0 as level FROM dndclasses WHERE parent_id is null;


--
-- Introducing WITH RECURSIVE
--
WITH RECURSIVE dndclasses_from_parents AS
  (
    SELECT
      id,
      name,
      '{}'::int[] as parents,
      0 as level
    FROM
      dndclasses
    WHERE
      parent_id is null

    UNION ALL

    SELECT
      c.id,
      c.name,
      parents || c.parent_id    as parents,
      level + 1                 as level
    FROM
      dndclasses_from_parents p
      inner join dndclasses c on (c.parent_id = p.id)
    WHERE
      c.id != ALL(parents)       -- Optional cycle detection. Same as "not c.id = ANY(parent_id)".
  )
SELECT name, id, parents, level FROM dndclasses_from_parents;


--
-- Final Query
--

WITH
recursive dndclasses_from_parents AS
(
  -- Classes with no parent, our starting point
  SELECT id, name, '{}'::int[] as parents, 0 as level FROM dndclasses WHERE parent_id is null

  UNION ALL

  -- Recursively find sub-classes and append them to the result-set
  SELECT
    c.id, c.name, parents || c.parent_id, level+1
  FROM
    dndclasses_from_parents p
    inner join dndclasses c on (c.parent_id = p.id)
  WHERE
    not c.id = any(parents)
),
dndclasses_from_children AS
(
  -- Now start from the leaf nodes and recurse to the top-level
  -- Leaf nodes are not parents (level > 0) and have no other row
  -- pointing to them as their parents, directly or indirectly
  -- (not id = any(parents))
  SELECT 
    c.parent_id,
    json_agg(jsonb_build_object('Name', c.name))::jsonb as js
  FROM
    dndclasses_from_parents tree
    inner join dndclasses c using (id)
  WHERE
    level > 0 and 
    tree.id != all(tree.parents)
  GROUP BY
    c.parent_id

  UNION ALL

  -- build our JSON document, one piece at a time
  -- as we're traversing our graph from the leaf nodes, 
  -- the bottom-up traversal makes it possible to accumulate
  -- sub-classes as JSON document parts that we glue together
  SELECT
    c.parent_id,
    jsonb_build_object('Name', c.name) || jsonb_build_object('Sub Classes', js) as js
  FROM
    dndclasses_from_children tree
    inner join dndclasses c on c.id = tree.parent_id
)
-- Finally, the traversal being done, we can aggregate
-- the top-level classes all into the same JSON document,
-- an array.
SELECT
  jsonb_pretty(jsonb_agg(js))
FROM
  dndclasses_from_children
WHERE
  parent_id is null
;


