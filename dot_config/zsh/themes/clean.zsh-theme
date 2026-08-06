# ==============================================================================
# clean 主题
# ==============================================================================

# 使用 Zsh 内置 vcs_info 显示 Git 分支，不依赖外部主题框架。
autoload -Uz colors vcs_info add-zsh-hook
colors
setopt PROMPT_SUBST

zstyle ':vcs_info:git:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{yellow}[%b]%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}[%b|%a]%f'

function _dotfiles_update_vcs_info() {
  vcs_info
}
add-zsh-hook precmd _dotfiles_update_vcs_info

# 两行提示符让长命令拥有更完整的输入空间。
PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}
%F{green}%#%f '
