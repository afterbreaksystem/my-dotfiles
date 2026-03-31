#!/bin/bash

# Функция получения громкости для PipeWire
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | \
    awk '{
        vol = $2 * 100;
        if (vol < 1) vol = 0;
        printf "%d", vol
    }'
}

# Функция получения статуса mute
get_mute() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | \
    grep -q "MUTED" && echo "true" || echo "false"
}

# Функция получения иконки
get_icon() {
    local mute=$1
    local vol=$2
    
    if [ "$mute" = "true" ] || [ "$vol" -eq 0 ]; then
        echo "󰖁"
    elif [ "$vol" -lt 30 ]; then
        echo "󰕿"
    elif [ "$vol" -lt 70 ]; then
        echo "󰖀"
    else
        echo "󰕾"
    fi
}

# Инициализация
vol=$(get_volume)
mute=$(get_mute)
icon=$(get_icon "$mute" "$vol")

# Обновляем eww переменные
/usr/bin/eww update volico="$icon"
/usr/bin/eww update get_vol="$vol"

# Слушаем события изменения (аналог pactl subscribe для PipeWire)
while read -r event; do
    # Фильтруем события изменения громкости
    if echo "$event" | grep -q "volume-changed\|mute-changed"; then
        vol=$(get_volume)
        mute=$(get_mute)
        icon=$(get_icon "$mute" "$vol")
        
        /usr/bin/eww update volico="$icon"
        /usr/bin/eww update get_vol="$vol"
    fi
done < <(wpctl --subscribe 2>/dev/null)
