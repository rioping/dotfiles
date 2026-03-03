# dotfiles

Mac のカスタム設定を一元管理するリポジトリ。新しい Mac への移行時に `install.sh` で全設定を再現できる。

## ディレクトリ構成

```
dotfiles/
├── install.sh                        # インストールスクリプト（--dry-run 対応）
├── Brewfile                          # Homebrew パッケージ一覧
├── shell/
│   ├── .zshrc                        # → ~/.zshrc
│   └── .zprofile                     # → ~/.zprofile
├── git/
│   ├── .gitconfig                    # → ~/.gitconfig
│   └── ignore                        # → ~/.config/git/ignore
├── claude/
│   ├── settings.json                 # → ~/.claude/settings.json
│   ├── config.json                   # → ~/.claude/config.json
│   ├── hooks/
│   │   ├── state-update.sh           # → ~/.claude/hooks/
│   │   ├── state-stop.sh
│   │   ├── session-start.sh
│   │   └── pre-bash.sh
│   └── scripts/
│       ├── statusline-command.sh     # → ~/.claude/scripts/
│       ├── tmux-pane-status.sh
│       ├── tmux-window-status.sh
│       └── tmux-pane-colors.sh
├── hammerspoon/
│   └── init.lua                      # → ~/.hammerspoon/init.lua
├── tmux/
│   └── .tmux.conf                    # → ~/.tmux.conf
├── gh/
│   ├── config.yml                    # → ~/.config/gh/
│   └── hosts.yml
├── docker/
│   └── config.json                   # → ~/.docker/config.json
├── bin/
│   └── claude-sessions.sh            # → ~/bin/
├── macos/
│   ├── setup.md                      # Mac セットアップ手順
│   └── keyboard-and-trackpad.md      # トラックパッド・キーボード設定
└── launchagents/
    └── com.productivity.macbook-export.plist  # → ~/Library/LaunchAgents/
```

## 使い方

```bash
# クローン
git clone git@github.com:rioping/dotfiles.git ~/dev/dotfiles

# プレビュー（ファイルは変更しない）
./install.sh --dry-run

# インストール（既存ファイルは .bak にバックアップ）
./install.sh
```

## Claude Code Hooks

| イベント | 動作 |
|---------|------|
| `UserPromptSubmit` | → thinking（🧠） |
| `SessionStart` | → starting（🚀）+ CLAUDE.md / git チェック |
| `PreToolUse (Bash)` | → git push 前に CLAUDE.md 鮮度チェック |
| `PermissionRequest` | → permission（🛑）+ 音声 + macOS 通知 |
| `Stop` | → completed（✅）or waiting（💬）+ 音声 + macOS 通知 |

## tmux セッション状態の可視化

| 状態 | 絵文字 | ボーダー色 |
|------|--------|-----------|
| 思考中 | 🧠 | `#a6e3a1` グリーン |
| 完了 | ✅ | `#a6adc8` グレー |
| 入力待ち | 💬 | `#fab387` オレンジ |
| 許可待ち | 🛑 | `#f38ba8` レッド |
| 起動中 | 🚀 | `#89b4fa` ブルー |

## Hammerspoon

マウスドラッグ終了時に `Cmd+C` を自動送信し、全アプリで「選択即コピー」を実現。Terminal.app は除外（tmux の `MouseDragEnd` + `pbcopy` と競合するため）。

## statusline 表示

`ctx:45% | 5h:23%(2h30m) | 7d:12%` の形式でコンテキスト使用率と API 使用率を表示。API 取得失敗時は `5h:-- | 7d:--` にフォールバック。

## 追跡しないもの

- `~/.claude/settings.local.json` — 自動生成の許可リスト
- `~/.zshrc` の OAuth トークン — `claude login` で取得
- `~/.ssh/*` — 秘密鍵
- `~/.config/gcloud/*`, `~/.config/firebase/*` — 認証情報

## Git ルール

- コミットメッセージは日本語で書くこと
- カラーコードは Catppuccin Mocha パレットに準拠
- シェルスクリプトは `#!/bin/bash` を使用
