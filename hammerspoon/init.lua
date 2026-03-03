-- CLI 連携用
require("hs.ipc")

-- マウス選択時の自動コピー
-- ドラッグ終了時に Cmd+C を送信してクリップボードにコピーする

-- Terminal.app は除外（tmux の MouseDragEnd + pbcopy と競合するため）
local excludedApps = {
  ["Terminal"] = true,
}

dragStartPos = nil
MIN_DRAG_DISTANCE = 10 -- ピクセル（クリック操作を無視するための閾値）

function distance(p1, p2)
  local dx = p1.x - p2.x
  local dy = p1.y - p2.y
  return math.sqrt(dx * dx + dy * dy)
end

-- マウスドラッグ開始を検知
dragStart = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(e)
  dragStartPos = { x = e:location().x, y = e:location().y }
  return false
end)

-- マウスドラッグ終了を検知して Cmd+C を送信
dragEnd = hs.eventtap.new({ hs.eventtap.event.types.leftMouseUp }, function(e)
  if dragStartPos == nil then
    return false
  end

  local endPos = { x = e:location().x, y = e:location().y }

  -- クリック操作（移動距離が短い）はスキップ
  if distance(dragStartPos, endPos) < MIN_DRAG_DISTANCE then
    dragStartPos = nil
    return false
  end

  -- 除外アプリのチェック
  local app = hs.application.frontmostApplication()
  if app and excludedApps[app:name()] then
    dragStartPos = nil
    return false
  end

  -- 少し遅延させてから Cmd+C を送信（選択が確定するのを待つ）
  hs.timer.doAfter(0.05, function()
    hs.eventtap.keyStroke({ "cmd" }, "c")
  end)

  dragStartPos = nil
  return false
end)

dragStart:start()
dragEnd:start()
