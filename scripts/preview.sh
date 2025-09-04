#!/usr/bin/env bash

selected="$1"

if [[ -z "$selected" ]]; then
	exit 0
fi

# Remove ANSI color codes and emoji prefix to get the actual name
clean_name=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^[^ ]* //')

if [[ "$selected" == ** ]]; then
	# This is a tmux window
	if [[ "$clean_name" == *":"* ]]; then
		# It's a window (session:window format)
		session=$(echo "$clean_name" | cut -d: -f1)
		window=$(echo "$clean_name" | cut -d: -f2)
		echo "Tmux Window: $session:$window"
		echo ""
		tmux list-windows -t "$session" -F "#I: #W (#F)" | grep "^$window:"
	fi
else
	# This is an SSH host - display SSH configuration
	# Sanitize host variable to prevent injection
	host_config=$(awk -v h="${clean_name//[^a-zA-Z0-9._-]/}" '
	  /^Host / {p=0}
	  $2 == h {p=1}
	  p && NF > 0 {print}
	  p && NF == 0 {exit}
	' ~/.ssh/config)

	if [[ -n "$host_config" ]]; then
		if command -v bat >/dev/null 2>&1; then
			echo "$host_config" | bat --style=plain --language=ssh_config --color=always
		else
			echo "$host_config"
		fi
	else
		echo "SSH Host: $clean_name"
		echo "No configuration found in ~/.ssh/config"
	fi
fi