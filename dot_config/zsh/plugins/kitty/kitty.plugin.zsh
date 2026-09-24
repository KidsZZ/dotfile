# 在 Kitty 中使用 SSH kitten，其他终端继续使用系统 SSH。
# 使用函数在每次调用时判断环境，并原样传递所有参数。
function ssh() {
  if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
    command kitten ssh "$@"
  else
    command ssh "$@"
  fi
}
