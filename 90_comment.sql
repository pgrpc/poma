/*
    Тесты comment
*/

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_schema'); -- BOT
/*
  Test comment schema
*/
SELECT poma.comment('n','poma','Postgresql projects Makefile'); --EOT
SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment;  -- EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_table'); -- BOT
/*
  Тест comment table
*/
SELECT poma.comment('t','poma.pkg'
  ,'Информация о пакетах и схемах'
  , VARIADIC ARRAY[
      'id','идентификатор'
    , 'code','код пакета'
    , 'schemas','наименование схемы'
    , 'op','стадия'
    , 'version','версия'
    , 'log_name','наименования пользователя'
    , 'user_name','имя пользователя'
    , 'ssh_client','ключ'
    , 'usr','пользователь'
    , 'ip','ip-адрес'
    , 'stamp','дата/время создания/изменения'
  ]); --EOT
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='pkg'
ORDER BY attname ASC; --EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_view'); -- BOT
CREATE OR REPLACE VIEW poma.test_view_pkg AS 
 SELECT id, code, schemas FROM poma.pkg;
/*
  Тест comment view
*/
SELECT poma.comment('v','poma.test_view_pkg'
  ,'Представление с краткой информацией о пакетах и схемах'
  , VARIADIC ARRAY[
      'id','идентификатор'
    , 'code','код пакета'
    , 'schemas','наименование схемы'
  ]); --EOT
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='test_view_pkg'
ORDER BY attname ASC; --EOT
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
/*
  Test comment function
*/
-- вызов коментирования функций
SELECT poma.comment('f','poma.comment',E'te''st'); --EOT
SELECT poma.comment('f','poma.test_arg','all test_arg'); --EOT

SELECT p.proname
  , pg_catalog.pg_get_function_identity_arguments(p.oid)
  , obj_description(p.oid, 'pg_proc')
FROM pg_catalog.pg_proc p
WHERE p.proname IN ('comment','test_arg')
ORDER BY proname, pg_get_function_identity_arguments ASC; -- EOT
-- ----------------------------------------------------------------------------

/*
id integer NOT NULL,
  code text NOT NULL,
  schemas name[],
  op,
  version,
  log_name,
  user_name,
  ssh_client,
  usr,
  ip,
  stamp,

select nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
from pg_class c join pg_attribute a on (a.attrelid = c.oid) join pg_namespace n on (n.oid = c.relnamespace)
where nspname='poma' and relname='pkg';
*/
/*
*      WHEN a_type = 'n' THEN 'SCHEMA'
*      WHEN a_type = 't' THEN 'TABLE'
      WHEN a_type = 'v' THEN 'VIEW'
      WHEN a_type = 'c' THEN 'COLUMN'
      WHEN a_type = 'T' THEN 'TYPE'
      WHEN a_type = 'D' THEN 'DOMAIN'
*      WHEN a_type = 'f' THEN 'FUNCTION'
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
