# OSC 52 由 SSH 客户端所在的终端处理，将内容写入客户端的系统剪贴板。
function _dotfiles_clipcopy_osc52() {
  emulate -L zsh

  if (( ! $+commands[base64] )); then
    print -u2 -- "[dotfiles] 远程复制需要 base64 命令"
    return 1
  fi

  # 直接写入控制终端，避免重定向 stdout 时把控制序列写进文件。
  local tty_fd encoded result
  if ! exec {tty_fd}>/dev/tty; then
    print -u2 -- "[dotfiles] 远程复制需要交互终端，请使用 ssh -t 分配终端"
    return 1
  fi

  # 先完整读取并编码，输入失败时不发送序列，避免意外清空剪贴板。
  if ! encoded=$(command base64 < "${1:-/dev/stdin}"); then
    exec {tty_fd}>&-
    return 1
  fi
  # GNU/BSD 的 base64 换行行为不同，统一移除编码结果中的换行。
  encoded=${encoded//$'\n'/}
  encoded=${encoded//$'\r'/}
  print -rn -- $'\e]52;c;'"$encoded"$'\a' >&$tty_fd
  result=$?
  exec {tty_fd}>&-
  return $result
}

# 参考 OMZ 的 clipboard lib，支持 SSH、常见桌面、WSL 和 tmux 后端。
function _dotfiles_detect_clipboard() {
  emulate -L zsh

  # SSH 优先写入客户端终端，避免误用服务器的桌面剪贴板或 X11 转发。
  if [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]]; then
    if [[ -n "${TMUX-}" ]] && (( $+commands[tmux] )); then
      # 由 tmux 发送 OSC 52，同时保留其内部缓冲区供 clippaste 使用。
      function clipcopy() { command tmux load-buffer -w "${1:--}"; }
      function clippaste() { command tmux save-buffer -; }
    else
      function clipcopy() { _dotfiles_clipcopy_osc52 "$@"; }
      # OSC 52 读取支持因终端而异，不向服务器剪贴板回退。
      function clippaste() {
        print -u2 -- "[dotfiles] SSH 会话不支持读取客户端剪贴板，请使用终端的粘贴快捷键"
        return 1
      }
    fi
  elif [[ "$OSTYPE" == darwin* ]] && (( $+commands[pbcopy] && $+commands[pbpaste] )); then
    function clipcopy() { command cat < "${1:-/dev/stdin}" | command pbcopy; }
    function clippaste() { command pbpaste; }
  elif (( $+commands[clip.exe] && $+commands[powershell.exe] )); then
    function clipcopy() { command cat < "${1:-/dev/stdin}" | command clip.exe; }
    function clippaste() { command powershell.exe -NoProfile -Command Get-Clipboard; }
  elif [[ -n "${WAYLAND_DISPLAY-}" ]] && (( $+commands[wl-copy] && $+commands[wl-paste] )); then
    function clipcopy() { command cat < "${1:-/dev/stdin}" | command wl-copy &>/dev/null &|; }
    function clippaste() { command wl-paste --no-newline; }
  elif [[ -n "${DISPLAY-}" ]] && (( $+commands[xsel] )); then
    function clipcopy() { command cat < "${1:-/dev/stdin}" | command xsel --clipboard --input; }
    function clippaste() { command xsel --clipboard --output; }
  elif [[ -n "${DISPLAY-}" ]] && (( $+commands[xclip] )); then
    function clipcopy() { command cat < "${1:-/dev/stdin}" | command xclip -selection clipboard -in &>/dev/null &|; }
    function clippaste() { command xclip -selection clipboard -out; }
  elif [[ -n "${TMUX-}" ]] && (( $+commands[tmux] )); then
    function clipcopy() { command tmux load-buffer -w "${1:--}"; }
    function clippaste() { command tmux save-buffer -; }
  else
    return 1
  fi
}

# 首次调用时再检测后端，避免无图形环境的 SSH 会话在启动时产生错误。
function clipcopy clippaste {
  local requested_command="$0"
  if _dotfiles_detect_clipboard; then
    "$requested_command" "$@"
  else
    print -u2 -- "[dotfiles] 未找到可用的系统剪贴板工具"
    return 1
  fi
}

# Linux 上保留原先的使用习惯；macOS 已有原生命令时不覆盖。
(( $+commands[pbcopy] )) || alias pbcopy='clipcopy'
(( $+commands[pbpaste] )) || alias pbpaste='clippaste'

# 将文件内容复制到系统剪贴板。
function copyfile() {
  emulate -L zsh

  if (( $# != 1 )); then
    print -u2 -- "用法：copyfile <文件>"
    return 1
  fi

  local file="$1"
  if [[ ! -f "$file" || ! -r "$file" ]]; then
    print -u2 -- "[dotfiles] 文件不存在或不可读：$file"
    return 1
  fi

  clipcopy "$file" || return 1
  print -r -- "已复制文件内容：${file:a}"
}

# 不传参数时复制当前目录；传入文件或目录时复制其绝对路径。
function copypath() {
  emulate -L zsh

  if (( $# > 1 )); then
    print -u2 -- "用法：copypath [文件或目录]"
    return 1
  fi

  local target="${1:-.}"
  if [[ ! -e "$target" && ! -L "$target" ]]; then
    print -u2 -- "[dotfiles] 路径不存在：$target"
    return 1
  fi

  local absolute_path="${target:a}"
  print -rn -- "$absolute_path" | clipcopy || return 1
  print -r -- "已复制路径：$absolute_path"
}

# Ctrl-O 复制当前尚未执行的整条命令，方便粘贴到脚本、文档或聊天中。
function copybuffer() {
  if print -rn -- "$BUFFER" | clipcopy; then
    zle -M "已复制当前命令"
  else
    zle -M "复制失败：未找到可用的剪贴板后端"
    return 1
  fi
}

zle -N copybuffer
bindkey '^O' copybuffer
