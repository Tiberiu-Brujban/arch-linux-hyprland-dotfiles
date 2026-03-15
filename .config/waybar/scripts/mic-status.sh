#!/bin/bash

STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if [[ $STATUS == *"MUTED"* ]]; then
    echo '{"text":" ","class":"muted"}'
else
    echo '{"text":"  ","class":"active"}'
fi
