/*
    Тесты
*/

/* ------------------------------------------------------------------------- */
SELECT poma.test('pkg_require'); -- BOT
/*
  Тест pkg_require
*/
SELECT * FROM poma.pkg_require('test'); -- EOT
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('array_remove'); -- BOT
/*
  Тест array_remove
*/
SELECT * FROM poma.array_remove(ARRAY['poma-sample', 'poma', 'mega_scheme'], 'mega_scheme'); -- EOT
/* ------------------------------------------------------------------------- */

