# eza 不存在时保留 lib/60-aliases.zsh 提供的系统 ls 别名。
(( $+commands[eza] )) || return 0

# 插件直接提供个人配置的默认值，同时允许预先声明同名 zstyle 进行覆盖。
typeset -a _dotfiles_eza_options
typeset _dotfiles_eza_dirs_first
typeset _dotfiles_eza_icons
typeset _dotfiles_eza_time_style

# 没有外部配置时，默认启用目录优先和自动图标。
zstyle -s ':dotfiles:plugins:eza' dirs-first _dotfiles_eza_dirs_first || _dotfiles_eza_dirs_first='yes'
zstyle -s ':dotfiles:plugins:eza' icons _dotfiles_eza_icons || _dotfiles_eza_icons='yes'

if [[ "${_dotfiles_eza_dirs_first:l}" == yes ]]; then
  _dotfiles_eza_options+=(--group-directories-first)
fi

if [[ "${_dotfiles_eza_icons:l}" == yes ]]; then
  _dotfiles_eza_options+=(--icons=auto)
fi

# 默认使用统一时间格式；将 time-style 覆盖为空字符串即可关闭该选项。
zstyle -s ':dotfiles:plugins:eza' time-style _dotfiles_eza_time_style \
  || _dotfiles_eza_time_style='+%Y-%m-%d %H:%M:%S'
if [[ -n "$_dotfiles_eza_time_style" ]]; then
  _dotfiles_eza_options+=("--time-style='$_dotfiles_eza_time_style'")
fi

# 将公共选项展开进别名，插件加载完成后即可清理临时变量和辅助函数。
function _dotfiles_alias_eza() {
  local alias_name="$1"
  local alias_flags="$2"
  local common_options="${(j: :)_dotfiles_eza_options}"
  local alias_command="eza"

  [[ -n "$alias_flags" ]] && alias_command+=" $alias_flags"
  [[ -n "$common_options" ]] && alias_command+=" $common_options"
  alias "$alias_name=$alias_command"
}

_dotfiles_alias_eza ls ''
_dotfiles_alias_eza ll '-lh'
_dotfiles_alias_eza la '-lha'
_dotfiles_alias_eza lg '-lha --git'
_dotfiles_alias_eza tree '--tree'

unfunction _dotfiles_alias_eza
unset _dotfiles_eza_dirs_first _dotfiles_eza_icons
unset _dotfiles_eza_options _dotfiles_eza_time_style
