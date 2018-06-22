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
SELECT poma.comment('t','poma.pkg', 'Информация о пакетах и схемах',
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
); --EOT
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='pkg'
AND attnum > 0
ORDER BY attname ASC; --EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_view1'); -- BOT
CREATE OR REPLACE VIEW poma.test_view_pkg AS 
 SELECT id, code, schemas FROM poma.pkg;
/*
  Тест comment view
*/
SELECT poma.comment('v','poma.test_view_pkg'
  ,'Представление с краткой информацией о пакетах и схемах'
  , VARIADIC ARRAY[
      'id','идентификатор view'
    , 'code','код пакета view'
    , 'schemas','наименование схемы view'
  ]); --EOT
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='test_view_pkg'
ORDER BY attname ASC; --EOT
-- ----------------------------------------------------------------------------
SELECT poma.test('comment_view2'); -- BOT
create table poma.vctable1(
id integer primary key
, anno text
); -- EOT
select poma.comment('t','poma.vctable1', 'test table'
, 'anno', 'row anno'
, 'id', 'row id'
); --EOT

create view poma.vcview1 AS
  select *
  , current_date AS date
  from poma.vctable1
; --EOT
select poma.comment('v','poma.vcview1', 'test view1'
, 'id', 'row id1'
, 'date', 'cur date'
); -- EOT
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum)
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname IN('vctable1', 'vcview1')
AND attnum > 0
ORDER BY relname, attname ASC; --EOT
-- ----------------------------------------------------------------------------
SELECT poma.test('comment_view3'); -- BOT
CREATE VIEW poma.vcview2 AS
  SELECT v.id, v.date, t.anno
  , 1 AS ok
  FROM poma.vcview1 v
  JOIN poma.vctable1 t using(id)
; -- EOT
SELECT poma.comment('v','poma.vcview2', 'test view2'
, 'ok', 'new filed'
); -- EOT

SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname = 'vcview2'
ORDER BY attname ASC; --EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_column'); -- BOT
/*
  Тест comment column
*/
SELECT poma.comment('c', 'poma.pkg.id', 'Тест. Изменение наименования column id'); --EOT
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='pkg' AND attname='id'
ORDER BY attname ASC; --EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_type_enum'); -- BOT
/*
  Тест comment type enum
*/
CREATE TYPE poma.tmp_event_class AS ENUM (
  'create'
, 'update'
, 'delete'
); --EOT
SELECT poma.comment('E','poma.tmp_event_class','Комментирование типа enum'); --EOT
SELECT obj_description(to_regtype('poma.tmp_event_class')); --EOT

-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_type'); -- BOT
/*
  Тест comment type
*/
CREATE TYPE poma.tmp_errordef AS (
  field_code TEXT
, err_code   TEXT
, err_data   TEXT
); --EOT

SELECT poma.comment('T', 'poma.tmp_errordef', 'Тестовый тип'
 , 'field_code', 'Код поля с ошибкой'
 , 'err_code', 'Код ошибки'
 , 'err_data', 'Данные ошибки'
); --EOT

SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(to_regtype(c.relname)), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='tmp_errordef'
ORDER BY attname ASC; --EOT
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_domain'); -- BOT
/*
  Тест comment domain
*/
CREATE DOMAIN test_domain AS INTEGER; --EOT
SELECT poma.comment('D', 'test_domain', 'Тест комментария DOMAIN'); --EOT
SELECT obj_description(to_regtype('test_domain')); --EOT
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

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_sequence'); -- BOT
/*
  Тест comment sequence
*/
SELECT poma.comment('s', 'pkg_id_seq', 'Тест комментария последовательности pkg_id_seq'); --EOT
SELECT obj_description('pkg_id_seq'::regclass); --EOT
-- ----------------------------------------------------------------------------
