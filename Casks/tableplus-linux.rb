cask "tableplus-linux" do
  version "0.1.306"
  sha256 "c58ed0766e6999c5a8169221d910bf56bef4ff59cee1a87bb90c671adc479a07"

  url "https://deb.tableplus.com/debian/22/pool/main/t/tableplus/tableplus_#{version}_amd64.deb",
      verified: "deb.tableplus.com/"
  name "TablePlus"
  desc "Modern, native database GUI client supporting multiple databases"
  homepage "https://tableplus.com/"

  livecheck do
    url "https://deb.tableplus.com/debian/22/pool/main/t/tableplus/"
    regex(/tableplus_([0-9.]+)_amd64\.deb/i)
  end

  depends_on formula: "dpkg"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/256x256/apps"

    # Extract the deb package
    deb_file = "#{staged_path}/tableplus_#{version}_amd64.deb"
    system "dpkg", "-x", deb_file, staged_path
    FileUtils.rm_f deb_file
  end

  binary "usr/bin/tableplus", target: "tableplus"

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")

    icon_source = Dir.glob("#{staged_path}/usr/share/icons/**/*.png").sort_by { |f| -File.size(f) }.first
    icon_target = "#{xdg_data}/icons/hicolor/256x256/apps/tableplus.png"
    FileUtils.cp(icon_source, icon_target) if icon_source && File.exist?(icon_source)

    desktop_source = Dir.glob("#{staged_path}/usr/share/applications/*.desktop").first
    if desktop_source && File.exist?(desktop_source)
      desktop_content = File.read(desktop_source)
      desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/tableplus %U")
      desktop_content.gsub!(/^Icon=.*/, "Icon=#{icon_target}")
      File.write("#{xdg_data}/applications/tableplus.desktop", desktop_content)
    else
      File.write("#{xdg_data}/applications/tableplus.desktop", <<~EOS)
        [Desktop Entry]
        Name=TablePlus
        Comment=Modern, native database GUI client
        GenericName=Database GUI
        Exec=#{HOMEBREW_PREFIX}/bin/tableplus %U
        Icon=#{icon_target}
        Type=Application
        StartupNotify=true
        StartupWMClass=TablePlus
        Categories=Development;Database;
        MimeType=x-scheme-handler/tableplus;
        Keywords=database;sql;mysql;postgresql;sqlite;redis;
      EOS
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/tableplus.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/256x256/apps/tableplus.png"
  end

  zap trash: [
    "~/.config/TablePlus",
    "~/.local/share/tableplus",
  ]
end
