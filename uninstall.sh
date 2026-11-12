#!/bin/zsh
# 自動起動を解除し、アプリを削除する（アクセシビリティの一覧からの削除は手動）
set -uo pipefail
LABEL="io.github.isshi-hasegawa.RightDragScroll"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist"
pkill -x RightDragScroll 2>/dev/null
rm -rf "$HOME/Applications/RightDragScroll.app"
echo "アンインストールしました"
