cask "positron-linux" do
  arch arm: "arm64", intel: "x64"

  version "2026.07.1-5"
  sha256 on_arch_conditional intel: "432e22d31e65250e0a1eacf0cf34d58e115fd6f9e70516b52fddabf6791b9800",
                             arm:   :no_check

  url "https://cdn.posit.co/positron/releases/deb/#{arch == "arm64" ? "arm64" : "x86_64"}/Positron-#{version}-#{arch}.deb",
      verified: "cdn.posit.co/positron/"
  name "Positron"
  desc "Next-generation data science IDE for R and Python"
  homepage "https://positron.posit.co/"

  livecheck do
    url "https://api.github.com/repos/posit-dev/positron/releases/latest"
    regex(/"tag_name":\s*"([^"]+)"/i)
    strategy :json do |json|
      json["tag_name"]
    end
  end

  depends_on formula: "dpkg"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/256x256/apps"

    # Extract the deb package
    deb_file = "#{staged_path}/Positron-#{version}-#{arch}.deb"
    system "dpkg", "-x", deb_file, staged_path
    FileUtils.rm_f deb_file
  end

  binary "usr/bin/positron", target: "positron"

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")

    icon_source = "#{staged_path}/usr/share/icons/hicolor/256x256/apps/positron.png"
    icon_target = "#{xdg_data}/icons/hicolor/256x256/apps/positron.png"
    FileUtils.cp(icon_source, icon_target) if File.exist?(icon_source)

    desktop_source = "#{staged_path}/usr/share/applications/positron.desktop"
    if File.exist?(desktop_source)
      desktop_content = File.read(desktop_source)
      desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/positron %F")
      desktop_content.gsub!(/^Icon=.*/, "Icon=#{icon_target}")
      File.write("#{xdg_data}/applications/positron.desktop", desktop_content)
    else
      File.write("#{xdg_data}/applications/positron.desktop", <<~EOS)
        [Desktop Entry]
        Name=Positron
        Comment=Next-generation data science IDE for R and Python
        GenericName=Data Science IDE
        Exec=#{HOMEBREW_PREFIX}/bin/positron %F
        Icon=#{icon_target}
        Type=Application
        StartupNotify=true
        StartupWMClass=Positron
        Categories=Development;IDE;Science;
        MimeType=text/plain;inode/directory;
        Keywords=r;python;data;science;statistics;
      EOS
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/positron.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/256x256/apps/positron.png"
  end

  zap trash: [
    "~/.config/Positron",
    "~/.local/share/positron",
  ]
end
