#!/bin/sh
cat lisp.lsp | sed -e 's/;.*$//g' | tr -d '\n' | sed -e 's/  */ /g' | \
    awk "{sub(\"WRITE_HERE\", \"$1\")}{print}"
