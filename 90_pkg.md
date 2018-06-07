#  poma/90_pkg
## poma/90_pkg

```sql
/*
  Тест pkg_require
*/
SELECT * FROM poma.pkg_require('test')
;
```
|pkg_require 
|------------
|

## poma/90_pkg

```sql
/*
  Тест array_remove
*/
SELECT * FROM poma.array_remove(ARRAY['poma-sample', 'poma', 'mega_scheme'], 'mega_scheme')
;
```
|   array_remove    
|-------------------
|{poma-sample,poma}

## poma/90_pkg

```sql
/*
  Тест pkg_op_before
*/
SELECT poma.pkg_op_before('create', 'test_poma', 'test_poma', '', '', '')
;
```
|    pkg_op_before     
|----------------------
|test_poma-create.psql

## poma/90_pkg

```sql
/*
  Тест pkg_op_after
*/
SELECT poma.pkg_op_after('create', 'test_poma', 'test_poma', '', '', '')
;
```
|    pkg_op_after      
|----------------------
|test_poma-create.psql

## poma/90_pkg

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

## poma/90_pkg

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

## poma/90_pkg

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

## poma/90_pkg

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

