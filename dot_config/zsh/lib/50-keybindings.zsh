# ==============================================================================
# 按键绑定
# ==============================================================================

# 使用 Emacs 风格快捷键。
bindkey -e
zmodload zsh/terminfo

# 上下方向键按当前输入前缀搜索历史
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${terminfo[kcuu1]-}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]-}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

# Home 和 End 移动到命令行首尾；同时保留常见终端的默认转义序列。
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
[[ -n "${terminfo[khome]-}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]-}" ]] && bindkey "${terminfo[kend]}" end-of-line

# Delete 删除光标后的字符，Ctrl-Delete 删除光标后的整个单词。
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word
[[ -n "${terminfo[kdch1]-}" ]] && bindkey "${terminfo[kdch1]}" delete-char

# Ctrl-左右方向键按单词移动，适配主流 xterm 兼容终端。
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Shift-Tab 在补全菜单中反向移动。
[[ -n "${terminfo[kcbt]-}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

# Ctrl-X Ctrl-E 使用 $VISUAL 或 $EDITOR 编辑当前命令，适合处理长命令。
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line
