/*

    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
    [SQL_LICENSE]

    Компиляция и установка пакетов
*/


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION array_remove(
  a ANYARRAY
, b ANYELEMENT
) RETURNS ANYARRAY IMMUTABLE LANGUAGE 'sql' AS
$_$
  -- a: массив
  -- b: элемент
SELECT array_agg(x) FROM unnest($1) x WHERE x <> $2;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION test(a_code TEXT) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:  сообщение для теста
  BEGIN
    -- RAISE WARNING parsed for test output
    IF a_code IS NULL THEN
      RAISE WARNING '::';
    ELSE
      RAISE WARNING '::%', 't/'||a_code;
    END IF;
    -- RETURN saved to .md
    RETURN a_code;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg(a_code TEXT) RETURNS pkg STABLE LANGUAGE 'sql' AS
$_$
  -- a_code:  пакет
  SELECT * FROM poma.pkg WHERE code = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_references(
  a_is_on  BOOL
, a_pkg    name
, a_schema name DEFAULT NULL
) RETURNS SETOF TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_is_on:  флаг активности
  -- a_pkg:    пакет
  -- a_schema: связанная схема
  DECLARE
    r              RECORD;
    v_sql          TEXT;
    v_self_default TEXT;
  BEGIN
    -- defaults
    FOR r IN SELECT * 
      FROM poma.pkg_default_protected
      WHERE pkg = a_pkg
        AND schema IS NOT DISTINCT FROM a_schema
        AND is_active = NOT a_is_on
    LOOP
      v_sql := CASE WHEN a_is_on THEN
        format('ALTER TABLE wsd.%s ALTER COLUMN %s SET DEFAULT %s'
          , quote_ident(r.wsd_rel) 
          , quote_ident(r.wsd_col) 
          , r.func
          )
      ELSE       
        format('ALTER TABLE wsd.%s ALTER COLUMN %s DROP DEFAULT'
        , quote_ident(r.wsd_rel) 
        , quote_ident(r.wsd_col) 
        )
      END;
      IF r.wsd_rel = 'pkg_default_protected' THEN
        v_self_default := v_sql; -- мы внутри цикла по этой же таблице
      ELSE
        EXECUTE v_sql;
      END IF;
      RETURN NEXT v_sql;
    END LOOP;
    IF v_self_default IS NOT NULL THEN
      EXECUTE v_self_default;
    END IF;
    UPDATE poma.pkg_default_protected SET is_active = a_is_on
      WHERE pkg = a_pkg
        AND schema IS NOT DISTINCT FROM a_schema
        AND is_active = NOT a_is_on
    ;
    
    -- fkeys
    
        -- Перед удалением пакета - удаление всех присоединенных пакетом зарегистрированных FK
        -- rel in (select rel from wsd.pkg_fkey_required_by where required_by = a_pkg
        -- После создания пакета - создание всех еще несуществующих зарегистрированных FK присоединенных пакетом таблиц 
      --  NOT is_active AND rel not in (select rel from wsd.pkg_fkey_required_by where required_by not in (select code from ws.pkg)
    
    v_self_default := NULL;
    FOR r IN SELECT * 
      FROM poma.pkg_fkey_protected
      WHERE is_active = NOT a_is_on
        AND CASE WHEN a_is_on THEN
          rel NOT IN (SELECT rel FROM poma.pkg_fkey_required_by WHERE required_by NOT IN (SELECT code FROM poma.pkg))
            AND EXISTS (SELECT 1 FROM poma.pkg WHERE code = pkg) and EXISTS (SELECT 1 FROM poma.pkg where schemas @> array[pkg_fkey_protected.schema]::name[])
          ELSE
          (pkg = a_pkg AND schema IS NOT DISTINCT FROM a_schema)
          OR rel IN (SELECT rel FROM poma.pkg_fkey_required_by WHERE required_by = a_pkg)
        END
    LOOP
      v_sql := CASE WHEN a_is_on THEN
        format('ALTER TABLE wsd.%s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES %s'
          , quote_ident(r.wsd_rel)
          , r.wsd_rel || '_' || replace(regexp_replace(r.wsd_col, E'\\s','','g'), ',', '_') || '_fkey'
          , r.wsd_col -- может быть список колонок через запятую 
          , r.rel
          )
      ELSE       
        format('ALTER TABLE wsd.%s DROP CONSTRAINT %s'
          , quote_ident(r.wsd_rel)
          , r.wsd_rel || '_' || replace(regexp_replace(r.wsd_col, E'\\s','','g'), ',', '_') || '_fkey'
        )
      END;
      IF r.wsd_rel = 'pkg_fkey_protected' THEN
        v_self_default := v_sql; -- мы внутри цикла по этой же таблице
      ELSE
        EXECUTE v_sql;
      END IF;
      RETURN NEXT v_sql;
    END LOOP;
    IF v_self_default IS NOT NULL THEN
      EXECUTE v_self_default;
    END IF;
    UPDATE poma.pkg_fkey_protected SET is_active = a_is_on
      WHERE is_active = NOT a_is_on
        AND CASE WHEN a_is_on THEN
          rel NOT IN (SELECT rel FROM poma.pkg_fkey_required_by WHERE required_by NOT IN (SELECT code FROM poma.pkg))
            AND EXISTS (SELECT 1 FROM poma.pkg WHERE code = pkg) and EXISTS (SELECT 1 FROM poma.pkg where schemas @> array[pkg_fkey_protected.schema]::name[])
          ELSE
          (pkg = a_pkg AND schema IS NOT DISTINCT FROM a_schema)
          OR rel IN (SELECT rel FROM poma.pkg_fkey_required_by WHERE required_by = a_pkg)
        END
    ;
    RETURN;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_op_before(
  a_op         t_pkg_op
, a_code       name
, a_schema     name
, a_log_name   TEXT
, a_user_name  TEXT
, a_ssh_client TEXT
) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_op:          стадия
  -- a_code:        пакет 
  -- a_schema:      список схем
  -- a_log_name:    имя 
  -- a_user_name:   имя пользователя 
  -- a_ssh_client:  ключ
  DECLARE
    r_pkg          poma.pkg%ROWTYPE;
    r              RECORD;
    v_sql          TEXT;
    v_self_default TEXT;
    v_pkgs         TEXT;
  BEGIN
    r_pkg := poma.pkg(a_code);
    CASE a_op
      WHEN 'create' THEN
        IF r_pkg IS NOT NULL AND a_schema = ANY(r_pkg.schemas)THEN
          RAISE EXCEPTION '***************** Package % schema % installed already at % (%) *****************'
          , a_code, a_schema, r_pkg.stamp, r_pkg.id
          ;
        END IF;
        IF r_pkg IS NULL THEN
          INSERT INTO poma.pkg (id, code, schemas, log_name, user_name, ssh_client, op) VALUES 
            (NEXTVAL('poma.pkg_id_seq'), a_code, ARRAY[a_schema], a_log_name, a_user_name, a_ssh_client, a_op)
            RETURNING * INTO r_pkg
          ;
        ELSE 
          UPDATE poma.pkg SET
            id          = NEXTVAL('poma.pkg_id_seq') -- runs after rule
          , schemas     = array_append(schemas, a_schema)
          , log_name    = a_log_name
          , user_name   = a_user_name
          , ssh_client  = a_ssh_client
          , stamp       = now()
          , op          = a_op
          WHERE code = a_code
            RETURNING * INTO r_pkg
          ;
        END IF;
        r_pkg.schemas = ARRAY[a_schema]; -- save schema in log
        INSERT INTO poma.pkg_log VALUES (r_pkg.*);
      WHEN 'build' THEN
        UPDATE poma.pkg SET
          id            = NEXTVAL('poma.pkg_id_seq') -- runs after rule
        , log_name    = a_log_name
        , user_name   = a_user_name
        , ssh_client  = a_ssh_client
        , stamp       = now()
        , op          = a_op
        WHERE code = a_code
          RETURNING * INTO r_pkg
        ;
        IF NOT FOUND THEN
          RAISE EXCEPTION '***************** Package % schema % does not found *****************'
          , a_code, a_schema
          ;
        END IF;
        r_pkg.schemas = ARRAY[a_schema]; -- save schema in log
        INSERT INTO poma.pkg_log VALUES (r_pkg.*);
      WHEN 'drop', 'erase' THEN
        SELECT INTO v_pkgs
          array_to_string(array_agg(required_by::TEXT),', ')
          FROM poma.pkg_required_by 
          WHERE code = a_code
        ;
        IF v_pkgs IS NOT NULL THEN
          RAISE EXCEPTION '***************** Package % is required by others (%) *****************', a_code, v_pkgs;
        END IF;
        PERFORM poma.pkg_references(FALSE, a_code, a_schema);
    END CASE;
    RETURN 'Begin ' || a_op || ' for '|| a_code;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_op_after(
  a_op         t_pkg_op
, a_code       name
, a_schema     name
, a_log_name   TEXT
, a_user_name  TEXT
, a_ssh_client TEXT
) RETURNS TEXT VOLATILE LANGUAGE 'plpgsql' AS
$_$
  -- a_op:           стадия
  -- a_code:         пакет
  -- a_schema:       список схем
  -- a_log_name:     имя
  -- a_user_name:    имя пользователя
  -- a_ssh_client:   ключ
  DECLARE
    r_pkg          poma.pkg%ROWTYPE;
    r              RECORD;
    v_sql          TEXT;
    v_self_default TEXT;
  BEGIN
    r_pkg := poma.pkg(a_code);
    CASE a_op
      WHEN 'create' THEN
        IF a_code = 'poma' AND a_schema = 'poma' THEN
          INSERT INTO poma.pkg (id, code, schemas, log_name, user_name, ssh_client, op) VALUES 
            (NEXTVAL('poma.pkg_id_seq'), a_code, ARRAY[a_schema], a_log_name, a_user_name, a_ssh_client, a_op)
            RETURNING * INTO r_pkg
          ;
          r_pkg.schemas = ARRAY[a_schema]; -- save schema in log
          INSERT INTO poma.pkg_log VALUES (r_pkg.*);
        END IF;
        PERFORM poma.pkg_references(TRUE, a_code, a_schema);
        UPDATE poma.pkg SET op = 'done' WHERE code = a_code;
      WHEN 'drop', 'erase' THEN
        INSERT INTO poma.pkg_log (id, code, schemas, log_name, user_name, ssh_client, op)
          VALUES (NEXTVAL('poma.pkg_id_seq'), a_code, ARRAY[a_schema], a_log_name, a_user_name, a_ssh_client, a_op)
        ;


        IF a_op = 'erase' AND a_schema <> 'poma' THEN
          DELETE FROM poma.pkg_script_protected  WHERE pkg = a_schema;
          DELETE FROM poma.pkg_default_protected WHERE pkg = a_schema;
          DELETE FROM poma.pkg_fkey_protected    WHERE pkg = a_schema;
          DELETE FROM poma.pkg_fkey_required_by  WHERE required_by = a_schema;
        END IF;
        DELETE FROM poma.pkg_required_by  WHERE required_by = a_schema;
        IF r_pkg.schemas = ARRAY[a_schema] THEN
          -- last/single schema
          DELETE FROM poma.pkg WHERE code = a_code;
        ELSE  
          UPDATE poma.pkg SET
            schemas = poma.array_remove(schemas, a_schema)
            WHERE code = a_code
          ;
        END IF;
      WHEN 'build' THEN
        NULL;
    END CASE;
    RETURN 'End ' || a_op || ' for '|| a_code;
  END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_require(a_code TEXT) RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_code:
  BEGIN
    RAISE NOTICE 'TODO: function needs code';
    RETURN NULL;
  END
$_$;

CREATE OR REPLACE FUNCTION patch(
  a_pkg TEXT
, a_md5 TEXT
, a_file TEXT
, a_prefix TEXT
, a_blank TEXT DEFAULT 'blank.sql'
) RETURNS TEXT LANGUAGE plpgsql AS $_$
DECLARE
  v_md5 TEXT;
  v_name TEXT;
BEGIN
  v_name := substr(a_file, length(a_prefix) + 1);
  IF (a_prefix || v_name) <> a_file THEN
    RAISE WARNING '%: no prefix % (%)', a_file, a_prefix, v_name;
    v_name := a_file;
  END IF;
  SELECT INTO v_md5 csum FROM poma.pkg_script_protected WHERE pkg = a_pkg AND file = v_name;
  IF NOT FOUND THEN
    -- patch() вызывается в той же транзакции, что и сам файл
    INSERT INTO poma.pkg_script_protected (pkg, file, csum) VALUES (a_pkg, v_name, a_md5);
    RETURN a_file;
  ELSIF v_md5 <> a_md5 THEN
    RAISE WARNING '% md5 changed: from % to %', a_file, v_md5, a_md5;
  END IF;
  RETURN a_blank;
END;
$_$; -- VOLATILE
COMMENT ON FUNCTION patch(TEXT,TEXT,TEXT,TEXT,TEXT) IS 'Регистрация скриптов обновления БД';
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION raise_on_errors(errors TEXT) RETURNS void LANGUAGE 'plpgsql' AS
$_$
BEGIN
  IF errors <> '' THEN
    RAISE EXCEPTION E'\n%', errors;
  END IF;
END
$_$;

