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
WHERE nspname='poma' AND relname='pkg' AND attname in ('id','code','schemas') 
ORDER BY attname ASC
;
```
|nspname | relname | attname | format_type |        obj_description        |  col_description   
|--------|---------|---------|-------------|-------------------------------|--------------------
|poma    | pkg     | code    | text        | Информация о пакетах и схемах | код пакета
|poma    | pkg     | id      | integer     | Информация о пакетах и схемах | идентификатор
|poma    | pkg     | schemas | name[]      | Информация о пакетах и схемах | наименование схемы

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

