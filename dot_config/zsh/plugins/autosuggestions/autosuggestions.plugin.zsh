# zsh-autosuggestions 由 chezmoi external 安装，当前文件只负责接入现有加载框架。
typeset _dotfiles_autosuggestions_file="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# 外部插件尚未下载时静默跳过，chezmoi apply 完成后会自动生效。
[[ -r "$_dotfiles_autosuggestions_file" ]] || {
  unset _dotfiles_autosuggestions_file
  return 0
}

# 使用终端默认的暗色前景显示建议；可在 local-before.zsh 中覆盖。
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE:-fg=8}"

source "$_dotfiles_autosuggestions_file"
unset _dotfiles_autosuggestions_file
