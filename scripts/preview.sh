#!/usr/bin/env bash

host="$1"

if [[ -z "$host" ]]; then
	exit 0
fi

# Use bat for syntax highlighting if available, otherwise cat
if command -v bat >/dev/null 2>&1; then
	awk -v h="$host" '
	  /^Host / {p=0}
	  $2 == h {p=1}
	  p && NF > 0 {print}
	  p && NF == 0 {exit}
	' ~/.ssh/config | bat --language=ssh-config --style=plain --line-numbers=off --decorations=never
else
	awk -v h="$host" '
	  /^Host / {p=0}
	  $2 == h {p=1}
	  p && NF > 0 {print}
	  p && NF == 0 {exit}
	' ~/.ssh/config
fi