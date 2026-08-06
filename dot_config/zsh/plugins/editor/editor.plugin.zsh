# 编辑器检测依赖 local-before.zsh 已经准备好的 PATH，因此在插件阶段执行。
# $commands 是 Zsh 的命令索引；优先使用 Neovim，不存在时退回 Vim。
if (( $+commands[nvim] )); then
  export EDITOR='nvim'
  export VISUAL='nvim'
elif (( $+commands[vim] )); then
  export EDITOR='vim'
  export VISUAL='vim'
fi
