#!/usr/bin/env

# terminate all running instances of the polybar
killall -q polybar

# wait until all processes have stopped
while pgrep -x polybar > /dev/null; do sleep 1; done

# launch the bar named
polybar i3-poly-bar &

# alert status
echo "polybar has started"
