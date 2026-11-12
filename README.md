# RightDragScroll

右ボタンを押しながらマウスを動かすとスクロールする macOS 用の常駐アプリ。Hammerspoon を使わずに同じことをする。

- 右ボタンを押しながら動かす → スクロール（カーソルは止まったまま）
- 動かさずに離す → 普通の右クリック

## インストール

### Homebrew

```sh
brew install isshi-hasegawa/tap/right-drag-scroll
brew services start right-drag-scroll
```

初回だけ「システム設定 → プライバシーとセキュリティ → アクセシビリティ」に
`/opt/homebrew/opt/right-drag-scroll/RightDragScroll.app` を追加してオンにする。

### ソースから

```sh
./install.sh
```

`~/Applications/RightDragScroll.app` を作り、ログイン時に自動起動するよう登録する。
初回だけ同じくアクセシビリティで RightDragScroll をオンにする。

## 設定

```sh
# スクロールの速さと向き（初期値 -4。マイナスで従来の向き、プラスで逆向き）
defaults write io.github.isshi-hasegawa.RightDragScroll scrollMultiplier -float -6

# 初期値に戻す
defaults delete io.github.isshi-hasegawa.RightDragScroll scrollMultiplier

# 今の設定を表示（Homebrew 版）
right-drag-scroll --show-settings
```

設定は右ボタンを押すたびに読み直すので、再起動は不要。

## アンインストール

```sh
# Homebrew
brew services stop right-drag-scroll
brew uninstall right-drag-scroll

# ソースから入れた場合
./uninstall.sh
```

## ライセンス

MIT
