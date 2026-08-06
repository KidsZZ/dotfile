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

# 可在 local-before.zsh 中覆盖这些选项和触发命令。
typeset -g ZSH_NVM_LAZY="${ZSH_NVM_LAZY:-true}"
typeset -g ZSH_NVM_AUTO_USE="${ZSH_NVM_AUTO_USE:-true}"
typeset -ga ZSH_NVM_LAZY_COMMANDS
(( ${#ZSH_NVM_LAZY_COMMANDS[@]} )) || ZSH_NVM_LAZY_COMMANDS=(
  nvm
  node
  npm
  npx
  corepack
  pnpm
  pnpx
  yarn
)

function _dotfiles_nvm_setup_completion() {
  [[ -n "${_DOTFILES_NVM_COMPLETION_READY-}" ]] && return 0
  [[ -r "$NVM_DIR/bash_completion" ]] || return 0

  # nvm 只提供 Bash 补全，使用 Zsh 自带的兼容层加载。
  autoload -Uz +X bashcompinit
  bashcompinit
  ZSH_VERSION= source "$NVM_DIR/bash_completion"
  typeset -g _DOTFILES_NVM_COMPLETION_READY=1
}

function _dotfiles_nvm_load() {
  [[ -n "${_DOTFILES_NVM_LOADED-}" ]] && return 0

  local lazy_command
  for lazy_command in "${ZSH_NVM_LAZY_COMMANDS[@]}"; do
    (( $+functions[$lazy_command] )) && unfunction "$lazy_command"
  done

  source "$NVM_DIR/nvm.sh" || return 1
  typeset -g _DOTFILES_NVM_LOADED=1
  _dotfiles_nvm_setup_completion
}

function _dotfiles_nvm_lazy_call() {
  local command_name="$1"
  shift

  _dotfiles_nvm_load || return 1
  if (( $+functions[$command_name] )); then
    "$command_name" "$@"
  elif (( $+commands[$command_name] )); then
    command "$command_name" "$@"
  else
    print -u2 -- "[dotfiles] NVM 加载后仍未找到命令：$command_name"
    return 127
  fi
}

if [[ "$ZSH_NVM_LAZY" == true ]]; then
  for _dotfiles_nvm_command in "${ZSH_NVM_LAZY_COMMANDS[@]}"; do
    eval "function $_dotfiles_nvm_command() { _dotfiles_nvm_lazy_call $_dotfiles_nvm_command \"\$@\"; }"
  done
  unset _dotfiles_nvm_command
else
  _dotfiles_nvm_load
fi

function _dotfiles_find_nvmrc() {
  local search_dir="${PWD:A}"
  while [[ "$search_dir" != "/" ]]; do
    if [[ -f "$search_dir/.nvmrc" ]]; then
      print -r -- "$search_dir/.nvmrc"
      return 0
    fi
    search_dir="${search_dir:h}"
  done

  [[ -f "/.nvmrc" ]] && print -r -- "/.nvmrc"
}

function _dotfiles_nvm_auto_use() {
  [[ "$ZSH_NVM_AUTO_USE" == true ]] || return 0

  local nvmrc_path="$(_dotfiles_find_nvmrc)"
  if [[ -n "$nvmrc_path" ]]; then
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
  elif [[ -n "${_DOTFILES_NVM_AUTO_ACTIVE-}" ]] && (( $+functions[nvm] )); then
    nvm use --silent default >/dev/null 2>&1
    unset _DOTFILES_NVM_AUTO_ACTIVE
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _dotfiles_nvm_auto_use
_dotfiles_nvm_auto_use

unset _dotfiles_nvm_brew_dir
