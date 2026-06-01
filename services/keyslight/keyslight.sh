#!/bin/bash

PATH=/opt/someApp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

rogauracore initialize_keyboard
rogauracore brightness 3
rogauracore single_static 00ff00
notify-send "Keyboard lights are ON"
