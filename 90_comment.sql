/*
    Тесты comment
*/

-- ----------------------------------------------------------------------------
SELECT poma.test('comment_schema'); -- BOT
/*
  Тест pkg_op_before
*/
SELECT poma.comment('n','poma','Postgresql projects Makefile'); -- EOT

\dn+
-- EOT
-- current schema
--SELECT comment('n',NULL,'current=ok');
-- named schema
--SELECT comment('n','rpc','rpc=ok');

-- ----------------------------------------------------------------------------

