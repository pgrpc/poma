/*
    Тесты comment
*/

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_schema'); -- BOT
SELECT poma.comment('n','poma','Postgresql projects Makefile');
/*
  Test comment schema
*/
SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment;  -- EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_function'); -- BOT
\set QUIET on
create or replace function poma.test_arg() returns void language sql as
$_$ 
 SET CLIENT_MIN_MESSAGES = 'DEBUG';
$_$;
create or replace function poma.test_arg(a TEXT) returns void language sql as
$_$ 
 SET CLIENT_MIN_MESSAGES = a; --'INFO';
$_$;
\set QUIET off

-- вызов коментирования функций
SELECT poma.comment('f','poma.comment',E'te''st');
SELECT poma.comment('f','poma.test_arg','all test_arg');

/*
  Test comment function
*/
SELECT p.proname
, pg_catalog.pg_get_function_identity_arguments(p.oid)
, obj_description(p.oid, 'pg_proc')
  FROM pg_catalog.pg_proc p
 WHERE p.proname IN ('comment','test_arg')
; -- EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--SELECT poma.test('comment_table'); -- BOT
/*
  Тест comment table
*/
--SELECT poma.comment('t','poma.pkg','{id,"идентификатор","code","код",schemas,"наименование схемы"}');
--SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment;  -- EOT
-- ----------------------------------------------------------------------------

/*
id integer NOT NULL,
  code text NOT NULL,
  schemas name[],
  op poma.t_pkg_op,
  version numeric NOT NULL DEFAULT 0,
  log_name text,
  user_name text,
  ssh_client text,
  usr text DEFAULT "current_user"(),
  ip inet DEFAULT inet_client_addr(),
  stamp timestamp without time zone DEFAULT now(),
select nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
from pg_class c join pg_attribute a on (a.attrelid = c.oid) join pg_namespace n on (n.oid = c.relnamespace)
where nspname='poma' and relname='pkg';
*/
/*
      WHEN a_type = 'n' THEN 'SCHEMA'
      WHEN a_type = 't' THEN 'TABLE'
      WHEN a_type = 'v' THEN 'VIEW'
      WHEN a_type = 'c' THEN 'COLUMN'
      WHEN a_type = 'T' THEN 'TYPE'
      WHEN a_type = 'D' THEN 'DOMAIN'
      WHEN a_type = 'f' THEN 'FUNCTION'
      WHEN a_type = 's' THEN 'SEQUENCE'

*/
/*
-- type
set local search_path = poma,public;
SELECT comment('T','t_pg_proc_info','type comm'
,	'schema', 's anno'
, 'name',   'n anno'
, 'rt_oid', 'o_anno'
);
\dT+ poma.t_pg_proc_info
\d+ poma.t_pg_proc_info

-- current schema
SELECT comment('n',NULL,'current=ok');
-- named schema
SELECT comment('n','rpc','rpc=ok');
\dn+


*/
