移行方針: クリーンインストール方式

 Apple移行アシスタントはゴミも含め丸ごとコピーするため使わない。Mac Miniにゼロからセットアップする。

 ---
 Step 1: Mac Mini で Homebrew + CLIツールをセットアップ

 # Homebrew インストール
 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

 # 現在MacBookで使っているformula
 brew install node pnpm gh terraform supabase cocoapods ruby

 # Google Cloud SDK
 curl https://sdk.cloud.google.com | bash

 Step 2: GUIアプリのインストール

 開発・仕事系:
 - Google Chrome
 - Slack
 - Discord
 - Notion
 - Obsidian
 - Claude
 - Xcode（App Store）
 - Google Drive
 - Microsoft Office（Excel, Word, Outlook）

 ユーティリティ:
 - Raycast
 - Clipy
 - MillenVPN

 コミュニケーション・メディア:
 - LINE
 - Zoom
 - Spotify
 - Amazon Kindle

 行政系（確定申告時に必要なら）:
 - e-Gov電子申請アプリケーション
 - JPKI利用者ソフト
 - ELPKI

 移行しないアプリ:
 - Antigravity（不要）
 - 夢アプリ（不要）
 - iMovie（Mac Miniにプリインストール済み）

 Step 3: 設定ファイルをコピー

 MacBook Air → Mac Mini にコピーするもの:

 # 1. SSH鍵（最重要 - GitHubアクセスに必要）
 scp -r ~/.ssh/ macmini:~/.ssh/
 # Mac Mini側でパーミッション設定
 ssh macmini 'chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519 ~/.ssh/google_compute_engine'

 # 2. Git設定
 scp ~/.gitconfig macmini:~/.gitconfig

 # 3. シェル設定
 scp ~/.zshrc macmini:~/.zshrc
 scp ~/.zprofile macmini:~/.zprofile
 # ※ Mac Miniでは .zshrc からAntigravity関連の行を削除すること
 # ※ Claude Code OAuthトークンの行も削除し、Mac Miniで `claude login` を実行

 # 4. Claude Code設定
 scp ~/.claude/settings.json macmini:~/.claude/settings.json
 scp ~/.claude/config.json macmini:~/.claude/config.json

 Step 4: 開発プロジェクトを Git から再clone

 全プロジェクトがGitHubにpush済み。node_modules等を含まないクリーンな状態で取得:

 mkdir -p ~/dev ~/hobby
 cd ~/dev

 # MachineTechnologies（仕事）
 git clone git@github.com:MachineTechnologies/quumo.git
 git clone git@github.com:MachineTechnologies/grantnav.git
 git clone git@github.com:MachineTechnologies/quumo.ai.git
 git clone git@github.com:MachineTechnologies/business-evaluation.git
 git clone git@github.com:MachineTechnologies/toritekicloud.git

 # rioping（個人）
 git clone git@github.com:rioping/tennis-court-sniper-bot.git
 git clone git@github.com:rioping/wework-invitation-bot.git
 git clone git@github.com:rioping/openclaw.git

 各プロジェクトで pnpm install / npm install を実行して依存関係を再構築。

 Step 5: SSH接続の設定（後日）

 Mac Miniに外出先からSSH接続するための設定は後日決定。
 選択肢: Tailscale（推奨）/ ポートフォワーディング+DDNS

 ---
 移行前の確認事項

 各リポジトリに未pushの変更がないか確認すること:
 cd ~/dev && for d in */; do echo "=== $d ===" && (cd "$d" && git status -s && git log origin/main..HEAD --oneline 2>/dev/null || git
  log origin/master..HEAD --oneline 2>/dev/null); done

 ---
 セキュリティ警告

 ~/.zshrc にClaude Code OAuthトークンがハードコードされています。
 Mac Miniではこの行を削除し、claude login で新しいトークンを取得してください。
 移行時に .zshrc ファイルを他人と共有しないよう注意してください。