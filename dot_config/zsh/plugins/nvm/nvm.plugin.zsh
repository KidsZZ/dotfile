# nvm 是 Shell 函数而不是普通可执行文件，因此必须在当前 Zsh 中 source nvm.sh。
[[ -n "${_DOTFILES_NVM_PLUGIN_READY-}" ]] && return 0
if (( $+functions[nvm] )); then
  typeset -g _DOTFILES_NVM_PLUGIN_READY=1
  typeset -g _DOTFILES_NVM_LOADED=1
  return 0
fi

# 尊重 local-before.zsh 或系统环境提供的 NVM_DIR，否则寻找常见安装位置。
if [[ -z "${NVM_DIR-}" ]]; then
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
  elif [[ -s "${XDG_CONFIG_HOME:-$HOME/.config}/nvm/nvm.sh" ]]; then
    export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
  elif (( $+commands[brew] )); then
    _dotfiles_nvm_brew_dir="$(brew --prefix nvm 2>/dev/null)"
    [[ -s "$_dotfiles_nvm_brew_dir/nvm.sh" ]] && export NVM_DIR="$_dotfiles_nvm_brew_dir"
  fi
fi

[[ -n "${NVM_DIR-}" && -s "$NVM_DIR/nvm.sh" ]] || return 0
typeset -g _DOTFILES_NVM_PLUGIN_READY=1

# 可在 local-before.zsh 中覆盖开关，或添加无法从 NVM bin 目录发现的额外触发命令。
typeset -g ZSH_NVM_LAZY="${ZSH_NVM_LAZY:-true}"
typeset -g ZSH_NVM_AUTO_USE="${ZSH_NVM_AUTO_USE:-true}"
typeset -gaU ZSH_NVM_LAZY_EXTRA_COMMANDS

# 加载 NVM 本体与补全；重复调用直接返回。
function _dotfiles_nvm_load() {
  [[ -n "${_DOTFILES_NVM_LOADED-}" ]] && return 0

  source "$NVM_DIR/nvm.sh" || return 1
  rehash
  typeset -g _DOTFILES_NVM_LOADED=1

  # nvm 只提供 Bash 补全，使用 Zsh 自带的兼容层加载。
  if [[ -r "$NVM_DIR/bash_completion" ]]; then
    autoload -Uz +X bashcompinit
    bashcompinit
    ZSH_VERSION= source "$NVM_DIR/bash_completion"
  fi
}

function _dotfiles_nvm_lazy_call() {
  local command_name="$1"
  shift

  # 当前代理先移除自身；其他代理按需保留，避免维护额外的全局注册状态。
  [[ "${functions[$command_name]-}" == *'_dotfiles_nvm_lazy_call '* ]] && unfunction "$command_name"
  _dotfiles_nvm_load || return 1
  if ! (( $+functions[$command_name] || $+commands[$command_name] )); then
    print -u2 -- "[dotfiles] NVM 加载后仍未找到命令：$command_name"
    return 127
  fi

  "$command_name" "$@"
}

# nvm 是 Shell 函数，必须显式注册；其余命令从 NVM 各版本的 bin 自动发现。
function _dotfiles_nvm_setup_lazy() {
  local -aU commands_to_wrap
  local binary_path command_name function_body

  commands_to_wrap=(nvm "${ZSH_NVM_LAZY_EXTRA_COMMANDS[@]}")
  for binary_path in "$NVM_DIR"/v[0-9]*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N); do
    [[ -x "$binary_path" && ! -d "$binary_path" ]] || continue
    command_name="${binary_path:t}"

    # 尊重用户定义的别名和函数；外部同名命令由 NVM 代理优先接管。
    (( $+aliases[$command_name] || $+functions[$command_name] )) && continue
    commands_to_wrap+=("$command_name")
  done

  for command_name in "${commands_to_wrap[@]}"; do
    [[ -n "$command_name" ]] || continue
    (( $+aliases[$command_name] || $+functions[$command_name] )) && continue

    # functions 关联数组可以安全创建动态函数名，无需 eval 扫描结果。
    function_body="_dotfiles_nvm_lazy_call ${(q)command_name} \"\$@\""
    functions[$command_name]="$function_body"
  done
}

if [[ "$ZSH_NVM_LAZY" == true ]]; then
  _dotfiles_nvm_setup_lazy
  unfunction _dotfiles_nvm_setup_lazy
else
  _dotfiles_nvm_load
fi

# 查找当前目录或父目录的 .nvmrc，用于进入项目时自动切换版本。
function _dotfiles_nvm_find_nvmrc() {
  local search_dir="${PWD:A}"
  while true; do
    if [[ -f "$search_dir/.nvmrc" ]]; then
      print -r -- "$search_dir/.nvmrc"
      return 0
    fi

    [[ "$search_dir" == "/" ]] && return 1
    search_dir="${search_dir:h}"
  done
}

function _dotfiles_nvm_auto_use() {
  [[ "$ZSH_NVM_AUTO_USE" == true ]] || return 0

  local nvmrc_path="$(_dotfiles_nvm_find_nvmrc)"
  if [[ -z "$nvmrc_path" ]]; then
    if [[ -n "${_DOTFILES_NVM_AUTO_ACTIVE-}" ]] && (( $+functions[nvm] )); then
      nvm use --silent default >/dev/null 2>&1
      unset _DOTFILES_NVM_AUTO_ACTIVE
    fi
    return 0
  fi

  _dotfiles_nvm_load || return 1

  local requested_version="$(<"$nvmrc_path")"
  requested_version="${requested_version//[[:space:]]/}"
  local installed_version="$(nvm version "$requested_version")"

  if [[ "$installed_version" == "N/A" ]]; then
    print -u2 -- "[dotfiles] .nvmrc 请求的 Node $requested_version 尚未安装，请手动执行：nvm install"
    return 0
  fi

  if [[ "$(nvm current)" != "$installed_version" ]]; then
    nvm use --silent "$requested_version"
  fi
  typeset -g _DOTFILES_NVM_AUTO_ACTIVE="$nvmrc_path"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _dotfiles_nvm_auto_use
_dotfiles_nvm_auto_use

unset _dotfiles_nvm_brew_dir
