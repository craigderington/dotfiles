#!/bin/bash
#
#   _   _                                              
#  | | | |_   _ _ __  _ __ _ __   __ _ _ __   ___ _ __ 
#  | |_| | | | | '_ \| '__| '_ \ / _` | '_ \ / _ \ '__|
#  |  _  | |_| | |_) | |  | |_) | (_| | |_) |  __/ |   
#  |_| |_|\__, | .__/|_|  | .__/ \__,_| .__/ \___|_|   
#         |___/|_|        |_|         |_|              
#
#
WALLPAPER_DIRECTORY="/home/craigderington/.config/backgrounds/"
WALLPAPER=$(find $WALLPAPER_DIRECTORY -type f | shuf -n 1)

#echo $WALLPAPER_DIRECTORY
#echo $WALLPAPER

hyprctl hyprpaper preload $WALLPAPER
hyprctl hyprpaper wallpaper "desc:Samsung Electric Company C34J79x HNTTC01019,$WALLPAPER"

sleep 0.10

hyprctl hyprpaper unload unused
