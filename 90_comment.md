#  poma/90_comment
## poma/90_comment

```sql
/*
  Test comment schema
*/
SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment
;
```
|is_set_comment 
|---------------
|t

## poma/90_comment

```sql
/*
  Test comment function
*/
SELECT p.proname
, pg_catalog.pg_get_function_identity_arguments(p.oid)
, obj_description(p.oid, 'pg_proc')
  FROM pg_catalog.pg_proc p
 WHERE p.proname IN ('comment','test_arg')
;
```
|proname  |                    pg_get_function_identity_arguments                    | obj_description 
|---------|--------------------------------------------------------------------------|-----------------
|comment  | a_type character, a_code name, a_comment text, VARIADIC a_columns text[] | te'st
|test_arg |                                                                          | all test_arg
|test_arg | a text                                                                   | all test_arg

## poma/90_comment

```sql
/*
  Тест comment table
*/


;
```
