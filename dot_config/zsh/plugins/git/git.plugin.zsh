# 仅放置与 Git 直接相关的交互增强，未安装 Git 时不产生任何副作用。
(( $+commands[git] )) || return 0

alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph -20'

