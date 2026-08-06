# pdf2zh 未安装时不定义包装函数，保持插件静默且无副作用。
(( $+commands[pdf2zh] )) || return 0

# 密钥必须由未纳入 chezmoi 的 local.zsh 或系统秘密管理工具提供。
function pdf2zh() {
  if [[ -z "${SILICON_API_KEY-}" ]]; then
    print -u2 -- "[dotfiles] 未设置 SILICON_API_KEY，无法调用 pdf2zh 的 silicon 服务"
    return 1
  fi

  local model="${SILICON_MODEL:-Qwen/Qwen3-VL-8B-Instruct}"
  local threads="${PDF2ZH_THREADS:-4}"

  SILICON_API_KEY="$SILICON_API_KEY" \
  SILICON_MODEL="$model" \
    command pdf2zh --service silicon --thread "$threads" "$@"
}
