#!/bin/sh

ERLIB=$(erl -noshell -eval 'io:format(code:lib_dir()).' -s erlang halt)
YAWS=$(ls $ERLIB | grep yaws)

YAWS_INCLUDE_DIR=$ERLIB/$YAWS/include
if [ ! -e $YAWS_INCLUDE_DIR ]; then
  YAWS_INCLUDE_DIR=/usr/local/lib/yaws/include
fi

cat >Emakefile <<EOF
{"src/erlyweb/*", [debug_info, {outdir, "ebin"}, {i,"$YAWS_INCLUDE_DIR"}]}.
{"src/erlydb/*", [debug_info, {outdir, "ebin"}]}.
{"src/erlsql/*", [debug_info, {outdir, "ebin"}]}.
{"src/erltl/*", [debug_info, {outdir, "ebin"}]}.
{"src/smerl/*", [debug_info, {outdir, "ebin"}]}.
{"src/erlang-mysql-driver/*", [debug_info, {outdir, "ebin"}]}.
{"src/erlang-psql-driver/*", [debug_info, strict_record_tests, {outdir,
"ebin"}]}.
EOF

ebin_dir="./ebin"
# bash check if directory exists
if [ ! -d $ebin_dir ]; then
    mkdir $ebin_dir
fi

erl -noshell -eval 'make:all(), filelib:fold_files("src/", ".+\.et$", true, fun(F, _Acc) -> erltl:compile(F, [{outdir, "ebin"}, debug_info, show_errors, show_warnings]) end, []).' -pa ebin -s erlang halt
