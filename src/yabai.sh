#!/bin/bash

# 定义 get_yabai_action 函数
get_yabai_action() {
  cat <<EOB
{
  "items": [
    {
      "title": "Toggle Layout",
      "subtitle": "切换布局",
      "arg": "toggle_layout",
    },
    {
      "title": "Cycle Clockwise",
      "subtitle":"顺时针循环调整窗口",
      "arg": "cycle_clockwise(option + r)",
    },
    {
      "title": "Cycle Counterclockwise",
      "subtitle":"逆时针循环调整窗口",
      "arg": "cycle_counterclockwise",
    },
    {
      "title": "Swap to Last Window",
      "subtitle":"将当前窗口与最后一个窗口交换",
      "arg": "swap_to_last_win",
    }
  ]
}
EOB
}

# 函数：发送系统通知
send_notification() {
  local message="$1"
  osascript -e "display notification \"$message\" with title \"Yabai 布局已更改\""
}

# 在 float 和 bsp 布局之间切换
toggle_layout() {
  # 获取当前 space 的布局
  current_layout=$(yabai -m query --spaces --space | jq -r '.type')

  # 切换布局
  if [ "$current_layout" = "bsp" ]; then
    yabai -m space --layout float
    send_notification "已切换到 float 布局"
  else
    yabai -m space --layout bsp
    send_notification "已切换到 bsp 布局"
  fi
}

# 顺时针循环调整窗口
cycle_clockwise() {
  win=$(yabai -m query --windows --window last | jq '.id')
  while :; do
    yabai -m window $win --swap prev &>/dev/null
    if [[ $? -eq 1 ]]; then
      break
    fi
  done
}

# 逆时针循环调整窗口
cycle_counterclockwise() {
  win=$(yabai -m query --windows --window first | jq '.id')
  while :; do
    yabai -m window $win --swap next &>/dev/null
    if [[ $? -eq 1 ]]; then
      break
    fi
  done
}

swap_to_last_win() {
  yabai -m window --swap last
}

action="$1"
case "$action" in
"get_yabai_action")
  get_yabai_action
  ;;
"toggle_layout")
  toggle_layout
  ;;
"cycle_clockwise")
  cycle_clockwise
  ;;
"cycle_counterclockwise")
  cycle_counterclockwise
  ;;
"swap_to_last_win")
  swap_to_last_win
  ;;
*)
  send_notification "Unknown action: $action"
  ;;
esac
