# ==============================================================================
# Zsh 交互行为
# ==============================================================================

# 直接输入目录即可进入，并保留一份去重后的目录栈。
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# 允许在交互命令中写注释，并关闭终端错误提示音。
setopt INTERACTIVE_COMMENTS
unsetopt BEEP

