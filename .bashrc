#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias ll="ls -la --color=auto"

eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/hanselman.omp.json)"
alias config='/usr/bin/git --git-dir=/home/rafl/.cfg/ --work-tree=/home/rafl'
