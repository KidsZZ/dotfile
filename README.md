# 个人dotfile配置仓库
该仓库为个人dotfile配置备份跟踪仓库，采用`chezmoi`进行自动部署

新电脑初始化:

1. clone 该仓库

```zsh
chezmoi init https://github.com/KidsZZ/dotfile.git
```
或 使用 **git** 进行 clone (注意chezmoi默认地址为`~/.local/share/chezmoi/`, 建议复制到该地址)

```zsh
git clone https://github.com/KidsZZ/dotfile.git ~/.local/share/chezmoi
```

2. 备份配置文件(推荐)

该脚本将当前配置文件备份到`~/.local/state/dotfiles-backups/dotfiles-YYYYMMDD-HHMMSS.tar.gz`, 并生成sha256校验文件
```zsh
./scripts/backup-dotfiles.zsh
```

3. 应用新的配置文件
```zsh
# 检查修改
chezmoi diff

# 确认应用
chezmoi apply
```

4. 备份恢复
```zsh
# 查看有哪些备份
ls -lt ~/.local/state/dotfiles-backups/

# 选择恢复
./scripts/restore-dotfiles.zsh ~/.local/state/dotfiles-backups/dotfiles-YYYYMMDD-HHMMSS.tar.gz
```
## zsh

Zsh 采用自行维护的模块化框架，参考 Oh My Zsh实现。

架构：

`.zshrc` 作为顶层配置文件，配置主题以及插件开关

`.config/zsh` 存放具体配置信息。其中：

- `lib`存放程序无关的普适配置文件，修改 zsh 默认行为
- `plugins`存放各个程序的插件，用于自动补全以及默认配置
- `themes`存放终端主题，其中powerlevel10k为引擎适配器
- `local-before` 中存本地程序path信息(需要根据**电脑实际情况**进行修改)
- `local-after`中存敏感信息，比如api-key，不加入github跟踪

`dot_p10k.zsh`存放p10k配置文件，并手动关闭右侧显示

> Powerlevel10k、zsh-autosuggestions 和 zsh-syntax-highlighting 由 `.chezmoiexternal.toml` 固定版本并安装。
