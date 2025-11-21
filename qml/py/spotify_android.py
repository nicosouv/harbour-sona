#!/usr/bin/env python3
import subprocess
import pyotherside

def check_installed():
    """Check if Spotify Android app is installed"""
    try:
        result = subprocess.run(
            ["apkd-launcher", "--list-packages"],
            capture_output=True,
            text=True,
            timeout=5
        )
        return "com.spotify.music" in result.stdout
    except Exception as e:
        print(f"Error checking installation: {e}")
        return False

def check_running():
    """Check if Spotify Android app is running"""
    try:
        result = subprocess.run(
            ["pgrep", "-f", "com.spotify.music"],
            capture_output=True,
            timeout=5
        )
        return result.returncode == 0
    except Exception as e:
        print(f"Error checking if running: {e}")
        return False

def launch():
    """Launch Spotify Android app"""
    try:
        subprocess.Popen(
            ["apkd-launcher", "--start", "com.spotify.music"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return True
    except Exception as e:
        print(f"Error launching: {e}")
        return False
