#!/usr/bin/env bash
set -euo pipefail

# brain-first — 多 coding agent 一键安装/卸载
# 用法:
#   ./install.sh            # 安装到所有已存在的 agent skill 目录（幂等）
#   ./install.sh --uninstall  # 从所有目录卸载
#
# Windows 用户请用 Git Bash 运行；PowerShell 可执行 `bash install.sh`

SKILL_NAME="brain-first"
SKILL_SRC="$(cd "$(dirname "$0")" && pwd)/skills/$SKILL_NAME"
MODE="${1:-install}"

# 各 agent 的全局 skill 目录（目录不存在则跳过，OpenCode 会读 ~/.claude/skills 与 ~/.agents/skills）
TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.kimi-code/skills"
  "$HOME/.codex/skills"
  "$HOME/.agents/skills"
  "$HOME/.config/opencode/skills"
)

case "$MODE" in
  install)
    if [ ! -d "$SKILL_SRC" ]; then
      echo "错误：找不到 skill 源目录 $SKILL_SRC" >&2
      exit 1
    fi
    installed=0
    for dir in "${TARGETS[@]}"; do
      [ -d "$dir" ] || continue
      # 先删后拷，保证与源完全一致（cp -r 合并复制不会删除源中已移除的文件）
      rm -rf "$dir/$SKILL_NAME"
      cp -r "$SKILL_SRC" "$dir/"
      echo "已安装 -> $dir/$SKILL_NAME"
      installed=$((installed + 1))
    done
    if [ "$installed" -eq 0 ]; then
      echo "未检测到任何已安装的 coding agent 目录。" >&2
      echo "手动安装：将 skills/$SKILL_NAME 复制到对应工具的 skills 目录（见 README）。" >&2
      exit 1
    fi
    echo "完成：已安装到 $installed 个目录。新开会话即可使用。"
    ;;
  --uninstall)
    removed=0
    for dir in "${TARGETS[@]}"; do
      [ -d "$dir/$SKILL_NAME" ] || continue
      rm -rf "$dir/$SKILL_NAME"
      echo "已卸载 <- $dir/$SKILL_NAME"
      removed=$((removed + 1))
    done
    echo "完成：从 $removed 个目录卸载。"
    ;;
  *)
    echo "用法: ./install.sh [install|--uninstall]" >&2
    exit 1
    ;;
esac
