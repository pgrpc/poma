#  poma/90_comment
## comment_schema

```sql
/*
  Test comment schema
*/
SELECT poma.comment('n','poma','Postgresql projects Makefile')
;
```
|comment 
|--------
|

```sql
SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment
;
```
|is_set_comment 
|---------------
|t

## comment_table

```sql
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
)
;
```
|comment 
|--------
|

```sql
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='pkg'
AND attnum > 0
ORDER BY attname ASC
;
```
|nspname | relname |  attname   |         format_type         |        obj_description        |        col_description        
|--------|---------|------------|-----------------------------|-------------------------------|-------------------------------
|poma    | pkg     | code       | text                        | Информация о пакетах и схемах | код пакета
|poma    | pkg     | id         | integer                     | Информация о пакетах и схемах | идентификатор
|poma    | pkg     | ip         | inet                        | Информация о пакетах и схемах | ip-адрес
|poma    | pkg     | log_name   | text                        | Информация о пакетах и схемах | наименования пользователя
|poma    | pkg     | op         | poma.t_pkg_op               | Информация о пакетах и схемах | стадия
|poma    | pkg     | schemas    | name[]                      | Информация о пакетах и схемах | наименование схемы
|poma    | pkg     | ssh_client | text                        | Информация о пакетах и схемах | ключ
|poma    | pkg     | stamp      | timestamp without time zone | Информация о пакетах и схемах | дата/время создания/изменения
|poma    | pkg     | user_name  | text                        | Информация о пакетах и схемах | имя пользователя
|poma    | pkg     | usr        | text                        | Информация о пакетах и схемах | пользователь
|poma    | pkg     | version    | numeric                     | Информация о пакетах и схемах | версия

## comment_view1

```sql
/*
  Тест comment view
*/
SELECT poma.comment('v','poma.test_view_pkg'
  ,'Представление с краткой информацией о пакетах и схемах'
  , VARIADIC ARRAY[
      'id','идентификатор view'
    , 'code','код пакета view'
    , 'schemas','наименование схемы view'
  ])
;
```
|comment 
|--------
|

```sql
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum) 
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='test_view_pkg'
ORDER BY attname ASC
;
```
|nspname |    relname    | attname | format_type |                    obj_description                     |     col_description     
|--------|---------------|---------|-------------|--------------------------------------------------------|-------------------------
|poma    | test_view_pkg | code    | text        | Представление с краткой информацией о пакетах и схемах | код пакета view
|poma    | test_view_pkg | id      | integer     | Представление с краткой информацией о пакетах и схемах | идентификатор view
|poma    | test_view_pkg | schemas | name[]      | Представление с краткой информацией о пакетах и схемах | наименование схемы view

## comment_view2

```sql
create table poma.vctable1(
id integer primary key
, anno text
)
;
```
```sql
select poma.comment('t','poma.vctable1', 'test table'
, 'anno', 'row anno'
, 'id', 'row id'
)
;
```
|comment 
|--------
|

```sql
create view poma.vcview1 AS
  select *
  , current_date AS date
  from poma.vctable1
;
```
```sql
select poma.comment('v','poma.vcview1', 'test view1'
, 'id', 'row id1'
, 'date', 'cur date'
)
;
```
|comment 
|--------
|

```sql
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum)
FROM pg_class c 
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname IN('vctable1', 'vcview1')
AND attnum > 0
ORDER BY relname, attname ASC
;
```
|nspname | relname  | attname | format_type | obj_description | col_description 
|--------|----------|---------|-------------|-----------------|-----------------
|poma    | vctable1 | anno    | text        | test table      | row anno
|poma    | vctable1 | id      | integer     | test table      | row id
|poma    | vcview1  | anno    | text        | test view1      | row anno
|poma    | vcview1  | date    | date        | test view1      | cur date
|poma    | vcview1  | id      | integer     | test view1      | row id1

## comment_view3

```sql
CREATE VIEW poma.vcview2 AS
  SELECT v.id, v.date, t.anno
  , 1 AS ok
  FROM poma.vcview1 v
  JOIN poma.vctable1 t using(id)
;
```
```sql
SELECT poma.comment('v','poma.vcview2', 'test view2'
, 'ok', 'new filed'
)
;
```
|comment 
|--------
|

```sql
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum)
  FROM pg_class c
  JOIN pg_attribute a ON (a.attrelid = c.oid)
  JOIN pg_namespace n ON (n.oid = c.relnamespace)
 WHERE nspname='poma' AND relname = 'vcview2'
 ORDER BY attname ASC
;
```
|nspname | relname | attname | format_type | obj_description | col_description 
|--------|---------|---------|-------------|-----------------|-----------------
|poma    | vcview2 | anno    | text        | test view2      | row anno
|poma    | vcview2 | date    | date        | test view2      | cur date
|poma    | vcview2 | id      | integer     | test view2      | row id1
|poma    | vcview2 | ok      | integer     | test view2      | new filed

## comment_column

```sql
/*
  Тест comment column
*/
SELECT poma.comment('c', 'poma.pkg.id', 'Тест. Изменение наименования column id')
;
```
|comment 
|--------
|

```sql
SELECT nspname, relname, attname, format_type(atttypid, atttypmod), obj_description(c.oid), col_description(c.oid, a.attnum)
FROM pg_class c
JOIN pg_attribute a ON (a.attrelid = c.oid)
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='pkg' AND attname='id'
ORDER BY attname ASC
;
```
|nspname | relname | attname | format_type |        obj_description        |            col_description             
|--------|---------|---------|-------------|-------------------------------|----------------------------------------
|poma    | pkg     | id      | integer     | Информация о пакетах и схемах | Тест. Изменение наименования column id

## comment_type_enum

```sql
/*
  Тест comment type enum
*/
CREATE TYPE poma.tmp_event_class AS ENUM (
  'create'
, 'update'
, 'delete'
)
;
```
```sql
SELECT poma.comment('E','poma.tmp_event_class','Комментирование типа enum')
;
```
|comment 
|--------
|

```sql
SELECT obj_description(to_regtype('poma.tmp_event_class'))
;
```
|     obj_description      
|--------------------------
|Комментирование типа enum

## comment_type

```sql
/*
  Тест comment type
*/
CREATE TYPE poma.tmp_errordef AS (
  field_code TEXT
, err_code   TEXT
, err_data   TEXT
)
;
```
```sql
SELECT poma.comment('T', 'poma.tmp_errordef', 'Тестовый тип'
 , 'field_code', 'Код поля с ошибкой'
 , 'err_code', 'Код ошибки'
 , 'err_data', 'Данные ошибки'
)
;
```
|comment 
|--------
|

```sql
SELECT nspname, relname, attname, format_type(atttypid, atttypmod)
  , obj_description(to_regtype(nspname||'.'||c.relname))
  , col_description(c.oid, a.attnum) 
FROM pg_class c
JOIN pg_attribute a ON (a.attrelid = c.oid) 
JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE nspname='poma' AND relname='tmp_errordef'
ORDER BY attname ASC
;
```
|nspname |   relname    |  attname   | format_type | obj_description |  col_description   
|--------|--------------|------------|-------------|-----------------|--------------------
|poma    | tmp_errordef | err_code   | text        | Тестовый тип    | Код ошибки
|poma    | tmp_errordef | err_data   | text        | Тестовый тип    | Данные ошибки
|poma    | tmp_errordef | field_code | text        | Тестовый тип    | Код поля с ошибкой

## comment_domain

```sql
/*
  Тест comment domain
*/
CREATE DOMAIN test_domain AS INTEGER
;
```
```sql
SELECT poma.comment('D', 'test_domain', 'Тест комментария DOMAIN')
;
```
|comment 
|--------
|

```sql
SELECT obj_description(to_regtype('test_domain'))
;
```
|    obj_description     
|------------------------
|Тест комментария DOMAIN

## comment_function

```sql
/*
  Test comment function
*/

SELECT poma.comment('f','poma.comment',E'te''st')
;
```
|comment 
|--------
|

```sql
SELECT poma.comment('f','poma.test_arg','all test_arg')
;
```
|comment 
|--------
|

```sql
SELECT p.proname
  , pg_catalog.pg_get_function_identity_arguments(p.oid)
  , obj_description(p.oid, 'pg_proc')
FROM pg_catalog.pg_proc p
WHERE p.proname IN ('comment','test_arg')
ORDER BY proname, pg_get_function_identity_arguments ASC
;
```
|proname  |                    pg_get_function_identity_arguments                    | obj_description 
|---------|--------------------------------------------------------------------------|-----------------
|comment  | a_type character, a_code name, a_comment text, VARIADIC a_columns text[] | te'st
|test_arg |                                                                          | all test_arg
|test_arg | a text                                                                   | all test_arg

## comment_sequence

```sql
/*
  Тест comment sequence
*/
SELECT poma.comment('s', 'poma.pkg_id_seq', 'Тест комментария последовательности pkg_id_seq')
;
```
|comment 
|--------
|

```sql
SELECT obj_description('poma.pkg_id_seq'::regclass)
;
```
|               obj_description                 
|-----------------------------------------------
|Тест комментария последовательности pkg_id_seq

