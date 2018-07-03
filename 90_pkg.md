#  poma/90_pkg
## pkg_op_before

```sql
/*
  Тест pkg_op_before
*/
SELECT poma.pkg_op_before('create', 'test_poma', 'test_poma', '', '', '', 'blank.sql')
;
```
|    pkg_op_before     
|----------------------
|test_poma-create.psql

## pkg_op_after

```sql
/*
  Тест pkg_op_after
*/
SELECT poma.pkg_op_after('create', 'test_poma', 'test_poma', '', '', '', 'noskip','blank.sql')
;
```
|    pkg_op_after      
|----------------------
|test_poma-create.psql

## pkg

```sql
/*
  Тест pkg
*/
SELECT code, schemas, op FROM poma.pkg('test_poma')
;
```
|  code    |   schemas   |  op  
|----------|-------------|------
|test_poma | {test_poma} | done

## pkg_with_non_existent_schema

```sql
/*
  Тест pkg с несуществующей схемой. Ожидаемый результат: 0 строк.
*/
SELECT count(1) FROM poma.pkg('non_existent_schema')
;
```
|count 
|------
|    0

## patch

```sql
/*
  Тест patch
*/
SELECT poma.patch('poma_test','a83084dc0332dbc4d1f7a6c7dc7b4993','sql/poma_test/20_xxtest_once.sql','sql/poma_test/','.build/empty_test.sql')
;
```
|             patch               
|---------------------------------
|sql/poma_test/20_xxtest_once.sql

```sql
SELECT poma.patch('poma_test','a83084dc0332dbc4d1f7a6c7dc7b4993','sql/poma_test/20_xxtest_once.sql','sql/poma_test/','.build/empty_test.sql')
;
```
|        patch         
|----------------------
|.build/empty_test.sql

## raise_on_errors

```sql
/*
  Тест raise_on_errors
*/
SELECT poma.raise_on_errors('')
;
```
|raise_on_errors 
|----------------
|

