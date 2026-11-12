# RightDragScroll

右ボタンを押しながらマウスを動かすとスクロールする macOS 用の常駐アプリ。Hammerspoon を使わずに同じことをする。

- 右ボタンを押しながら動かす → スクロール（カーソルは止まったまま）
- 動かさずに離す → 普通の右クリック

## インストール

```sh
./install.sh
```

`~/Applications/RightDragScroll.app` を作り、ログイン時に自動起動するよう登録する。
初回だけ「システム設定 → プライバシーとセキュリティ → アクセシビリティ」で RightDragScroll をオンにする。

## 設定

```sh
# スクロールの速さと向き（初期値 -4。マイナスで従来の向き、プラスで逆向き）
defaults write local.rightdragscroll scrollMultiplier -float -6

# 初期値に戻す
defaults delete local.rightdragscroll scrollMultiplier

# 今の設定を表示
~/Applications/RightDragScroll.app/Contents/MacOS/RightDragScroll --show-settings
```

設定は右ボタンを押すたびに読み直すので、再起動は不要。

## アンインストール

```sh
./uninstall.sh
```
