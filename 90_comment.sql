/*
    Тесты comment
*/

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_schema'); -- BOT
/*
  Тест comment schema
*/
SELECT poma.comment('n','poma','Postgresql projects Makefile');
SELECT (CASE WHEN (select obj_description(to_regnamespace('poma'))) = 'Postgresql projects Makefile' THEN TRUE ELSE FALSE END) AS is_set_comment;  -- EOT
-- ----------------------------------------------------------------------------




/*
-- type
set local search_path = poma,public;
SELECT comment('T','t_pg_proc_info','type comm'
,	'schema', 's anno'
, 'name',   'n anno'
, 'rt_oid', 'o_anno'
);
\dT+ poma.t_pg_proc_info
\d+ poma.t_pg_proc_info

-- current schema
SELECT comment('n',NULL,'current=ok');
-- named schema
SELECT comment('n','rpc','rpc=ok');
\dn+

create or replace function rpc.test_arg() returns void language sql as
$_$ 
 SET CLIENT_MIN_MESSAGES = 'DEBUG';
$_$;
create or replace function rpc.test_arg(a TEXT) returns void language sql as
$_$ 
 SET CLIENT_MIN_MESSAGES = a; --'INFO';
$_$;

-- func
SELECT poma.comment('f','poma.comment',E'te''st');
SELECT poma.comment('f','rpc.test_arg','all test_arg');

SELECT p.proname
, pg_catalog.pg_get_function_identity_arguments(p.oid)
, obj_description(p.oid, 'pg_proc')
  FROM pg_catalog.pg_proc p
 WHERE p.proname IN ('comment','test_arg')
;

*/
