#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_ssh_hosts() {
	if [[ ! -f ~/.ssh/config ]]; then
		echo "No SSH config found at ~/.ssh/config"
		return 1
	fi
	hosts=$(awk '/^Host / {print $2}' ~/.ssh/config | grep -v '[*?]' | sort)
	if [[ -z "$hosts" ]]; then
		echo "No SSH hosts found in ~/.ssh/config"
		return 1
	fi
	echo "$hosts"
}

tmux_option_or_fallback() {
	local option_value
	option_value="$(tmux show-option -gqv "$1")"
	if [ -z "$option_value" ]; then
		option_value="$2"
	fi
	echo "$option_value"
}

handle_output() {
	host="$*"
	if [[ -z "$host" ]]; then
		exit 0
	fi

	if [ -n "$TMUX" ]; then
		# Open a new tmux window and run ssh; close the window automatically when done
		tmux new-window -n "$host" "ssh '$host'; tmux kill-window"
	else
		# Not in tmux, run normal SSH
		ssh "$host"
	fi

	exit 0
}

run_plugin() {
	INPUT=$(get_ssh_hosts 2>/dev/null || echo "Error: Check your SSH configuration")
	eval "$(tmux show-option -gqv @sshx-_built-args)"
	FZF_BUILTIN_TMUX=$(tmux show-option -gqv @sshx-fzf-builtin-tmux)
	if [[ "$FZF_BUILTIN_TMUX" == "on" ]]; then
		RESULT=$(echo -e "${INPUT}" | fzf "${fzf_opts[@]}" "${args[@]}" | tail -n1)
	else
		RESULT=$(echo -e "${INPUT}" | fzf-tmux "${fzf_opts[@]}" "${args[@]}" | tail -n1)
	fi
}

run_plugin
handle_output "$RESULT"