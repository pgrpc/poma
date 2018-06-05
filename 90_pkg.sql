\set TEST poma/90_pkg
\set TESTOUT .build/poma/90_pkg.md
-- ----------------------------------------------------------------------------
-- test_begin
\set QUIET on
-- ----------------------------------------------------------------------------

\set OUTW '| echo ''```sql'' >> ':TESTOUT' ; cat >> ':TESTOUT' ; echo '';\n```'' >> ':TESTOUT
\set OUTT '| echo -n ''##'' >> ':TESTOUT' ; cat >> ':TESTOUT
\set OUTG '| /usr/bin/gawk ''{ gsub(/--\\+--/, "--|--"); gsub(/^[ |-]/, "|"); print }'' >> ':TESTOUT

\o :TESTOUT
\qecho '# ' :TEST
\o

-- ----------------------------------------------------------------------------
SAVEPOINT package_test;
\set QUIET off
\qecho '# ----------------------------------------------------------------------------'
\qecho '#' :TEST

-- test_begin
-- ----------------------------------------------------------------------------
/*
    Тесты
*/

/* ------------------------------------------------------------------------- */
SELECT poma.test('pkg_require');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест pkg_require
*/
SELECT * FROM poma.pkg_require('test')
\w :OUTW
\g :OUTG
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('array_remove');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест array_remove
*/
SELECT * FROM poma.array_remove(ARRAY['poma-sample', 'poma', 'mega_scheme'], 'mega_scheme')
\w :OUTW
\g :OUTG
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('pkg_op_before');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест pkg_op_before
*/
SELECT poma.pkg_op_before('create', 'test_poma', 'test_poma', '', '', '')
\w :OUTW
\g :OUTG
--TODO: RAISE EXCEPTION отработать utils.exception_test из pgm
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('pkg_op_after');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест pkg_op_after
*/
SELECT poma.pkg_op_after('create', 'test_poma', 'test_poma', '', '', '')
\w :OUTW
\g :OUTG
--TODO: RAISE EXCEPTION отработать utils.exception_test из pgm
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('pkg');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест pkg
*/
SELECT code, schemas, op FROM poma.pkg('test_poma')
\w :OUTW
\g :OUTG
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('patch');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест patch
*/
SELECT poma.patch('poma_test','a83084dc0332dbc4d1f7a6c7dc7b4993','sql/poma_test/20_xxtest_once.sql','sql/poma_test/','.build/empty_test.sql')
\w :OUTW
\g :OUTG
SELECT poma.patch('poma_test','a83084dc0332dbc4d1f7a6c7dc7b4993','sql/poma_test/20_xxtest_once.sql','sql/poma_test/','.build/empty_test.sql')
\w :OUTW
\g :OUTG
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
SELECT poma.test('raise_on_errors');
\qecho '#  t/':TEST
SELECT :'TEST'
\set QUIET on
\pset t on
\g :OUTT
\pset t off
\set QUIET on
/*
  Тест raise_on_errors
*/
SELECT poma.raise_on_errors('')
\w :OUTW
\g :OUTG
--TODO: после подключения pgm/utils можно отработать тест с исключением,- utils.exception_test
/* ------------------------------------------------------------------------- */

\! diff sql/poma/90_pkg.md .build/poma/90_pkg.md | tr "\t" ' ' > .build/errors.diff
-- ----------------------------------------------------------------------------
-- test_end

\set QUIET on

ROLLBACK TO SAVEPOINT package_test;
\set ERRORS `cat .build/errors.diff`
\pset t on
SELECT poma.raise_on_errors(:'ERRORS');
\pset t off
\set QUIET off

-- test_end
-- ----------------------------------------------------------------------------
