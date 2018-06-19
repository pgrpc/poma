#  poma/90_comment
## poma/90_comment

```sql
SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment
;
```
|is_set_comment 
|---------------
|t

