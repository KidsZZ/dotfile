# ==============================================================================
# 命令补全
# ==============================================================================

autoload -Uz compinit
compinit -d "$ZSH_CACHE_DIR/zcompdump"

# 补全菜单支持方向选择、大小写不敏感匹配，并按类型分组展示。
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"
[[ -n "${LS_COLORS-}" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
