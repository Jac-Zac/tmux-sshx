#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

tmux_option_or_fallback() {
	local option_value
	option_value="$(tmux show-option -gqv "$1")"
	if [ -z "$option_value" ]; then
		option_value="$2"
	fi
	echo "$option_value"
}

preview_settings() {
	preview_location=$(tmux_option_or_fallback "@sshx-preview-location" "right")
	preview_ratio=$(tmux_option_or_fallback "@sshx-preview-ratio" "55%")
	preview_enabled=$(tmux_option_or_fallback "@sshx-preview-enabled" "true")
}

window_settings() {
	window_height=$(tmux_option_or_fallback "@sshx-window-height" "90%")
	window_width=$(tmux_option_or_fallback "@sshx-window-width" "75%")
	layout_mode=$(tmux_option_or_fallback "@sshx-layout" "reverse")
	prompt_icon=$(tmux_option_or_fallback "@sshx-prompt" "SSH> ")
	pointer_icon=$(tmux_option_or_fallback "@sshx-pointer" "▶")
}

handle_binds() {
	additional_fzf_options=$(tmux_option_or_fallback "@sshx-additional-options" "--color pointer:9,spinner:92,marker:46")
	bind_exit=$(tmux_option_or_fallback "@sshx-bind-abort" "esc")
	bind_accept=$(tmux_option_or_fallback "@sshx-bind-accept" "enter")
	bind_scroll_up=$(tmux_option_or_fallback "@sshx-bind-scroll-up" "ctrl-u")
	bind_scroll_down=$(tmux_option_or_fallback "@sshx-bind-scroll-down" "ctrl-d")
	bind_select_up=$(tmux_option_or_fallback "@sshx-bind-select-up" "ctrl-n")
	bind_select_down=$(tmux_option_or_fallback "@sshx-bind-select-down" "ctrl-p")
}

handle_args() {
	if [[ "$preview_enabled" == "true" ]]; then
		PREVIEW_LINE="${SCRIPTS_DIR%/}/preview.sh {}"
	fi

	args=(
		--bind "$bind_accept:print-query"
		--bind "$bind_exit:abort"
		--bind "$bind_scroll_up:preview-half-page-up"
		--bind "$bind_scroll_down:preview-half-page-down"
		--bind "$bind_select_up:up"
		--bind "$bind_select_down:down"
		--bind '?:toggle-preview'
		--exit-0
		--preview="${PREVIEW_LINE}"
		--preview-window="${preview_location},${preview_ratio},,"
		--layout="$layout_mode"
		--pointer="$pointer_icon"
		-p "$window_width,$window_height"
		--prompt "$prompt_icon"
		--print-query
		--scrollbar '▌▐'
	)

	auto_accept=$(tmux_option_or_fallback "@sshx-auto-accept" "off")
	if [[ "${auto_accept}" == "on" ]]; then
		args+=(--bind one:accept)
	fi

	eval "fzf_opts=($additional_fzf_options)"
}

preview_settings
window_settings
handle_binds
handle_args

tmux set-option -g @sshx-_built-args "$(declare -p args)"

if [ `tmux_option_or_fallback "@sshx-prefix" "on"` = "on"  ]; then
	tmux bind-key "$(tmux_option_or_fallback "@sshx-bind" "S")" run-shell "$CURRENT_DIR/scripts/sshx.sh"
else
	tmux bind-key -n "$(tmux_option_or_fallback "@sshx-bind" "S")" run-shell "$CURRENT_DIR/scripts/sshx.sh"
fi