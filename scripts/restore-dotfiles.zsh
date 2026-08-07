#!/usr/bin/env zsh

# 从 backup-dotfiles.zsh 创建的快照恢复 dotfiles。
# 为了准确恢复“原本不存在”的路径，解压前会删除当前受管目标。

emulate -LR zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

die() {
    print -u2 -- "错误：$*"
    exit 1
}

usage() {
    print -u2 -- "用法：${0:t} [--yes] <dotfiles-YYYYMMDD-HHMMSS.tar.gz>"
    print -u2 -- "  --yes  跳过交互确认，适用于已经人工确认过备份路径的场景"
    exit 2
}

[[ -n "${HOME:-}" && "$HOME" != "/" ]] || die "HOME 目录无效"
command -v tar >/dev/null 2>&1 || die "缺少 tar 命令"

typeset -i auto_confirm=0
if [[ "${1:-}" == "--yes" ]]; then
    auto_confirm=1
    shift
fi

(( $# == 1 )) || usage

typeset -r backup_file="${1:A}"
typeset -r checksum_file="${backup_file}.sha256"
typeset -r backup_dir="${backup_file:h}"
typeset -r backup_name="${backup_file:t}"

[[ -f "$backup_file" ]] || die "备份文件不存在：$backup_file"
[[ -f "$checksum_file" ]] || die "校验文件不存在：$checksum_file"

typeset -ar managed_targets=(
    .zshrc
    .p10k.zsh
    .config/zsh
    .local/share/powerlevel10k
    .local/share/zsh/plugins/zsh-autosuggestions
    .local/share/zsh/plugins/zsh-syntax-highlighting
)

# 防止用户把备份放进即将删除的目标目录，导致恢复中途丢失归档。
typeset relative_path target_path
for relative_path in "${managed_targets[@]}"; do
    target_path="$HOME/$relative_path"
    if [[ "$backup_file" == "$target_path" || "$backup_file" == "$target_path/"* ]]; then
        die "备份文件位于待恢复目录内，请先移动备份：$backup_file"
    fi
done

# 自行计算归档摘要，不直接执行校验文件中可能被篡改的路径。
typeset expected_hash checksum_rest actual_hash
IFS=' ' read -r expected_hash checksum_rest < "$checksum_file" || die "无法读取校验文件"

if (( ${#expected_hash} != 64 )) || [[ "$expected_hash" == *[^0-9a-fA-F]* ]]; then
    die "校验文件中的 SHA-256 格式无效"
fi

if command -v sha256sum >/dev/null 2>&1; then
    actual_hash="$(command sha256sum "$backup_file")"
elif command -v shasum >/dev/null 2>&1; then
    actual_hash="$(command shasum -a 256 "$backup_file")"
else
    die "缺少 sha256sum 或 shasum"
fi
actual_hash="${actual_hash%% *}"

[[ "${actual_hash:l}" == "${expected_hash:l}" ]] || die "备份文件校验失败，拒绝恢复"

# 先确认 tar 可以完整读取，再限制归档成员只能落入预期路径。
command tar -tzf "$backup_file" >/dev/null || die "备份文件不是有效的 tar.gz 归档"

typeset -i archive_safe=1
typeset archive_entry normalized_entry
while IFS= read -r archive_entry; do
    normalized_entry="${archive_entry#./}"
    normalized_entry="${normalized_entry%/}"
    [[ -z "$normalized_entry" ]] && continue

    case "$normalized_entry" in
        .zshrc | \
        .p10k.zsh | \
        .config/zsh | \
        .config/zsh/* | \
        .local/share/powerlevel10k | \
        .local/share/powerlevel10k/* | \
        .local/share/zsh/plugins/zsh-autosuggestions | \
        .local/share/zsh/plugins/zsh-autosuggestions/* | \
        .local/share/zsh/plugins/zsh-syntax-highlighting | \
        .local/share/zsh/plugins/zsh-syntax-highlighting/*)
            ;;
        *)
            print -u2 -- "归档包含非预期路径：$archive_entry"
            archive_safe=0
            ;;
    esac
done < <(command tar -tzf "$backup_file")

(( archive_safe == 1 )) || die "备份路径校验失败，拒绝恢复"

print -- "即将使用以下备份覆盖当前 dotfiles："
print -- "  $backup_file"
print -- "恢复前会删除以下路径，以确保不存在备份中的文件不会被残留："
for relative_path in "${managed_targets[@]}"; do
    print -- "  $HOME/$relative_path"
done

if (( auto_confirm == 0 )); then
    typeset reply
    if ! read -r "reply?确认恢复？输入 y 继续 [y/N]："; then
        die "无法读取确认输入"
    fi
    [[ "$reply" == [yY] ]] || die "已取消恢复"
fi

# 删除范围严格限定为上面列出的六个目标，不触碰 HOME 中的其他内容。
for relative_path in "${managed_targets[@]}"; do
    command rm -rf -- "$HOME/$relative_path"
done

command tar -C "$HOME" -xzpf "$backup_file"

print -- "恢复完成。请先修正 chezmoi 源状态，再重新运行 chezmoi apply。"

