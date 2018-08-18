#    Copyright (c) 2018 Aleksei Kovrizhkin <lekovr+poma@gmail.com>
#    Use of this source code is governed by a MIT-style
#    license that can be found in the LICENSE file.

SHELL         = /bin/bash

# Dependencies
AWK          ?= $(shell command -v gawk 2> /dev/null)
MD5          ?= $(shell command -v md5 2> /dev/null)
MD5SUM       ?= $(shell command -v md5sum 2> /dev/null)
DIFF         ?= $(shell command -v diff 2> /dev/null)

BUILD_DIR    ?= .build
EMPTY_FILE   ?= empty.sql
SQL_EMPTY    ?= $(BUILD_DIR)/$(EMPTY_FILE)
CFG          ?= .env

# Raise error on create/drop attempt on pkg which exists/not exists (else skip silent)
POMA_STRICT  ?=

# App name, default for db user/name
PRG          ?= $(shell basename $$PWD)

# Rollback will be added if this is expty
DO_COMMIT    ?= 1

# -----------------------------------------------------------------------------
# Config data

# Postgresql variables
PGDATABASE   ?= $(PRG)
PGUSER       ?= $(PRG)
PGAPPNAME    ?= $(PRG)
PGHOST       ?= localhost
PGPORT       ?= 5432
PGSSLMODE    ?= disable
PGPASSWORD   ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 | head -c14; echo)

#Change to disable *once.sql script execution
RUNONCE      ?= yes

# Database template
DB_TEMPLATE  ?= template1
# Database dump for import on create
DB_SOURCE    ?=

# tool to run psql (psql or docker)
PSQL_VIA     ?= psql

# Running postgresql container name for `docker exec`
DB_CONTAINER ?= dcape_db_1

# SQL package list
POMA_PKG     ?= POMA_PKG_must_be_set_in_parent_Makefile

# build log
LOGFILE      ?= $(BUILD_DIR)/build.log

# -----------------------------------------------------------------------------
# THERE IS NOTHING TO CHANGE BELOW
# -----------------------------------------------------------------------------

# SQL files mask
MASK_CREATE  ?= [1-9]?_*.sql
MASK_BUILD   ?= 1[4-9]_*.sql [3-6,9]?_*.sql [2,4,8]*_once.sql
MASK_TEST    ?= 9?_*.sql
MASK_DROP    ?= 00_*.sql 02_*.sql
MASK_ERASE   ?= 0?_*.sql

-include $(CFG)
export

# TODO: check psql
## check if all dependencies are satisfied
poma-deps:
ifeq ($(AWK),)
	$(error "gawk is not available, please install it")
else
	@#echo "$(AWK) found."
endif
ifeq ($(MD5SUM),)
ifeq ($(MD5),)
	$(error "gawk is not available, please install it")
else
	@#echo "$(MD5) found."
	MD5SUM = $(MD5) -r
endif
else
	@#echo "$(MD5SUM) found."
endif
ifeq ($(DIFF),)
	$(error "diff is not available, please install it")
else
	@#echo "$(DIFF) found."
endif

## Run poma create for default package list
poma-create: poma-create-default

## Run poma build for default package list
poma-build: poma-build-default

## Run poma recreate for default package list
poma-recreate: poma-recreate-default

## Run poma test for default package list
poma-test: poma-test-default

## Run poma drop for default package list
poma-drop: poma-drop-default

## Run poma erase for default package list
poma-erase: poma-erase-default

## Run poma create for named package list
poma-create-%: MASK = $(MASK_CREATE)
poma-create-%: $(BUILD_DIR)/create.psql
	@echo "** $@ ** "

poma-build-%: MASK = $(MASK_BUILD)
poma-build-%: $(BUILD_DIR)/build.psql
	@echo "** $@ ** "

poma-recreate-%: MASK = $(MASK_DROP)
poma-recreate-%: $(BUILD_DIR)/recreate.psql
	@echo "** $@ ** "

poma-test-%: MASK = $(MASK_TEST)
poma-test-%: $(BUILD_DIR)/test.psql
	@echo "** $@ ** "

poma-drop-%: MASK = $(MASK_DROP)
poma-drop-%: $(BUILD_DIR)/drop.psql
	@echo "** $@ ** "

poma-erase-%: MASK = $(MASK_ERASE)
poma-erase-%: $(BUILD_DIR)/erase.psql
	@echo "** $@ ** "

poma-install: POMA_PKG=poma
poma-install: poma-create-poma

poma-uninstall: POMA_PKG=poma
poma-uninstall: poma-erase-poma


# https://stackoverflow.com/a/786530
reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

# generate MODE.psql file
$(BUILD_DIR)/%.psql: $(BUILD_DIR) $(SQL_EMPTY) poma-deps
	@echo "** $@ / $(POMA_PKG) ** "
	@mode=$* ; \
	echo "-- $$mode: $(POMA_PKG) --" > $@ ; \
	if [[ "$$mode" == "drop" || "$$mode" == "erase" || "$$mode" == "recreate" ]] ; then \
		plist="$(call reverse,$(POMA_PKG))" ; else plist="$(POMA_PKG)" ; \
	fi ; \
	if [[ "$(POMA_STRICT)" ]] ; then blank=NULL ; else blank="'$(EMPTY_FILE)'" ; fi ; \
	if [[ "$$mode" == "recreate" ]] ; then m=drop ; else m=$$mode ; fi ; \
	for p in $$plist ; do \
		$(MAKE) -s  $(BUILD_DIR)/$$p-$$m.psql MASK="$(MASK)" PKG=$$p MODE=$$m ; \
		if [[ $$m == "test" ]] ; then \
			echo "\i $(BUILD_DIR)/$$p-$$m.psql" >> $@ ; \
			continue ; \
		fi ; \
		if [[ $$p != "poma" || $$m != "create" ]] ; then \
			echo "SELECT poma.pkg_op_before('$$m', '$$p', '$$p', '$$LOGNAME', '$$USERNAME', '$$SSH_CLIENT', $$blank) \gset" >> $@ ; \
		else  \
			echo "\set pkg_op_before $$p-$$m.psql" >> $@ ; \
		fi ; \
		echo "\i $(BUILD_DIR)/:pkg_op_before" >> $@ ; \
		if [[ $$p != "poma" || $$m == "build" || $$m == "create" ]] ; then \
			echo "SELECT poma.pkg_op_after('$$m', '$$p', '$$p', '$$LOGNAME', '$$USERNAME', '$$SSH_CLIENT', :'pkg_op_before', $$blank);" >> $@ ; \
		fi ; \
	done ; \
	if [[ "$$mode" == "recreate" ]] ; then \
		m=create ; \
		for p in $(POMA_PKG) ; do \
			$(MAKE) -s  $(BUILD_DIR)/$$p-$$m.psql MASK="$(MASK_CREATE)" PKG=$$p MODE=$$m ; \
			if [[ $$p != "poma" ]] ; then \
				echo "SELECT poma.pkg_op_before('$$m', '$$p', '$$p', '$$LOGNAME', '$$USERNAME', '$$SSH_CLIENT', $$blank) \gset" >> $@ ; \
			else  \
				echo "\set pkg_op_before $$p-$$m.psql" >> $@ ; \
			fi ; \
			echo "\i $(BUILD_DIR)/:pkg_op_before" >> $@ ; \
			echo "SELECT poma.pkg_op_after('$$m', '$$p', '$$p', '$$LOGNAME', '$$USERNAME', '$$SSH_CLIENT', :'pkg_op_before', $$blank);" >> $@ ; \
		done ; \
	fi
	@[[ "$(DO_COMMIT)" ]] || echo "ROLLBACK; BEGIN;" >> $@
	@cp $@ $@.back
	@if [[ "$(PSQL_VIA)" != "docker" ]] ; then \
	  $(POMA_LOG_PARSER) ; \
	    psql --no-psqlrc --single-transaction -v VERBOSITY=terse \
	     -P footer=off -v ON_ERROR_STOP=1 -f $@ 3>&1 1>$$LOGFILE 2>&3 | log ; \
	else \
	  tmp_dir=$(shell mktemp -u) ; \
	  docker exec -i $$DB_CONTAINER mkdir -p $$tmp_dir ; \
	  echo "Temp dir: $$tmp_dir" ; \
	  docker cp sql $$DB_CONTAINER:$$tmp_dir ; \
	  docker cp .build $$DB_CONTAINER:$$tmp_dir ; \
	  $(POMA_LOG_PARSER) ; \
	  docker exec -w $$tmp_dir -e PGPASSWORD=$$PGPASSWORD -i $$DB_CONTAINER psql \
	    -U $$PGUSER -d $$PGDATABASE --no-psqlrc --single-transaction -v VERBOSITY=terse \
	    -P footer=off -v ON_ERROR_STOP=1 -f $@ 3>&1 1>$$LOGFILE 2>&3 | log ; \
	  docker exec -i $$DB_CONTAINER rm -rf $$tmp_dir ; \
	fi

$(BUILD_DIR):
	@[ -d $@ ] || mkdir -p $@

$(SQL_EMPTY):
	@echo "\qecho '*** skipped ***'" > $@

# ------------------------------------------------------------------------------
# DB operations

# Database import script
# DCAPE_DB_DUMP_DEST must be set in pg container

define POMA_IMPORT_SCRIPT
[[ "$$DCAPE_DB_DUMP_DEST" ]] || { echo "DCAPE_DB_DUMP_DEST not set. Exiting" ; exit 1 ; } ; \
PGDATABASE="$$1" ; PGUSER="$$2" ; PGPASSWORD="$$3" ; DB_SOURCE="$$4" ; \
dbsrc=$$DCAPE_DB_DUMP_DEST/$$DB_SOURCE.tgz ; \
if [ -f $$dbsrc ] ; then \
  echo "Dump file $$dbsrc found, restoring database..." ; \
  zcat $$dbsrc | PGPASSWORD=$$PGPASSWORD pg_restore -h localhost -O -Ft -U $$PGUSER -d $$PGDATABASE || exit 1 ; \
else \
  echo "Dump file $$dbsrc not found" ; \
  exit 2 ; \
fi
endef
export POMA_IMPORT_SCRIPT

# Wait for postgresql container start
.docker-wait:
	@echo -n "Checking PG is ready..."
	@until [[ `docker inspect -f "{{.State.Health.Status}}" $$DB_CONTAINER` == healthy ]] ; do sleep 1 ; echo -n "." ; done
	@echo "Ok"

## create user, db and load db dump if given, requires docker postgresql container
docker-db-create: .docker-wait
	@echo "*** $@ ***" ; \
	docker exec -i $$DB_CONTAINER psql -U postgres -c "CREATE USER \"$$PGUSER\" WITH PASSWORD '$$PGPASSWORD';" || true ; \
	docker exec -i $$DB_CONTAINER psql -U postgres -c "CREATE DATABASE \"$$PGDATABASE\" OWNER \"$$PGUSER\" TEMPLATE \"$$DB_TEMPLATE\";" || db_exists=1 ; \
	if [[ ! "$$db_exists" ]] ; then \
	  docker exec -i $$DB_CONTAINER psql -U postgres -c "COMMENT ON DATABASE \"$$PGDATABASE\" IS 'TEMPLATE $$DB_TEMPLATE';" ; \
	  if [[ "$$DB_SOURCE" && ! "$$DB_SOURCE_DISABLED" ]] ; then \
	    echo "$$POMA_IMPORT_SCRIPT" | docker exec -i $$DB_CONTAINER bash -s - $$PGDATABASE $$PGUSER $$PGPASSWORD $$DB_SOURCE \
	    && docker exec -i $$DB_CONTAINER psql -U postgres -c "COMMENT ON DATABASE \"$$PGDATABASE\" IS 'TEMPLATE $$DB_TEMPLATE SOURCE $$DB_SOURCE';" \
	    || true ; \
	  fi \
	fi

## drop database and user, requires docker postgresql container
docker-db-drop: .docker-wait
	@echo "*** $@ ***"
	@docker exec -it $$DB_CONTAINER psql -U postgres -c "DROP DATABASE \"$$PGDATABASE\";" || true
	@docker exec -it $$DB_CONTAINER psql -U postgres -c "DROP USER \"$$PGUSER\";" || true

poma-clean: rmd-$(BUILD_DIR)

rmd-%:
	@[ ! -d $* ] || rm -rf $*

## run psql
psql: psql-$(PSQL_VIA)

psql-psql:
	@psql

psql-docker: .docker-wait
	@docker exec -ti $$DB_CONTAINER psql -U $$PGUSER -d $$PGDATABASE

.PHONY: config poma-clean

define POMA_CONFIG_DEFAULT
# ------------------------------------------------------------------------------
# generated by `make config`

# Database

# Host
PGHOST=$(PGHOST)
# Port
PGPORT=$(PGPORT)
# Name
PGDATABASE=$(PGDATABASE)
# User
PGUSER=$(PGUSER)
# Password
PGPASSWORD=$(PGPASSWORD)

# Database template
DB_TEMPLATE=$(DB_TEMPLATE)
# Database dump for import on create
DB_SOURCE=$(DB_SOURCE)

# Client name inside database
PGAPPNAME=$(PGAPPNAME)
# connect via SSL
PGSSLMODE=$(PGSSLMODE)

# tool to run psql (psql or docker)
PSQL_VIA=$(PSQL_VIA)

# docker postgresql container name
DB_CONTAINER=$(DB_CONTAINER)

endef
export POMA_CONFIG_DEFAULT

# make run this when found include $(CFG) in Makefile if $(CFG) does not exists
$(CFG):
	@echo "Creating default config in $@"
	@echo "$$POMA_CONFIG_DEFAULT" > $@
ifdef CONFIG_DEFAULT
	@echo "$$CONFIG_DEFAULT" >> $@
endif

## Create default $(CFG) file
config:
	@true

# colors: https://linux.101hacks.com/ps1-examples/prompt-color-using-tput/
define POMA_LOG_PARSER
test_cnt=0; \
function log() { \
  local filenew ; \
  local fileold ; \
  ret="0" ; \
  while read data ; \
  do \
    total=$${data#*TOTAL TESTS:} ; \
    d=$${data#* WARNING:  ::} ; \
    dn=$${data#* NOTICE: } ; \
    dw=$${data#*: WARNING:  } ; \
    if [[ "$$data" != "$$total" ]] ; then \
      if [[ "$$test_cnt" != "0" ]] ; then \
        tput setaf 2 2>/dev/null ; \
        echo "ok $$out" ; \
        out=""; \
        tput sgr0 2>/dev/null ;  \
      fi ; \
      [[ "$$total" == "0" ]] || echo "1..$$total" ; \
      test_cnt=0; continue ; \
    fi ; \
    if [[ "$$data" != "$$d" ]] ; then \
      filenew=$${data%.sql*} ; \
      filenew=$${filenew#*psql:} ; \
      if [[ "$$fileold" != "$$filenew" ]] ; then \
        tput setaf 2 2>/dev/null ; \
        [[ "$$test_cnt" == "0" ]] || echo "ok $$out" ; \
        test_cnt=$$(($$test_cnt+1)) ; \
        [[ "$$filenew" ]] && out="$$test_cnt - $${filenew%.macro}.sql" ; \
        fileold=$$filenew ; \
        tput sgr0 2>/dev/null ;  \
      fi ; \
      [[ "$$d" ]] && echo "#$$d" ; \
    elif [[ "$$data" != "$$dw" ]] ; then \
      tput setaf 3 2>/dev/null ; \
      echo "$$data" ; \
      tput sgr0 2>/dev/null ;  \
    elif [[ "$$data" == "$$dn" ]] ; then \
        tput setaf 1 2>/dev/null ;  \
        [[ "$$ret" != "0" ]] || echo "not ok $$out ($$data)" ; \
        echo "$$data" >> $${LOGFILE}.err ; \
        echo "$$data" ; \
        ret="1" ; \
    fi; \
  done ; \
  if [[ $$ret == "0" ]] ; then \
    tput setaf 2 2>/dev/null ; \
    echo "ok $$out" ; \
  fi; \
  tput sgr0 2>/dev/null ; \
  return $$ret ; \
}
endef

# ------------------------------------------------------------------------------
# The following code called by $(BUILD_DIR)/%.psql target via recirsive make call

#SHELL  = /bin/bash
#AWK   ?= $(shell command -v gawk 2> /dev/null)

#POMA_ROOT  ?= sql
PKG   ?= PKG_must_be_set_in_parent_Makefile
MASK  ?= MASK_must_be_set_in_parent_Makefile
MODE  ?= MODE_must_be_set_in_parent_Makefile


# https://stackoverflow.com/a/12959764
# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

UNSORTED := $(foreach d,$(MASK),$(call rwildcard,$(SQL_ROOT)/$(PKG)/,$d))
SOURCES := $(sort $(UNSORTED))
PREPSQL := $(patsubst $(SQL_ROOT)/%, $(BUILD_DIR)/%, $(SOURCES))
PREPS := $(patsubst %.sql, %.psql, $(PREPSQL))

# сборка инклюдов для $(MODE).sql
$(BUILD_DIR)/$(PKG)-$(MODE).psql: $(PREPS)
	@echo " ** $@ **"
	@echo "-- generated for mode $(MODE)" > $@
	@echo "\set PKG $(PKG)" >> $@
	@ct=0; st=0; \
	for f in $^ ; do t=$${f##*/9} ; [[ "$${t%.macro.psql}" == "$$t" && "$$f" != "$$t" ]] && ct=$$(($$ct+1)) ; done; \
	for f in $^ ; do \
	    t=$${f##*/9} ; \
		[[ "$${t%.macro.psql}" != "$$t" && "$$f" != "$$t" ]] && continue ; \
		if [[ "$$f" != "$$t"  && "$$st" == "0" ]] ; then  st=1 ; echo "SELECT poma.test('TOTAL TESTS:$$ct');" >> $@ ; fi ; \
		cat $$f >> $@ ; \
	done

# get first char from string
#https://stackoverflow.com/a/3710342
INITIALS = 1 2 3 4 5 6 7 8 9 0
FIRST = $(strip $(foreach a,$(INITIALS),$(if $(patsubst $a%,,$(notdir $1)),,$a)))

# команда вызова или подготовленный файл
$(BUILD_DIR)/$(PKG)/%.psql: $(SQL_ROOT)/$(PKG)/%.sql
	@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	fc=$(call FIRST,$<);  \
	  in=$< ; innr=$${in%.sql}; inn=$${innr#$(SQL_ROOT)/} o=$@ ; outn=$${o%.psql} ; out=$$outn.sql ; \
	  # echo " -- $$outn ($$fc) --"; \
	  case $$fc in \
		1|3|5|6) \
		    $(AWK) '{ print gensub(/(\$$_\$$)($$| +#?)/, "\\1\\2 /* " FILENAME ":" FNR " */ ","g")};' \
		    $< > $$out || echo "-- dd" >> $out ; \
		    echo "\i $$out" > $@ ;; \
		2|4|8) \
		    if [[ "$$inn" != "$${inn%_once}" ]] ; then \
			echo "\qecho $$inn" > $$out ; \
			arg=$$("$(MD5SUM)" $$in | sed -E "s/ +/','/") ; \
			echo "select poma.patch('$(PKG)','$$arg','$(SQL_ROOT)/$(PKG)/','$(SQL_EMPTY)')" >> $$out ; \
			echo "\gset" >> $$out ; \
			if [[ "$(RUNONCE)" == "yes" ]] ; then echo "\i :patch" >> $$out ; fi ; \
			echo "\i $$out" > $@ ; \
		    else \
			echo "\i $<" > $@ ; \
		    fi ;; \
		9) \
		    # test file \
		    if [[ "$${in%.macro.sql}" == "$$in" ]] ; then  \
			echo "\\set TEST $$inn" > $$out ; \
		    echo "\\set TESTOUT $$outn.md" >> $$out ; \
			echo "\\set BUILD_DIR $(BUILD_DIR)/" >> $$out ; \
		    echo "$$POMA_TEST_BEGIN" >> $$out ; \
		    $(AWK) '{ gsub(/; *-- *BOT/, "\n\\pset t on\n\\g :OUTT\n\\pset t off\n\\set QUIET on"); gsub(/; *-- *EOT/, "\n\\w :OUTW\n\\g :OUTG"); print }' $< >> $$out ; \
		    echo "\! diff -c $$innr.md $$outn.md | tr \"\t\" ' ' > $(BUILD_DIR)/errors.diff" >> $$out ; \
		    echo "$$POMA_TEST_END" >> $$out ; \
		    echo "\i $$out" > $@ ; \
			else \
		    $(AWK) '{ gsub(/; *-- *BOT/, "\n\\pset t on\n\\g :OUTT\n\\pset t off\n\\set QUIET on"); gsub(/; *-- *EOT/, "\n\\w :OUTW\n\\g :OUTG"); print }' $< >> $$out ; \
		    echo "\i $$out" > $@ ; \
			fi ;; \
		*) \
		    echo "\i $<" > $@ ;; \
		esac ; \
	echo -n "."

BUILD_DIR ?= .build

clean-%:
	@PKG=$* ; \
	  [ ! -f "$(BUILD_DIR)/$${PKG}-*.psql" ] || rm $(BUILD_DIR)/$${PKG}-*.psql ; \
		[ ! -d "$(BUILD_DIR)/$$PKG" ] || rm -rf $(BUILD_DIR)/$$PKG


define POMA_TEST_BEGIN
-- ----------------------------------------------------------------------------
-- test_begin
\set QUIET on
-- ----------------------------------------------------------------------------

\set OUTW '| echo ''```sql'' >> ':TESTOUT' ; cat >> ':TESTOUT' ; echo '';\n```'' >> ':TESTOUT
\set OUTT '| echo -n ''##'' >> ':TESTOUT' ; cat >> ':TESTOUT
\set OUTG '| $(AWK) ''{ gsub(/--\\+--/, "--|--"); gsub(/^[ |-]/, "|"); print }'' >> ':TESTOUT

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
endef
export POMA_TEST_BEGIN

define POMA_TEST_END
-- ----------------------------------------------------------------------------
-- test_end

\set QUIET on

ROLLBACK TO SAVEPOINT package_test;
\set ERRORS `cat $(BUILD_DIR)/errors.diff`
\pset t on
SELECT poma.raise_on_errors(:'ERRORS');
\pset t off
\set QUIET off

-- test_end
-- ----------------------------------------------------------------------------
endef
export POMA_TEST_END
