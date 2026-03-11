#!/bin/bash
# dotfiles インストールスクリプト
# 使い方: ./install.sh [--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false

if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  echo "[DRY-RUN] 実際のファイル操作は行いません"
  echo ""
fi

# --- デプロイマッピング ---
# 形式: "リポジトリ内パス:デプロイ先"
FILES=(
  "shell/.zshrc:$HOME/.zshrc"
  "shell/.zprofile:$HOME/.zprofile"
  "git/.gitconfig:$HOME/.gitconfig"
  "git/ignore:$HOME/.config/git/ignore"
  "claude/settings.json:$HOME/.claude/settings.json"
  "claude/config.json:$HOME/.claude/config.json"
  "claude/scripts/statusline.sh:$HOME/.claude/statusline.sh"
  "tmux/.tmux.conf:$HOME/.tmux.conf"
  "gh/config.yml:$HOME/.config/gh/config.yml"
  "gh/hosts.yml:$HOME/.config/gh/hosts.yml"
  "docker/config.json:$HOME/.docker/config.json"
)

# ディレクトリ単位でコピーするもの
DIRS=(
  "claude/hooks:$HOME/.claude/hooks"
  "claude/scripts:$HOME/.claude/scripts"
  "bin:$HOME/bin"
  "hammerspoon:$HOME/.hammerspoon"
  "launchagents:$HOME/Library/LaunchAgents"
)

# --- ヘルパー関数 ---
deploy_file() {
  local src="$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    echo "  [SKIP] $src が見つかりません"
    return
  fi

  local dest_dir
  dest_dir="$(dirname "$dest")"

  if $DRY_RUN; then
    if [ -f "$dest" ]; then
      if diff -q "$src" "$dest" >/dev/null 2>&1; then
        echo "  [OK]   ${dest}（変更なし）"
      else
        echo "  [DIFF] ${src} → ${dest}（差分あり）"
      fi
    else
      echo "  [NEW]  $src → $dest"
    fi
    return
  fi

  # ディレクトリ作成
  mkdir -p "$dest_dir"

  # 既存ファイルのバックアップ
  if [ -f "$dest" ]; then
    if diff -q "$src" "$dest" >/dev/null 2>&1; then
      echo "  [OK]   ${dest}（変更なし）"
      return
    fi
    cp "$dest" "${dest}.bak"
    echo "  [BAK]  $dest → ${dest}.bak"
  fi

  # テンプレート変数の置換（__HOME__ → 実際のホームディレクトリ）
  sed "s|__HOME__|$HOME|g" "$src" > "$dest"
  echo "  [COPY] $src → $dest"
}

deploy_dir() {
  local src_dir="$1"
  local dest_dir="$2"

  if [ ! -d "$src_dir" ]; then
    echo "  [SKIP] $src_dir が見つかりません"
    return
  fi

  for src_file in "$src_dir"/*; do
    [ -f "$src_file" ] || continue
    local filename
    filename="$(basename "$src_file")"
    deploy_file "$src_file" "$dest_dir/$filename"
  done
}

# --- メイン処理 ---
echo "=== dotfiles インストール ==="
echo "ソース: $DOTFILES_DIR"
echo ""

# 個別ファイルのデプロイ
echo "--- ファイル ---"
for mapping in "${FILES[@]}"; do
  src="${DOTFILES_DIR}/${mapping%%:*}"
  dest="${mapping#*:}"
  deploy_file "$src" "$dest"
done

echo ""
echo "--- ディレクトリ ---"
for mapping in "${DIRS[@]}"; do
  src="${DOTFILES_DIR}/${mapping%%:*}"
  dest="${mapping#*:}"
  echo "  [$src → $dest]"
  deploy_dir "$src" "$dest"
done

# スクリプトに実行権限を付与
if ! $DRY_RUN; then
  echo ""
  echo "--- 実行権限の付与 ---"
  chmod +x "$HOME"/.claude/hooks/*.sh 2>/dev/null && echo "  [OK] ~/.claude/hooks/*.sh"
  chmod +x "$HOME"/.claude/scripts/*.sh 2>/dev/null && echo "  [OK] ~/.claude/scripts/*.sh"
  chmod +x "$HOME"/bin/*.sh 2>/dev/null && echo "  [OK] ~/bin/*.sh"
fi

# Brewfile
echo ""
echo "--- Homebrew ---"
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  if $DRY_RUN; then
    echo "  [DRY-RUN] brew bundle install --file=$DOTFILES_DIR/Brewfile"
  else
    echo "  brew bundle install を実行します..."
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
  fi
else
  echo "  [SKIP] Brewfile が見つかりません"
fi

echo ""
echo "=== 完了 ==="
if $DRY_RUN; then
  echo "DRY-RUN モードでした。実際にデプロイするには --dry-run を外して実行してください。"
fi
