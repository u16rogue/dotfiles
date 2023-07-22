# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='\[\e[0;38;5;219m\]\u\[\e[0m\]@\[\e[0;38;5;81m\]\H \[\e[0;1;38;5;228m\]\w \[\e[0;3;38;5;135m\]$(git branch 2>/dev/null | grep '"'"'^*'"'"' | colrm 1 2)\n\[\e[0m\][\[\e[0m\]\$\[\e[0m\]]\[\e[0m\] '

. "$HOME/.cargo/env"
