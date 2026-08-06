# zsh-syntax-highlighting 必须晚于其他交互插件加载，因此它位于 ZSH_PLUGINS 最后。
typeset _dotfiles_syntax_highlighting_file="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# 外部插件尚未下载时静默跳过，避免新机器首次初始化时产生无意义报错。
[[ -r "$_dotfiles_syntax_highlighting_file" ]] || {
  unset _dotfiles_syntax_highlighting_file
  return 0
}

source "$_dotfiles_syntax_highlighting_file"
unset _dotfiles_syntax_highlighting_file
