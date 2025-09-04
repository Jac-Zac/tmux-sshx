#!/usr/bin/env bash

host="$1"

if [[ -z "$host" ]]; then
	exit 0
fi

# Display SSH host configuration
awk -v h="$host" '
  /^Host / {p=0}
  $2 == h {p=1}
  p && NF > 0 {print}
  p && NF == 0 {exit}
' ~/.ssh/config