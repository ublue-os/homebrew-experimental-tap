cask "proton-mail-bridge-linux" do
  version "3.25.0"
  sha256 "6b0318f4f425ef1a19b63e2bd589bc1036d95f073cb9ac26b42c0fc63a8bc275"

  url "https://github.com/ProtonMail/proton-bridge/releases/download/v#{version}/protonmail-bridge_#{version}-1_amd64.deb",
      verified: "github.com/ProtonMail/proton-bridge/"
  name "Proton Mail Bridge"
  desc "Integrate Proton Mail with email clients via local IMAP/SMTP"
  homepage "https://proton.me/mail/bridge"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "dpkg"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/256x256/apps"

    # Extract the deb package
    deb_file = "#{staged_path}/protonmail-bridge_#{version}-1_amd64.deb"
    system "dpkg", "-x", deb_file, staged_path
    FileUtils.rm_f deb_file
  end

  binary "usr/bin/proton-bridge", target: "proton-mail-bridge"

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")

    icon_source = Dir.glob("#{staged_path}/usr/share/icons/**/*.png").sort_by { |f| -File.size(f) }.first
    icon_target = "#{xdg_data}/icons/hicolor/256x256/apps/proton-mail-bridge.png"
    FileUtils.cp(icon_source, icon_target) if icon_source && File.exist?(icon_source)

    desktop_source = Dir.glob("#{staged_path}/usr/share/applications/*.desktop").first
    if desktop_source && File.exist?(desktop_source)
      desktop_content = File.read(desktop_source)
      desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/proton-mail-bridge %U")
      desktop_content.gsub!(/^Icon=.*/, "Icon=#{icon_target}")
      File.write("#{xdg_data}/applications/proton-mail-bridge.desktop", desktop_content)
    else
      File.write("#{xdg_data}/applications/proton-mail-bridge.desktop", <<~EOS)
        [Desktop Entry]
        Name=Proton Mail Bridge
        Comment=Integrate Proton Mail with email clients via local IMAP/SMTP
        GenericName=Mail Bridge
        Exec=#{HOMEBREW_PREFIX}/bin/proton-mail-bridge %U
        Icon=#{icon_target}
        Type=Application
        StartupNotify=true
        StartupWMClass=proton-bridge
        Categories=Network;Email;
        Keywords=proton;mail;bridge;email;imap;smtp;
      EOS
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/proton-mail-bridge.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/256x256/apps/proton-mail-bridge.png"
  end

  zap trash: [
    "~/.config/protonmail/bridge-v3",
    "~/.local/share/protonmail/bridge-v3",
    "~/.cache/protonmail/bridge-v3",
  ]
end
