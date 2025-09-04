# Tmux SSHX

A fuzzy SSH host selector for Tmux, with preview capabilities, similar to tmux-sessionx but for SSH hosts.

[![image](https://github.com/omerxx/tmux-sessionx/raw/main/img/sessionxv2.png)](https://github.com/omerxx/tmux-sessionx/blob/main/img/sessionxv2.png)

## Prerequisites 🛠️

- [tpm](https://github.com/tmux-plugins/tpm)
- [fzf](https://github.com/junegunn/fzf)
- [fzf-tmux](https://github.com/junegunn/fzf#fzf-tmux-script)
- Optional: [bat](https://github.com/sharkdp/bat) for syntax highlighting in preview

## Install 💻

Add this to your `.tmux.conf` and run `Ctrl-I` for TPM to install the plugin.

```
set -g @plugin 'yourusername/tmux-sshx'
```

## Configure ⚙️

The default binding for this plugin is `<prefix>+S`. You can change it by adding this line with your desired key:

```
set -g @sshx-bind '<mykey>'
```

### Additional configuration options:

```
# By default, tmux `<prefix>` key needs to pressed before `<mykey>` to launch
# sshx. In case you just want to bind '<mykey>' without the tmux '<prefix>'
# add the following line to turn the prefix off. This option is set to
# on by defaut.
set -g @sshx-prefix off

# Change window dimensions
set -g @sshx-window-height '75%'
set -g @sshx-window-width '75%'

# If you want change the layout to top you can set
set -g @sshx-layout 'reverse'

# If you want to change the prompt, the space is needed to not overlap the icon
set -g @sshx-prompt " "

# If you want to change the pointer
set -g @sshx-pointer "▶ "

# Preview location and screenspace can be adjusted with these
set -g @sshx-preview-location 'right'
set -g @sshx-preview-ratio '55%'

# The preview can also be disabled altogether
set -g @sshx-preview-enabled 'false'

# If you want to pass in your own FZF options. This is passed in before all other
# arguments to FZF to ensure that other options like `@sshx-pointer` and
# `@sshx-window-height/width` still work. See `man fzf` for config options.
set -g @sshx-additional-options "--color pointer:9,spinner:92,marker:46"

# When set to 'on' auto-accept will interactively accept a host
# when there's only one match
set -g @sshx-auto-accept 'off'
```

## Working with SSHX 👷

Launching the plugin pops up an fzf-tmux "popup" with fuzzy search over SSH hosts from `~/.ssh/config`. If you select a host and hit enter, it will SSH into it. If in tmux, it opens a new window; otherwise, runs SSH directly.

- `enter` accept selection
- `esc` abort
- `ctrl-u` scroll preview up
- `ctrl-d` scroll preview down
- `ctrl-n` select up
- `ctrl-p` select down
- `?` toggles the preview pane

## Thanks ❤️

Inspired by [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) and your original tmux_fzf_ssh function.