#!/bin/zsh

# --- 配置区 ---
WALLPAPERS_DIR="$HOME/.config/hypr/files/pictures/wallpapers/scenes"  # 默认壁纸目录
ROFI_LAUNCHER_DIR="$HOME/.config/rofi/launchers/type-6"        # Rofi启动器目录
ROFI_THEME="style-6"                                           # Rofi主题

# swww切换配置
TRANSITION_TYPE="random"                # 过渡效果 (fade/grow/wipe/outer/random)
TRANSITION_DURATION=2                 # 过渡时长(秒)
TRANSITION_FPS=60                     # 过渡帧率
RESIZE_MODE="crop"                    # 图像适配模式 (crop/fit/no)

# --- 函数定义 ---

# 获取壁纸列表
get_wallpapers() {
  local -a files
  files=($WALLPAPERS_DIR/*.(jpg|jpeg|png|webp)(N))
  if (( ${#files} == 0 )); then
    notify-send --urgency=critical "壁纸切换" "未找到壁纸文件 in $WALLPAPERS_DIR"
    exit 1
  fi
  print -l $files
}

# 手动选择壁纸 (使用 rofi)
manual_select() {
  local wallpapers=($(get_wallpapers))
  local chosen=$(printf "%s\n" ${wallpapers##*/} | rofi -dmenu -p "选择壁纸" -theme "${ROFI_LAUNCHER_DIR}/${ROFI_THEME}.rasi")
  [[ -n "$chosen" ]] && echo "$WALLPAPERS_DIR/$chosen"
}

# 随机选择壁纸
random_select() {
  local wallpapers=($(get_wallpapers))
  print -n $wallpapers[$((RANDOM % $#wallpapers + 1))]
}

# 执行壁纸切换
change_wallpaper() {
  local wallpaper=$1
  swww img "$wallpaper" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps "$TRANSITION_FPS" \
    --resize "$RESIZE_MODE"
  notify-send "壁纸切换" "已设置为: ${wallpaper:t}"
}

# 启动Rofi应用启动器
launch_apps() {
  rofi -show drun -theme "${ROFI_LAUNCHER_DIR}/${ROFI_THEME}.rasi"
}

# 显示主菜单
show_main_menu() {
  local options=(
    "1. 更换壁纸"
    "2. 随机壁纸"
    "3. 启动应用"
    "4. 退出"
  )
  
  local choice=$(printf "%s\n" "${options[@]}" | rofi -dmenu -p "主菜单" -theme "${ROFI_LAUNCHER_DIR}/${ROFI_THEME}.rasi")
  
  case "$choice" in
    "1. 更换壁纸")
      wallpaper=$(manual_select)
      [[ -n "$wallpaper" ]] && change_wallpaper "$wallpaper"
      ;;
    "2. 随机壁纸")
      change_wallpaper $(random_select)
      ;;
    "3. 启动应用")
      launch_apps
      ;;
    "4. 退出")
      exit 0
      ;;
    *)
      # 默认返回主菜单
      show_main_menu
      ;;
  esac
}

# --- 主逻辑 ---
case "$1" in
  (--manual|-m)
    wallpaper=$(manual_select)
    [[ -n "$wallpaper" ]] && change_wallpaper "$wallpaper"
    ;;
  (--random|-r)
    change_wallpaper $(random_select)
    ;;
  (--menu)
    show_main_menu
    ;;
  (--apps|--launch)
    launch_apps
    ;;
  (*)
    echo "用法: $0 [--manual|-m|--random|-r|--menu|--apps]"
    exit 1
    ;;
esac
