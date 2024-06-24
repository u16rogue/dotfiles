#!/bin/bash

export CPM_SOURCE_CACHE=~/.cmakepackman

export TERM=alacritty
export EDITOR=vim

export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORM=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export QT_SCREEN_SCALE_FACTORS="1;1"
export MOZ_ENABLE_WAYLAND=1

exec sway
