# 个人dotfile配置仓库
该仓库为个人dotfile配置备份跟踪仓库，采用`chezmoi`进行自动部署

新电脑初始化
```zsh
chezmoi init https://github.com/KidsZZ/dotfile.git
chezmoi diff
chezmoi apply

或者
chezmoi init --apply https://github.com/KidsZZ/dotfile.git
```
## zsh

Zsh 采用自行维护的模块化框架，参考 Oh My Zsh实现。

架构：

`.zshrc` 作为顶层配置文件，配置主题以及插件开关

`.config/zsh` 存放具体配置信息。其中：

- `lib`存放程序无关的普适配置文件，修改 zsh 默认行为
- `plugins`存放各个程序的插件，用于自动补全以及默认配置
- `themes`存放终端主题，其中powerlevel10k为引擎适配器
- `local-before` 中存本地程序path信息
- `local-after`中存敏感信息，比如api-key，不加入github跟踪

`dot_p10k.zsh`存放p10k配置文件，并手动关闭右侧显示

> Powerlevel10k、zsh-autosuggestions 和 zsh-syntax-highlighting 由 `.chezmoiexternal.toml` 固定版本并安装。
