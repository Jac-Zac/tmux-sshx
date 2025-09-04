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

get_tmux_sessions() {
	if ! command -v tmux >/dev/null 2>&1; then
		return 1
	fi
	tmux list-sessions 2>/dev/null | awk -F: '{print " " $1 " - " $2}' | sort
}

get_matching_tmux_windows() {
	if ! command -v tmux >/dev/null 2>&1; then
		return 1
	fi

	# Get SSH hosts for filtering
	ssh_hosts=$(get_ssh_hosts 2>/dev/null)
	if [[ -z "$ssh_hosts" ]]; then
		return 1
	fi

	# Get tmux windows and filter by SSH host names using grep
	tmux list-windows -a 2>/dev/null | while IFS=: read session window rest; do
		# Extract window name by removing status indicators (* -) and trailing formatting
		window_name=$(echo "$rest" | sed 's/[*_-]$//' | sed 's/ (.*$//' | sed 's/^ *//' | sed 's/ *$//' | sed 's/[*_-]$//')

		# Check if window name matches any SSH host
		if echo "$ssh_hosts" | grep -q "^${window_name}$"; then
			echo -e "\033[36m $session:$window - $window_name\033[0m"
		fi
	done | sort
}

get_ssh_configs() {
	hosts=$(get_ssh_hosts 2>/dev/null)
	if [[ -z "$hosts" ]]; then
		return 1
	fi
	echo "$hosts" | awk '{print "\033[93m " $0 "\033[0m"}'
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
	selected="$*"
	if [[ -z "$selected" ]]; then
		exit 0
	fi

	# Remove ANSI color codes and emoji prefix to get the actual name
	clean_name=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^[^ ]* //' | sed 's/ - .*//')

	if [[ "$selected" == ** ]]; then
		# This is a tmux window
		if [[ "$clean_name" == *":"* ]]; then
			# It's a window (session:window format)
			session=$(echo "$clean_name" | cut -d: -f1)
			window=$(echo "$clean_name" | cut -d: -f2)
			# Switch to session first, then select window
			if [ -n "$TMUX" ]; then
				# Already in tmux, switch client to session
				tmux switch-client -t "$session"
			else
				# Not in tmux, attach to session
				tmux attach-session -t "$session"
			fi
			# Select the specific window
			tmux select-window -t "$session:$window"
		fi
	else
		# This is an SSH host
		if [ -n "$TMUX" ]; then
			# Open a new tmux window and run ssh; close the window automatically when done
			tmux new-window -n "$clean_name" "ssh '$clean_name'; tmux kill-window"
		else
			# Not in tmux, run normal SSH
			ssh "$clean_name"
		fi
	fi

	exit 0
}

run_plugin() {
	# Get matching tmux windows (those that match SSH host names)
	TMUX_WINDOWS=$(get_matching_tmux_windows 2>/dev/null || echo "")

	# Get SSH configs
	SSH_CONFIGS=$(get_ssh_configs 2>/dev/null || echo "")

	# Combine with matching windows first, then SSH configs
	INPUT=""
	if [[ -n "$TMUX_WINDOWS" ]]; then
		INPUT="${TMUX_WINDOWS}\n"
	fi
	if [[ -n "$SSH_CONFIGS" ]]; then
		INPUT="${INPUT}${SSH_CONFIGS}"
	fi

	if [[ -z "$INPUT" ]]; then
		echo "No matching tmux windows or SSH hosts found"
		exit 1
	fi

	eval "$(tmux show-option -gqv @sshx-_built-args)"
	FZF_BUILTIN_TMUX=$(tmux show-option -gqv @sshx-fzf-builtin-tmux)

	# Use fzf-tmux with colored emojis and sesh-like interface
	if [[ "$FZF_BUILTIN_TMUX" == "on" ]]; then
		RESULT=$(echo -e "${INPUT}" | fzf \
			--no-sort --ansi --border-label ' sshx ' --prompt '⚡  ' \
			--header '  ^a all ^t tmux ^c configs' \
			--bind 'tab:down,btab:up' \
			--bind 'ctrl-a:change-prompt(⚡  )+reload(echo -e "'"$TMUX_WINDOWS\n$SSH_CONFIGS"'")' \
			--bind 'ctrl-t:change-prompt(  )+reload(echo -e "'"$TMUX_WINDOWS"'")' \
			--bind 'ctrl-c:change-prompt(  )+reload(echo -e "'"$SSH_CONFIGS"'")' \
			--preview-window 'right:60%' \
			--preview "$CURRENT_DIR/preview.sh {}" \
			--color 'fg+:255,bg+:236' \
			"${fzf_opts[@]}" "${args[@]}" | tail -n1)
	else
		RESULT=$(echo -e "${INPUT}" | fzf-tmux -p 80%,70% \
			--no-sort --ansi --border-label ' sshx ' --prompt '⚡  ' \
			--header '  ^a all ^t tmux ^c configs' \
			--bind 'tab:down,btab:up' \
			--bind 'ctrl-a:change-prompt(⚡  )+reload(echo -e "'"$TMUX_WINDOWS\n$SSH_CONFIGS"'")' \
			--bind 'ctrl-t:change-prompt(  )+reload(echo -e "'"$TMUX_WINDOWS"'")' \
			--bind 'ctrl-c:change-prompt(  )+reload(echo -e "'"$SSH_CONFIGS"'")' \
			--preview-window 'right:60%' \
			--preview "$CURRENT_DIR/preview.sh {}" \
			--color 'fg+:255,bg+:236' \
			"${fzf_opts[@]}" "${args[@]}" | tail -n1)
	fi
}

run_plugin
handle_output "$RESULT"