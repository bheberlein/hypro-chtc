#!/usr/bin/env bash
# optional.sh

echo "if defined $2"
echo "    arguments = \$(arguments) $1 \$($2)"
echo "endif"
