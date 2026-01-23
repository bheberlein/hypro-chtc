#!/usr/bin/env bash
# flag.sh

# Flag is appended if $2=1 (default 0)
echo "if \$($2:0)"
echo "    arguments = \$(arguments) $1"
echo "endif"
