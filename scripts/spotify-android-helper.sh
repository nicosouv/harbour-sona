#!/bin/bash

case "$1" in
    check-installed)
        if apkd-launcher --list-packages 2>/dev/null | grep -q "com.spotify.music"; then
            echo "installed"
        else
            echo "not_installed"
        fi
        ;;
    check-running)
        if pgrep -f "com.spotify.music" > /dev/null 2>&1; then
            echo "running"
        else
            echo "not_running"
        fi
        ;;
    launch)
        apkd-launcher --start com.spotify.music 2>/dev/null
        echo "launched"
        ;;
    *)
        echo "Usage: $0 {check-installed|check-running|launch}"
        exit 1
        ;;
esac
