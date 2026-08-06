# ==============================================================================
# Powerlevel10k 主题适配器
# ==============================================================================

# 主题引擎由 .chezmoiexternal.toml 安装，不进入当前 dotfiles Git 仓库。
typeset _dotfiles_p10k_home="${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"

if [[ -r "$_dotfiles_p10k_home/powerlevel10k.zsh-theme" ]]; then
  source "$_dotfiles_p10k_home/powerlevel10k.zsh-theme"

  # p10k configure 生成的外观配置独立管理，主题引擎升级时不会被覆盖。
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
else
  # 外部依赖尚未应用时回退到 personal，保证新电脑仍有可用提示符。
  print -u2 -- '[dotfiles] Powerlevel10k 尚未安装，暂时使用 personal 主题'
  source "$ZSH_CONFIG_HOME/themes/personal.zsh-theme"
fi

unset _dotfiles_p10k_home
