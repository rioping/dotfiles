# Homebrew path for Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
alias py314="/Library/Frameworks/Python.framework/Versions/3.14/bin/python3"
alias pip314="/Library/Frameworks/Python.framework/Versions/3.14/bin/pip3"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

# Added by Claude Code setup
# CLAUDE_CODE_OAUTH_TOKEN は claude login で取得すること
export PATH="$HOME/.claude/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# zsh履歴にタイムスタンプを記録（ライフログ用）
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
HISTSIZE=50000
SAVEHIST=50000
