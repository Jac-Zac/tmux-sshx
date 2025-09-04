# Tmux SSHX

A fuzzy SSH host selector for Tmux, with preview capabilities, similar to tmux-sessionx but for SSH hosts.

[![image](https://github.com/omerxx/tmux-sessionx/raw/main/img/sessionxv2.png)](https://github.com/omerxx/tmux-sessionx/blob/main/img/sessionxv2.png)

## Prerequisites 🛠️

- [tpm](https://github.com/tmux-plugins/tpm)
- [fzf](https://github.com/junegunn/fzf)
- [fzf-tmux](https://github.com/junegunn/fzf#fzf-tmux-script)
- [bat](https://github.com/sharkdp/bat) for syntax highlighting in preview

### Installing Prerequisites

#### macOS (with Homebrew)
```bash
brew install tmux tpm fzf bat
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install tmux fzf bat
# Install TPM manually
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### Arch Linux
```bash
sudo pacman -S tmux fzf bat tmux-plugin-manager
```

#### Manual Installation
- **Tmux**: Download from https://github.com/tmux/tmux/releases
- **TPM**: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- **fzf**: Download from https://github.com/junegunn/fzf/releases
- **bat**: Download from https://github.com/sharkdp/bat/releases

## Install 💻

### Option 1: Using TPM (Recommended)
1. Add this to your `.tmux.conf`:
   ```
   set -g @plugin 'yourusername/tmux-sshx'
   ```
2. Reload your tmux config: `tmux source ~/.tmux.conf`
3. Install the plugin: Press `Ctrl-I` (or run `~/.tmux/plugins/tpm/bin/install_plugins`)

### Option 2: Manual Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/tmux-sshx.git ~/.tmux/plugins/tmux-sshx
   ```
2. Add to your `.tmux.conf`:
   ```
   run '~/.tmux/plugins/tmux-sshx/sshx.tmux'
   ```
3. Reload your tmux config: `tmux source ~/.tmux.conf`

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

Launching the plugin opens a fuzzy finder at the bottom of your screen with SSH hosts from `~/.ssh/config`. The preview pane on the right shows the selected host's configuration with syntax highlighting.

- `enter` accept selection and SSH into host
- `esc` abort without connecting
- `ctrl-u` scroll preview up
- `ctrl-d` scroll preview down
- `ctrl-n` select up
- `ctrl-p` select down
- `?` toggles the preview pane

When you select a host:
- If inside tmux: Opens SSH in a new tmux window
- If outside tmux: Runs SSH directly in your terminal

## Thanks ❤️

Inspired by [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) and your original tmux_fzf_ssh function.