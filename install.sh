#!/bin/zsh
# ビルドして ~/Applications/RightDragScroll.app に入れ、ログイン時に自動起動するよう登録する
set -euo pipefail

cd "${0:A:h}"
APP="$HOME/Applications/RightDragScroll.app"
BUNDLE_ID="local.rightdragscroll"
LABEL="$BUNDLE_ID"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# 1. ビルド
mkdir -p build
swiftc -O Sources/main.swift -o build/RightDragScroll

# 2. アプリの形にまとめる
mkdir -p "$APP/Contents/MacOS"
cp build/RightDragScroll "$APP/Contents/MacOS/RightDragScroll"
cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
<key>CFBundleName</key><string>RightDragScroll</string>
<key>CFBundleExecutable</key><string>RightDragScroll</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>2</string>
<key>LSUIElement</key><true/>
</dict></plist>
EOF

# 3. 署名（作り直してもアクセシビリティの許可が外れにくいよう、識別子だけを条件にする）
codesign --force --sign - -r="designated => identifier \"$BUNDLE_ID\"" "$APP"

# 4. ログイン時の自動起動（落ちたら自動で再起動）
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>$LABEL</string>
<key>ProgramArguments</key><array><string>$APP/Contents/MacOS/RightDragScroll</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><true/>
<key>ThrottleInterval</key><integer>10</integer>
<key>ProcessType</key><string>Interactive</string>
</dict></plist>
EOF

# 5. 起動し直す
pkill -x RightDragScroll 2>/dev/null || true
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "インストールしました: $APP"
