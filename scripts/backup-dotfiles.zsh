#!/usr/bin/env zsh

# 将当前机器上的 dotfiles 和 exact external 目录保存为可恢复快照。
# 默认备份目录不受 chezmoi 管理，避免 apply 或恢复过程覆盖备份本身。

emulate -LR zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL
umask 077

die() {
    print -u2 -- "错误：$*"
    exit 1
}

[[ -n "${HOME:-}" && "$HOME" != "/" ]] || die "HOME 目录无效"
command -v tar >/dev/null 2>&1 || die "缺少 tar 命令"

typeset -r backup_dir="${DOTFILES_BACKUP_DIR:-$HOME/.local/state/dotfiles-backups}"
typeset -r timestamp="$(date +%Y%m%d-%H%M%S)"
typeset -r backup_name="dotfiles-${timestamp}.tar.gz"
typeset -r backup_file="$backup_dir/$backup_name"
typeset -r checksum_file="${backup_file}.sha256"

# 这些路径覆盖仓库直接管理的 Zsh 配置，以及 exact=true 的 external 目录。
typeset -ar managed_targets=(
    .zshrc
    .p10k.zsh
    .config/zsh
    .local/share/powerlevel10k
    .local/share/zsh/plugins/zsh-autosuggestions
    .local/share/zsh/plugins/zsh-syntax-highlighting
)

typeset -a existing_targets=()
typeset relative_path target_path

for relative_path in "${managed_targets[@]}"; do
    target_path="$HOME/$relative_path"
    if [[ "$backup_file" == "$target_path" || "$backup_file" == "$target_path/"* ]]; then
        die "备份目录不能位于受管目标内：$backup_dir"
    fi

    # -L 同时识别目标不存在的失效符号链接。
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        existing_targets+=("$relative_path")
    fi
done

command mkdir -p -- "$backup_dir"
[[ ! -e "$backup_file" && ! -e "$checksum_file" ]] || die "同名备份已经存在：$backup_file"

if (( ${#existing_targets[@]} > 0 )); then
    command tar -C "$HOME" -czf "$backup_file" -- "${existing_targets[@]}"
else
    # 所有目标都不存在时仍创建一个有效的空快照，恢复时会删除 apply 新建的目标。
    command tar -C "$HOME" -czf "$backup_file" -T /dev/null
fi

# 校验文件只记录归档文件名，保证整个备份目录移动后仍可验证。
if command -v sha256sum >/dev/null 2>&1; then
    (
        cd "$backup_dir"
        command sha256sum "$backup_name" > "${backup_name}.sha256"
    )
elif command -v shasum >/dev/null 2>&1; then
    (
        cd "$backup_dir"
        command shasum -a 256 "$backup_name" > "${backup_name}.sha256"
    )
else
    command rm -f -- "$backup_file"
    die "缺少 sha256sum 或 shasum，已删除无法校验的备份"
fi

command chmod 600 -- "$backup_file" "$checksum_file"

print -- "备份完成：$backup_file"
print -- "校验文件：$checksum_file"
