cask "localwp-linux" do
  version "9.2.0"
  sha256 "f880e0a80c4fde8a11965177c81b193240836c5c258f32f15f6c68ca65e3c29e"

  url "https://cdn.localwp.com/releases/#{version}/linux/local-#{version}-linux-x64.tar.gz",
      verified: "cdn.localwp.com/releases/"
  name "LocalWP"
  desc "Local WordPress development environment"
  homepage "https://localwp.com/"

  auto_updates true

  binary "Local", target: "localwp"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/512x512/apps"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")

    # Find icon in extracted archive
    icon_source = Dir.glob("#{staged_path}/**/local.png").first ||
                  Dir.glob("#{staged_path}/**/*.png").first
    icon_target = "#{xdg_data}/icons/hicolor/512x512/apps/localwp.png"
    FileUtils.cp(icon_source, icon_target) if icon_source && File.exist?(icon_source)

    File.write("#{xdg_data}/applications/localwp.desktop", <<~EOS)
      [Desktop Entry]
      Name=LocalWP
      Comment=Local WordPress development environment
      GenericName=WordPress Development Tool
      Exec=#{HOMEBREW_PREFIX}/bin/localwp %U
      Icon=#{icon_target}
      Type=Application
      StartupNotify=true
      StartupWMClass=Local
      Categories=Development;WebDevelopment;
      MimeType=x-scheme-handler/local-site;
      Keywords=wordpress;local;development;web;
    EOS
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/localwp.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/512x512/apps/localwp.png"
  end

  zap trash: [
    "~/.config/Local",
    "~/.local/share/Local",
    "~/Local Sites",
  ]
end
