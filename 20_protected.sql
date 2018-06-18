/*
    Copyright (c) 2010-2018 Tender.Pro team <it@tender.pro>
    Use of this source code is governed by a MIT-style
    license that can be found in the LICENSE file.

    Схема изменяемых в процессе эксплуатации данных и ее базовые объекты
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE pkg_script_protected (
  pkg         name
, file        TEXT
, csum        TEXT NOT NULL
, created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT  pkg_script_protected_pkey PRIMARY KEY (pkg, file)
);


/* ------------------------------------------------------------------------- */
CREATE TABLE pkg_fkey_protected (
  pkg         name
, wsd_rel     name
, wsd_col     text
, rel         name
, is_active   bool NOT NULL DEFAULT FALSE
, schema      name -- NOT NULL только для 2й схемы пакета
, CONSTRAINT pkg_fkey_protected_pkey PRIMARY KEY (pkg, wsd_rel, wsd_col)
);

/* ------------------------------------------------------------------------- */
CREATE TABLE pkg_fkey_required_by (
  pkg         name 
, rel         name
, required_by name
, CONSTRAINT pkg_fkey_required_by_pkey PRIMARY KEY (pkg, rel, required_by)
);
-- TODO: В триггере на INSERT проверять, что в wsd.pkg_fkey_protected есть такая пара pkg,rel

/* ------------------------------------------------------------------------- */
CREATE TABLE pkg_default_protected (
  pkg         name
, wsd_rel     name NOT NULL
, wsd_col     text NOT NULL
, func        name
, is_active   bool NOT NULL DEFAULT FALSE
, schema      name NOT NULL DEFAULT current_schema()
, CONSTRAINT pkg_default_protected_pkey PRIMARY KEY (pkg, wsd_rel, wsd_col)
);

/* ------------------------------------------------------------------------- */
