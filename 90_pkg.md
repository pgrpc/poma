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

