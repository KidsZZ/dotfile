# ==============================================================================
# 插件加载前的公开配置
# ==============================================================================

# cargo
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"


# toolchains
# 声明一个普通 Zsh 数组，按希望的优先级列出本机可能存在的命令目录。
# 此处只登记候选路径，下面会过滤不存在的目录，避免污染 PATH。
typeset -a _dotfiles_local_bin_dirs=(
  "$CARGO_HOME/bin"                                  # Cargo 安装的用户级命令。
  /opt/toolchains/x86_64-linux-musl-cross/bin         # x86_64 musl 交叉编译工具链。
  /opt/toolchains/aarch64-linux-musl-cross/bin        # AArch64 musl 交叉编译工具链。
  /opt/toolchains/riscv64-linux-musl-cross/bin        # RISC-V 64 位 musl 交叉编译工具链。
  /opt/toolchains/loongarch64-linux-musl-cross/bin    # LoongArch 64 位 musl 交叉编译工具链。
)
# 创建空数组，用来保存经过目录存在性检查后的有效路径。
typeset -a _dotfiles_existing_bin_dirs
# 逐个读取候选目录。
for _dotfiles_bin_dir in "${_dotfiles_local_bin_dirs[@]}"; do
  # -d 判断目录是否存在；只有存在时才追加到有效路径数组。
  [[ -d "$_dotfiles_bin_dir" ]] && _dotfiles_existing_bin_dirs+=("$_dotfiles_bin_dir")
done
# path 是 Zsh 与 PATH 自动同步的数组；把有效目录整体放到原 PATH 前面。
# dot_zshrc 已将 path 声明为唯一数组，因此重复目录会被自动去除。
path=("${_dotfiles_existing_bin_dirs[@]}" $path)
# 临时数组和循环变量完成使命后立即清理，避免污染交互式 Shell。
unset _dotfiles_bin_dir _dotfiles_existing_bin_dirs _dotfiles_local_bin_dirs

snet() {
    local DEFAULT_PROXY="http://127.0.0.1:7890"
    local TARGET_PROXY="${CUSTOM_PROXY:-$DEFAULT_PROXY}"
    
    (
        export http_proxy="$TARGET_PROXY"
        export https_proxy="$TARGET_PROXY"
        export ftp_proxy="$TARGET_PROXY"
        export all_proxy="$TARGET_PROXY"
        "$@"
    )
}