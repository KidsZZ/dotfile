# zoxide 不存在时静默跳过，避免配置在未安装该工具的电脑上报错。
(( $+commands[zoxide] )) || return 0

# zoxide init 会生成当前 Zsh 所需的函数和目录切换 hook，因此必须在当前 Shell 中执行。
# 默认提供 z 和 zi；如需改名，可在插件加载前设置 ZOXIDE_CMD_OVERRIDE。
eval "$("${commands[zoxide]}" init --cmd "${ZOXIDE_CMD_OVERRIDE:-z}" zsh)"
