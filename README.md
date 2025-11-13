# Sona - Spotify Client for Sailfish OS

A native Spotify client for Sailfish OS that allows you to browse and control your Spotify playback.

## Features

- ✅ OAuth2 authentication with Spotify (PKCE flow)
- ✅ Browse your playlists
- ✅ View playlist details and tracks
- ✅ Search for tracks, artists, albums, and playlists
- ✅ Now Playing view with playback controls
- ✅ Control playback via Spotify Connect (play, pause, next, previous)
- ✅ Shuffle and repeat controls

## Prerequisites

- Sailfish SDK installed
- Spotify Developer account with an app created
- Client ID and Client Secret from Spotify

## Setup

### 1. Spotify App Configuration

1. Create a Spotify app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Configure the Redirect URI: `harbour-sona://callback`
3. Select **Web API** only (not iOS, Android, or other SDKs)
4. Note your Client ID and Client Secret

### 2. Local Development Setup

1. Copy the config template:
   ```bash
   cp qml/config.js.example qml/config.js
   ```

2. Edit `qml/config.js` and add your credentials:
   ```javascript
   var SPOTIFY_CLIENT_ID = "YOUR_CLIENT_ID"
   var SPOTIFY_CLIENT_SECRET = "YOUR_CLIENT_SECRET"
   ```

**Important:** Never commit `qml/config.js` to git. It's already in `.gitignore`.

### 3. GitHub Actions Setup (Optional)

If you're using GitHub Actions for builds, add these secrets to your repository:

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add two secrets:
   - `SPOTIFY_CLIENT_ID`: Your Spotify Client ID
   - `SPOTIFY_CLIENT_SECRET`: Your Spotify Client Secret

The workflow will automatically inject these during build.

## Building

### Using Sailfish SDK

1. Open the project in Qt Creator (from Sailfish SDK)
2. Select your Sailfish OS target
3. Build and deploy to device or emulator

### Using command line

```bash
mb2 -t SailfishOS-latest-armv7hl build
```

## Project Structure

```
harbour-sona/
├── src/
│   └── harbour-sona.cpp          # C++ entry point
├── qml/
│   ├── harbour-sona.qml          # Main application window
│   ├── pages/
│   │   ├── MainPage.qml          # Main page with OAuth2
│   │   └── AboutPage.qml         # About page
│   └── cover/
│       └── CoverPage.qml         # App cover
├── rpm/
│   ├── harbour-sona.spec         # RPM spec file
│   ├── harbour-sona.yaml         # Package configuration
│   └── harbour-sona.changes      # Changelog
├── harbour-sona.pro              # Qt project file
└── harbour-sona.desktop          # Desktop entry file
```

## Dependencies

- sailfishapp >= 1.0.2
- sailfishsilica-qt5 >= 0.10.9
- amber-web-authorization (for OAuth2)

## Spotify API

This app uses the **Spotify Web API** which provides:
- User authentication via OAuth2
- Playlist and library management
- Playback control (requires Spotify Premium)
- Search functionality

## Limitations

- Direct audio streaming requires the Web Playback SDK which is not available for native apps
- The app can control playback on other Spotify Connect devices
- Playback control requires a Spotify Premium account

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
