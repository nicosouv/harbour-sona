Name:       harbour-sona
Summary:    Spotify client for Sailfish OS
Version:    0.1.0
Release:    1
Group:      Applications/Multimedia
License:    MIT
URL:        https://github.com/yourusername/harbour-sona
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   amber-web-authorization
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(amberwebauthorization)

%description
Sona is a Spotify client for Sailfish OS that allows you to browse and control your Spotify playback.

Features:
- OAuth2 authentication
- Browse playlists and library
- Control playback via Spotify Connect
- Search for music


%prep
%setup -q -n %{name}-%{version}

%build
%qtc_qmake5

%qtc_make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
