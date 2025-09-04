#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_ssh_hosts() {
	awk '/^Host / {print $2}' ~/.ssh/config | grep -v '[*?]' | sort
}

tmux_option_or_fallback() {
	local option_value
	option_value="$(tmux show-option -gqv "$1")"
	if [ -z "$option_value" ]; then
		option_value="$2"
	fi
	echo "$option_value"
}

input() {
	get_ssh_hosts
}

handle_output() {
	host="$*"
	if [[ -z "$host" ]]; then
		exit 0
	fi

	if [ -n "$TMUX" ]; then
		# Open a new tmux window and run ssh; close the window automatically when done
		tmux new-window -n "$host" "ssh $host; tmux kill-window"
	else
		# Not in tmux, run normal SSH
		ssh "$host"
	fi

	exit 0
}

run_plugin() {
	eval $(tmux show-option -gqv @sshx-_built-args)
	INPUT=$(input)

	RESULT=$(echo -e "${INPUT}" | fzf-tmux "${fzf_opts[@]}" "${args[@]}" | tail -n1)
}

run_plugin
handle_output "$RESULT"