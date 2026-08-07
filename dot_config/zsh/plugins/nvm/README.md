# NVM 插件

插件默认延迟加载 NVM，并自动扫描各 Node 版本的 `bin` 目录。直接执行 `node`、`npm`、`codex` 等已安装命令即可，首次调用会加载 NVM。

进入包含 `.nvmrc` 的项目时会自动切换 Node 版本；版本未安装时执行：

```zsh
nvm install
```

可在 `~/.config/zsh/local-before.zsh` 中覆盖配置：

```zsh
# 禁用延迟加载
typeset -g ZSH_NVM_LAZY=false

# 禁用 .nvmrc 自动切换
typeset -g ZSH_NVM_AUTO_USE=false

# 添加无法从 NVM bin 目录扫描到的额外触发命令
typeset -ga ZSH_NVM_LAZY_EXTRA_COMMANDS=(vim)
```
