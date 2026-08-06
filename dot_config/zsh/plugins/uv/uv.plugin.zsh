# uv 是普通可执行程序，不需要初始化；插件只负责参数保护、常用别名和补全。
(( $+commands[uv] )) || return 0

# 防止 Zsh 把 package[extra] 一类参数当作文件匹配表达式展开。
alias uv='noglob uv'
alias uvx='noglob uvx'

alias uva='uv add'
alias uvl='uv lock'
alias uvr='uv run'
alias uvs='uv sync'
alias uvv='uv venv'

function _dotfiles_refresh_uv_completion() {
  local executable="$1"
  local target="$2"
  shift 2

  # 仅在缓存缺失或 uv 可执行文件更新后重新生成，避免每次启动都执行生成命令。
  [[ -s "$target" && ! "$executable" -nt "$target" ]] && return 0

  local temporary_file="$target.$$.tmp"
  if "$@" >| "$temporary_file"; then
    command mv -f -- "$temporary_file" "$target"
  else
    command rm -f -- "$temporary_file"
    return 1
  fi
}

_dotfiles_refresh_uv_completion \
  "${commands[uv]}" \
  "$ZSH_COMPLETION_DIR/_uv" \
  "${commands[uv]}" generate-shell-completion zsh

if (( $+commands[uvx] )); then
  _dotfiles_refresh_uv_completion \
    "${commands[uvx]}" \
    "$ZSH_COMPLETION_DIR/_uvx" \
    "${commands[uvx]}" --generate-shell-completion zsh
fi

# compinit 已经执行，因此显式注册刚生成或刚更新的补全函数。
autoload -Uz _uv
compdef _uv uv
if [[ -s "$ZSH_COMPLETION_DIR/_uvx" ]]; then
  autoload -Uz _uvx
  compdef _uvx uvx
fi

unfunction _dotfiles_refresh_uv_completion

