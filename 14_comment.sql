/*
    Copyright (c) 2018 Alexey Kovrizhkin <lekovr+poma@gmail.com>
    Use of this source code is governed by a MIT-style
    license that can be found in the LICENSE file.

    Create comment for database object
    SELECT comment('n|t|v|c|T|D|f|s', name, comment{, column, column_comment})
*/

-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION comment(
  a_type CHAR(1)
, a_code NAME
, a_comment TEXT DEFAULT NULL
, VARIADIC a_columns TEXT[] DEFAULT NULL
) RETURNS VOID LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_object TEXT;
    v_names TEXT[];
    v_args TEXT;
    v_sql TEXT;
    v_len INTEGER;
  BEGIN
    v_object := CASE
      WHEN a_type = 'n' THEN 'SCHEMA'
      WHEN a_type = 't' THEN 'TABLE'
      WHEN a_type = 'v' THEN 'VIEW'
      WHEN a_type = 'c' THEN 'COLUMN'
      WHEN a_type = 'T' THEN 'TYPE'
      WHEN a_type = 'D' THEN 'DOMAIN'
      WHEN a_type = 'f' THEN 'FUNCTION'
      WHEN a_type = 's' THEN 'SEQUENCE'
      ELSE NULL
    END;
    IF v_object IS NULL THEN
      RAISE EXCEPTION 'Unknown object type: %', a_type;
    END IF;
    IF v_object = 'SCHEMA' THEN
      v_names[1] := COALESCE(a_code, current_schema());
    ELSE
      v_names := parse_ident(a_code);
      IF array_length(v_names, 1) < (CASE WHEN v_object = 'COLUMN' THEN 3 ELSE 2 END) THEN
        -- use current schema if not given
        v_names = array_prepend(current_schema()::TEXT,v_names);
      END IF;
    END IF;
    IF v_names[1] IN ('pg_catalog', 'information_schema') THEN
      RAISE EXCEPTION 'Objects from schema % does not supported', v_names[1];
    END IF;

    IF v_object = 'FUNCTION' THEN
      -- comment all functions with this name in given schema
      FOR v_args IN SELECT pg_catalog.pg_get_function_identity_arguments(p.oid)
        FROM pg_catalog.pg_proc p
        WHERE p.pronamespace = to_regnamespace(v_names[1])
          AND p.proname = v_names[2]
        LOOP
          v_sql := format('COMMENT ON FUNCTION %s.%s(%s) IS %s'
            , v_names[1], v_names[2], v_args, quote_literal(a_comment));
          RAISE DEBUG '%', v_sql;
          EXECUTE v_sql;
      END LOOP;
      IF NOT FOUND THEN
        RAISE EXCEPTION '% %: not found', v_object, a_code;
      END IF;
    ELSIF v_object = 'SCHEMA' THEN
      v_sql := format('COMMENT ON %s %s IS %s', v_object, v_names[1], quote_literal(a_comment));
      RAISE DEBUG '%', v_sql;
      EXECUTE v_sql;
    ELSE
      v_sql := format('COMMENT ON %s %s IS %s', v_object, array_to_string(v_names,'.'), quote_literal(a_comment));
      RAISE DEBUG '%', v_sql;
      EXECUTE v_sql;
    END IF;
    IF v_object NOT IN ('TABLE', 'VIEW', 'TYPE') THEN -- TODO: foreign table
      RETURN;
    END IF;

    -- composite type
    RAISE DEBUG 'READY TO COMMENT COLUMNS';
    -- TODO: fill view column comments from deps

    IF a_columns IS NOT NULL THEN
      v_len := array_length(a_columns, 1);
      IF v_len % 2 <> 0 THEN
        RAISE EXCEPTION '% %: column comment list (%) must contain pairs', v_object, a_code, a_columns;
      END IF;
      FOR v_i IN 1..v_len BY 2 LOOP
        v_sql := format('COMMENT ON COLUMN %s.%s.%s IS %s'
          , v_names[1], v_names[2], a_columns[v_i], quote_literal(a_columns[v_i + 1]));
        RAISE DEBUG '%', v_sql;
        EXECUTE v_sql;
      END LOOP;
    END IF;

    -- Check skipped columns
    SELECT INTO v_args
      string_agg(attname, ', ')
      FROM pg_catalog.pg_attribute
     WHERE attrelid = array_to_string(v_names, '.')::regclass
       AND attnum > 0
       AND NOT attisdropped
       AND col_description(attrelid, attnum) IS NULL
    ;
    IF v_args IS NOT NULL THEN
      RAISE WARNING '% %: columns %s still not commented', v_object, a_code, v_args;
    END IF;
    RETURN;
  END;
$_$;

SELECT comment('f', 'comment', 'Create comment for database object');
