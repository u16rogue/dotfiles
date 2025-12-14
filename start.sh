#!/bin/sh

#source .setup_private_env.sh

export CPM_SOURCE_CACHE=$(realpath ".cache/cmake-cpm")
export IDF_TOOLS_PATH=$(realpath "Packages/esp-idf/.espressif")

export TERM=alacritty
export EDITOR=vim

export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORM=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export QT_SCREEN_SCALE_FACTORS="1;1"
export MOZ_ENABLE_WAYLAND=1

export PATH="$PATH:$(realpath "Scripts"):$(realpath ".zig"):$(realpath ".cargo/bin"):$(realpath ".luarocks/bin")"

exec sway
