# fzf 不存在时静默跳过，让同一份配置可以安全应用到未安装 fzf 的电脑。
(( $+commands[fzf] )) || return 0

# 新版 fzf 会直接生成 Zsh 集成：Ctrl-R 搜历史、Ctrl-T 选文件、Alt-C 选目录。
typeset _dotfiles_fzf_init
if _dotfiles_fzf_init="$("${commands[fzf]}" --zsh 2>/dev/null)"; then
  eval "$_dotfiles_fzf_init"

# 兼容不支持 --zsh、但提供发行版示例脚本的旧版 Debian/Ubuntu 软件包。
elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] \
    && source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

unset _dotfiles_fzf_init
