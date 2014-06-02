#!/bin/sh
tr -d '\n' < lisp.lsp | sed -e 's/  */ /g' | sed -e 's/funcall //g' |
awk "{sub(\"WRITE_HERE\", \"$1\")}{print}"