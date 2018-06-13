INSERT INTO poma.pkg (id, code, schemas, log_name, user_name, ssh_client, op) 
VALUES (NEXTVAL('poma.pkg_id_seq'), 'poma', ARRAY['poma'], '', '', '', 'create');
