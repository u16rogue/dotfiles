FROM alpine AS setup

# Setup
RUN apk add --no-cache tmux fish bash git curl openssh

# Setup system
WORKDIR /home/user-container
RUN \
    adduser -D -s /bin/sh user-container

# Setup tmux config
RUN \
    mkdir -p /home/user-container/.config/tmux/ \
 && cat <<'EOF' > /home/user-container/.config/tmux/tmux.conf
unbind-key C-b
set -g prefix C-q
bind-key C-q send-prefix
set-option -g detach-on-destroy off
bind j select-pane -D
bind k select-pane -U
bind h select-pane -L
bind l select-pane -R
bind -r W select-pane -t .+1 \;  resize-pane -Z
set-option -s escape-time 1
set-option -ga terminal-overrides ",xterm-256color:Tc"
set -g base-index 1
setw -g pane-base-index 1
set -g status-position top
set -g @plugin 'catppuccin/tmux#v1.0.1'
set -g @catppuccin_window_status_style basic
set -g @catppuccin_status_default "on"
set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"
set -g status-left ""
set -g @catppuccin_window_default_fill "number"
set -g @catppuccin_window_default_text " #W \uec01 #{window_panes}#{?window_zoomed_flag, \uf1e5 ,}"
set -g @catppuccin_window_current_fill "number"
set -g @catppuccin_window_current_text " #W \uec01 #{window_panes}#{?window_zoomed_flag, \uf1e5 ,}"
set -g @catppuccin_status_fill "icon"
set -g @catppuccin_status_connect_separator "yes"
set -g @catppuccin_status_left_separator "█"
set -g @catppuccin_status_right_separator "█"
set -g @plugin 'tmux-plugins/tpm'
run "/home/user-container/.config/tmux/plugins/tpm/tpm"
EOF

# Setup fish config
RUN \
    mkdir -p /home/user-container/.config/fish \
 && cat <<'EOF' > /home/user-container/.config/fish/config.fish
if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end
fundle plugin 'danhper/fish-ssh-agent'
fundle init
if status is-interactive
  set -g fish_greeting
  fish_vi_key_bindings
end
function fish_prompt
  set -l user_char '$'
  if fish_is_root_user
      set user_char '#'
  end
  set -l git_prompt (fish_git_prompt)
  if test "$git_prompt" = ""
    set git_prompt ''
  end
  printf '%s%s%s@%s%s %s%s%s%s%s\n[%s] ' \
      (set_color brmagenta) $USER        \
      (set_color normal)                 \
      (set_color brblue) $hostname       \
      (set_color bryellow) (pwd)         \
      (set_color magenta)  $git_prompt   \
      (set_color normal) $user_char
end
EOF

RUN                                                                                                       \
    git clone --depth 1 https://github.com/tmux-plugins/tpm /home/user-container/.config/tmux/plugins/tpm \
 && mkdir -p /home/user-container/.ssh                                                                    \
 && chown -R user-container:user-container /home/user-container                                           \
 && su - user-container -c "/home/user-container/.config/tmux/plugins/tpm/bin/install_plugins"            \
 && su - user-container -c "fish -c 'eval (curl -sfL https://git.io/fundle-install) && fundle plugin danhper/fish-ssh-agent && fundle install && fundle init'"

FROM alpine

COPY --from=setup /home/user-container /home/user-container

RUN                                                                          \
    apk add --no-cache tmux fish bash git vim sudo openssh musl-locales curl \
 && adduser -D -s /usr/bin/fish user-container                               \
 && echo "user-container:1234" | chpasswd                                    \
 && addgroup user-container wheel                                            \
 && echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel                       \
 && mkdir -p /home/user-container/.ssh                                       \
 && chown -R user-container:user-container /home/user-container

ENV                   \
  LANG=en_US.UTF-8    \
  TERM=xterm-256color \
  LC_ALL=en_US.UTF-8

USER user-container
WORKDIR /home/user-container
ENTRYPOINT [ "tmux" ]
