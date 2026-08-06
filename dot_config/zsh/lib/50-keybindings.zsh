# ==============================================================================
# 按键绑定
# ==============================================================================

# 使用 Emacs 风格快捷键，并让上下方向键按当前输入前缀搜索历史。
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

zmodload zsh/terminfo
[[ -n "${terminfo[kcuu1]-}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]-}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

