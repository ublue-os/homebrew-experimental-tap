cask "proton-mail-bridge-linux" do
  version "3.26.0"
  sha256 "c076872522ce2f0facd0e64764d7d588b3a1ed213ff3acd25386b51e8a1f02e8"

  url "https://github.com/ProtonMail/proton-bridge/releases/download/v#{version}/protonmail-bridge_#{version}-1_amd64.deb"
  name "Proton Mail Bridge"
  desc "Integrate Proton Mail with email clients via local IMAP/SMTP"
  homepage "https://proton.me/mail/bridge"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "dpkg"

  binary "usr/bin/proton-bridge", target: "proton-mail-bridge"

  preflight_steps do
    # Normalise the versioned deb filename, then extract.
    move "protonmail-bridge_*-1_amd64.deb", "proton-mail-bridge.deb", source_glob: true
    run "{{HOMEBREW_PREFIX}}/opt/dpkg/bin/dpkg-deb",
        args: ["-x", "{{staged_path}}/proton-mail-bridge.deb", "{{staged_path}}"]
    remove "proton-mail-bridge.deb"
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/256x256/apps", base: :home

    # Select the largest icon and the first desktop file within staged_path first,
    # mirroring the original `Dir.glob(...).min_by { -File.size }` / `.first` picks.
    run "sh", args: ["-eu", "-c", <<~'SH']
      staged="{{staged_path}}"
      tab=$(printf '\t')
      icon_src=$(find "$staged/usr/share/icons" -type f -name '*.png' -printf '%s\t%p\0' 2>/dev/null |
        LC_ALL=C sort -z -t "$tab" -k1,1nr -k2,2 | head -z -n 1 | cut -z -f2-)
      if [ -n "$icon_src" ] && [ -f "$icon_src" ]; then
        cp "$icon_src" "$staged/proton-mail-bridge.icon.png"
      fi
      desktop_src=$(ls "$staged"/usr/share/applications/*.desktop 2>/dev/null | head -1)
      if [ -n "$desktop_src" ] && [ -f "$desktop_src" ]; then
        cp "$desktop_src" "$staged/proton-mail-bridge.desktop"
      fi
    SH

    if_path_exists "proton-mail-bridge.icon.png" do
      copy "proton-mail-bridge.icon.png",
           ".local/share/icons/hicolor/256x256/apps/proton-mail-bridge.png", target_base: :home
    end

    if_path_exists "proton-mail-bridge.desktop" do
      copy "proton-mail-bridge.desktop", ".local/share/applications/proton-mail-bridge.desktop",
           target_base: :home
      inreplace ".local/share/applications/proton-mail-bridge.desktop", /^Exec=.*/,
                "Exec={{HOMEBREW_PREFIX}}/bin/proton-mail-bridge %U", base: :home, audit_result: false
      inreplace ".local/share/applications/proton-mail-bridge.desktop", /^Icon=.*/,
                "Icon=proton-mail-bridge", base: :home, audit_result: false
    end
    unless_path_exists "proton-mail-bridge.desktop" do
      write_file ".local/share/applications/proton-mail-bridge.desktop", <<~EOS, base: :home
        [Desktop Entry]
        Name=Proton Mail Bridge
        Comment=Integrate Proton Mail with email clients via local IMAP/SMTP
        GenericName=Mail Bridge
        Exec={{HOMEBREW_PREFIX}}/bin/proton-mail-bridge %U
        Icon=proton-mail-bridge
        Type=Application
        StartupNotify=true
        StartupWMClass=proton-bridge
        Categories=Network;Email;
        Keywords=proton;mail;bridge;email;imap;smtp;
      EOS
    end
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/proton-mail-bridge.desktop", base: :home
    remove ".local/share/icons/hicolor/256x256/apps/proton-mail-bridge.png", base: :home
  end

  zap trash: [
    "~/.cache/protonmail/bridge-v3",
    "~/.config/protonmail/bridge-v3",
    "~/.local/share/protonmail/bridge-v3",
  ]
end
