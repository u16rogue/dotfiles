adb tcpip 5555
adb connect 192.168.1.123:5555
exec scrcpy -e &
disown
