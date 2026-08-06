# Debian/Ubuntu 会将部分命令改名；仅在标准命令不存在时提供兼容别名。
if (( ! $+commands[fd] && $+commands[fdfind] )); then
  alias fd='fdfind'
fi

if (( ! $+commands[bat] && $+commands[batcat] )); then
  alias bat='batcat'
fi
