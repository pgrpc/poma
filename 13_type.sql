/*
    Copyright (c) 2010-2018 Tender.Pro team <it@tender.pro>
    Use of this source code is governed by a MIT-style
    license that can be found in the LICENSE file.

    Типы данных и домены
*/

/* ------------------------------------------------------------------------- */
CREATE DOMAIN d_id AS INTEGER;

CREATE DOMAIN d_code AS TEXT CHECK (VALUE ~ E'^[a-z\\d][a-z\\d\\.\\-_]*$') ;

CREATE DOMAIN d_errcode AS char(5) CHECK (VALUE ~ E'^Y\\d{4}$') ;

CREATE TYPE t_textarr as (fld TEXT[]);
