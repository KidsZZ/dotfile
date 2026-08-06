function sve() {
  local venv_dir="${1:-.venv}"
  local activate_file="${venv_dir:A}/bin/activate"

  if [[ ! -f "$activate_file" ]]; then
    print -u2 -- "[dotfiles] 未找到 Python 虚拟环境：$venv_dir"
    return 1
  fi

  source "$activate_file" || return 1
  print -- "已激活 Python 虚拟环境：${venv_dir:A}"
}
