# ==============================================================================
# 命令历史
# ==============================================================================

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

# 多终端共享历史，同时过滤重复和无意义的空白命令。
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

