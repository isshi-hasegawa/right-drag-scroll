// RightDragScroll: Hammerspoon の init.lua と同じ動き
// - 右ボタンを押しながら動かす → スクロール（カーソルは動かない）
// - 動かさずに離す → 普通の右クリック
import Cocoa

let syntheticMark: Int64 = 0x52445343 // 自分で送ったクリックを見分ける印

// 設定は defaults で変更できる（右ボタンを押すたびに読み直す）
//   defaults write local.rightdragscroll scrollMultiplier -float -4
// マイナスで init.lua と同じ向き、プラスで逆向き。絶対値が大きいほど速い。
let defaultScrollMult: Double = -4    // init.lua の scrollmult と同じ
let appID = "local.rightdragscroll" as CFString
var scrollMult = defaultScrollMult

func reloadSettings() {
    CFPreferencesAppSynchronize(appID)
    if let v = CFPreferencesCopyAppValue("scrollMultiplier" as CFString, appID) as? NSNumber,
       v.doubleValue != 0 {
        scrollMult = v.doubleValue
    } else {
        scrollMult = defaultScrollMult
    }
}

var deferred = false
var tap: CFMachPort?
var downPos = CGPoint.zero

func postRight(_ type: CGEventType, at p: CGPoint) {
    let src = CGEventSource(stateID: .hidSystemState)
    let e = CGEvent(mouseEventSource: src, mouseType: type, mouseCursorPosition: p, mouseButton: .right)
    e?.setIntegerValueField(.mouseEventClickState, value: 1)
    e?.setIntegerValueField(.eventSourceUserData, value: syntheticMark)
    e?.post(tap: .cgSessionEventTap)
}

func postRightClick(at p: CGPoint) {
    // コールバックの外で、押す→少し待って離す、の順に送る
    DispatchQueue.main.async {
        postRight(.rightMouseDown, at: p)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            postRight(.rightMouseUp, at: p)
        }
    }
}

let callback: CGEventTapCallBack = { _, type, event, _ in
    // タップが無効化されたら再開する
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let t = tap { CGEvent.tapEnable(tap: t, enable: true) }
        return Unmanaged.passUnretained(event)
    }
    // 自分で送った右クリックは素通しする
    if event.getIntegerValueField(.eventSourceUserData) == syntheticMark {
        return Unmanaged.passUnretained(event)
    }

    switch type {
    case .rightMouseDown:
        deferred = true
        downPos = event.location
        reloadSettings()
        CGAssociateMouseAndMouseCursorPosition(0)    // 押している間カーソルを止める
        return nil                                   // いったん止める

    case .rightMouseUp:
        CGAssociateMouseAndMouseCursorPosition(1)
        if deferred {
            deferred = false
            postRightClick(at: downPos)              // 動かさずに離した → 右クリック
        }
        return nil

    case .rightMouseDragged:
        deferred = false
        let dx = Double(event.getIntegerValueField(.mouseEventDeltaX))
        let dy = Double(event.getIntegerValueField(.mouseEventDeltaY))
        if let scroll = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2,
                                wheel1: Int32(dy * scrollMult), wheel2: Int32(dx * scrollMult), wheel3: 0) {
            scroll.location = downPos
            scroll.post(tap: .cghidEventTap)
        }
        CGWarpMouseCursorPosition(downPos)           // 念のため元の位置に戻す
        CGAssociateMouseAndMouseCursorPosition(0)
        return nil                                   // ドラッグ自体は捨てる → カーソルは動かない

    default:
        return Unmanaged.passUnretained(event)
    }
}

// 今の設定を表示して終わる
if CommandLine.arguments.contains("--show-settings") {
    reloadSettings()
    print("scrollMultiplier = \(scrollMult)")
    exit(0)
}

// アクセシビリティ許可の確認（無ければ許可ダイアログを出す）
let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
if !AXIsProcessTrustedWithOptions(opts) {
    print("アクセシビリティの許可が必要です。許可してから再起動してください。")
}

let mask = (1 << CGEventType.rightMouseDown.rawValue)
         | (1 << CGEventType.rightMouseUp.rawValue)
         | (1 << CGEventType.rightMouseDragged.rawValue)

guard let t = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap,
                                options: .defaultTap, eventsOfInterest: CGEventMask(mask),
                                callback: callback, userInfo: nil) else {
    print("イベントタップを作成できませんでした（許可が無い可能性）")
    exit(1)
}
tap = t
let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, t, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
CGEvent.tapEnable(tap: t, enable: true)
print("RightDragScroll 起動中")
CFRunLoopRun()
