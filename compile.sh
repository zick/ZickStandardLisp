#!/bin/sh
v=""
while getopts e:hv: OPT; do
  case $OPT in
    "e") exp=$OPTARG;;
    "h") help=1;;
    "v") v=$OPTARG;;
  esac
done
if [ -z "$exp" -a -z "$help" ]; then
  exp=`cat - | tr -d '\n'`
fi
if [ -z "$exp" ]; then
  cat <<EOF
Usage:
  ./compile.sh -e "(car '(a b c))" > car.zsl
    or
  ./compile.sh < fib5.lsp > fib5.zsl
EOF
else
  source="`dirname $0`/lisp${v}.lsp"
  cat $source | sed -e 's/;.*$//g' | tr -d '\n' | sed -e 's/  */ /g' | \
      awk "{sub(\"WRITE_HERE\", \"$exp\")}{print}"
fi
