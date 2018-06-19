#  poma/90_comment
## poma/90_comment

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

## poma/90_comment

```sql
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
WHERE nspname='poma' AND relname='pkg'
ORDER BY attname ASC
;
```
|nspname | relname |  attname   |         format_type         |        obj_description        |        col_description        
|--------|---------|------------|-----------------------------|-------------------------------|-------------------------------
|poma    | pkg     | cmax       | cid                         | Информация о пакетах и схемах | 
|poma    | pkg     | cmin       | cid                         | Информация о пакетах и схемах | 
|poma    | pkg     | code       | text                        | Информация о пакетах и схемах | код пакета
|poma    | pkg     | ctid       | tid                         | Информация о пакетах и схемах | 
|poma    | pkg     | id         | integer                     | Информация о пакетах и схемах | идентификатор
|poma    | pkg     | ip         | inet                        | Информация о пакетах и схемах | ip-адрес
|poma    | pkg     | log_name   | text                        | Информация о пакетах и схемах | наименования пользователя
|poma    | pkg     | op         | t_pkg_op                    | Информация о пакетах и схемах | стадия
|poma    | pkg     | schemas    | name[]                      | Информация о пакетах и схемах | наименование схемы
|poma    | pkg     | ssh_client | text                        | Информация о пакетах и схемах | ключ
|poma    | pkg     | stamp      | timestamp without time zone | Информация о пакетах и схемах | дата/время создания/изменения
|poma    | pkg     | tableoid   | oid                         | Информация о пакетах и схемах | 
|poma    | pkg     | user_name  | text                        | Информация о пакетах и схемах | имя пользователя
|poma    | pkg     | usr        | text                        | Информация о пакетах и схемах | пользователь
|poma    | pkg     | version    | numeric                     | Информация о пакетах и схемах | версия
|poma    | pkg     | xmax       | xid                         | Информация о пакетах и схемах | 
|poma    | pkg     | xmin       | xid                         | Информация о пакетах и схемах | 

## poma/90_comment

```sql
/*
  Тест comment view
*/
SELECT poma.comment('v','poma.test_view_pkg'
  ,'Представление с краткой информацией о пакетах и схемах'
  , VARIADIC ARRAY[
      'id','идентификатор'
    , 'code','код пакета'
    , 'schemas','наименование схемы'
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
|nspname |    relname    | attname | format_type |                    obj_description                     |  col_description   
|--------|---------------|---------|-------------|--------------------------------------------------------|--------------------
|poma    | test_view_pkg | code    | text        | Представление с краткой информацией о пакетах и схемах | код пакета
|poma    | test_view_pkg | id      | integer     | Представление с краткой информацией о пакетах и схемах | идентификатор
|poma    | test_view_pkg | schemas | name[]      | Представление с краткой информацией о пакетах и схемах | наименование схемы

## poma/90_comment

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

## poma/90_comment

```sql
/*
  Тест comment type
*/
SELECT poma.comment('T','poma.t_pg_proc_info','Информация о функции')
;
```
|comment 
|--------
|

```sql
SELECT n.nspname as "Schema",
  pg_catalog.format_type(t.oid, NULL) AS "Name",
  pg_catalog.obj_description(t.oid, 'pg_type') as "Description"
FROM pg_catalog.pg_type t
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'poma' AND pg_catalog.format_type(t.oid, NULL) ='t_pg_proc_info'
;
```
|Schema |      Name      |     Description      
|-------|----------------|----------------------
|poma   | t_pg_proc_info | Информация о функции

## poma/90_comment

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

