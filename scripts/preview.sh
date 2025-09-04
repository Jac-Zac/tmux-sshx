#!/usr/bin/env bash

host="$1"

if [[ -z "$host" ]]; then
	exit 0
fi

# Display SSH host configuration with syntax highlighting
# Sanitize host variable to prevent injection
host_config=$(awk -v h="${host//[^a-zA-Z0-9._-]/}" '
  /^Host / {p=0}
  $2 == h {p=1}
  p && NF > 0 {print}
  p && NF == 0 {exit}
' ~/.ssh/config)

if command -v bat >/dev/null 2>&1; then
  echo "$host_config" | bat --style=plain --language=ssh_config --color=always
else
  echo "$host_config"
fi