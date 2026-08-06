# ==============================================================================
# PATH 与默认程序
# ==============================================================================

# 用户级文件目录PATH
typeset -a _dotfiles_user_bin_dirs
for _dotfiles_bin_dir in "$HOME/.local/bin" "$HOME/bin"; do
  [[ -d "$_dotfiles_bin_dir" ]] && _dotfiles_user_bin_dirs+=("$_dotfiles_bin_dir")
done
path=("${_dotfiles_user_bin_dirs[@]}" $path)

unset _dotfiles_bin_dir _dotfiles_user_bin_dirs
