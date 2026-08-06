# Cargo/Rustup 的 PATH 由 local-before.zsh 负责，插件只提供版本匹配的补全。
(( $+commands[cargo] && $+commands[rustup] )) || return 0

function _dotfiles_refresh_rustup_completion() {
  local target="$ZSH_COMPLETION_DIR/_rustup"
  [[ -s "$target" && ! "${commands[rustup]}" -nt "$target" ]] && return 0

  local temporary_file="$target.$$.tmp"
  if "${commands[rustup]}" completions zsh >| "$temporary_file"; then
    command mv -f -- "$temporary_file" "$target"
  else
    command rm -f -- "$temporary_file"
    return 1
  fi
}

function _dotfiles_create_cargo_completion() {
  local target="$ZSH_COMPLETION_DIR/_cargo"
  [[ -s "$target" ]] && return 0

  local temporary_file="$target.$$.tmp"
  {
    print -r -- '#compdef cargo'
    print -r -- 'source "$(rustc --print sysroot)/share/zsh/site-functions/_cargo"'
  } >| "$temporary_file"
  command mv -f -- "$temporary_file" "$target"
}

_dotfiles_refresh_rustup_completion
_dotfiles_create_cargo_completion

autoload -Uz _rustup _cargo
compdef _rustup rustup
compdef _cargo cargo

unfunction _dotfiles_refresh_rustup_completion _dotfiles_create_cargo_completion
