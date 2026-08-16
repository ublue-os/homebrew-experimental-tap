cask "positron-linux" do
  arch arm: "arm64", intel: "x64"

  version "2026.08.1-2"
  sha256 arm64_linux:  "78ccb9b8f25f6a0c99fd233367f6675c24001bf54347d5ad694423020976d7ca",
         x86_64_linux: "e307d3710b054de4236b62591702419887d73bdb65e8253f279fc7663d3ced89"

  url "https://cdn.posit.co/positron/releases/deb/#{(arch == "arm64") ? "arm64" : "x86_64"}/Positron-#{version}-#{arch}.deb",
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

  depends_on linux: :any
  depends_on formula: "dpkg"

  binary "usr/bin/positron", target: "positron"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/256x256/apps"

    # Extract the deb package
    deb_file = "#{staged_path}/Positron-#{version}-#{arch}.deb"
    system "dpkg", "-x", deb_file, staged_path
    FileUtils.rm(deb_file, force: true)
  end

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
    FileUtils.rm("#{xdg_data}/applications/positron.desktop", force: true)
    FileUtils.rm("#{xdg_data}/icons/hicolor/256x256/apps/positron.png", force: true)
  end

  zap trash: [
    "~/.config/Positron",
    "~/.local/share/positron",
  ]
end
