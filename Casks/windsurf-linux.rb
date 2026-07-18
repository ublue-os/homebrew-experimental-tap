cask "windsurf-linux" do
  version "3.4.27,0d4bf12ed4a7597cb8ae9016fe8474468aad98a2"
  sha256 "80850124b31331f63c24a201d1317bdacdfb438fb2bcc9b31c9b7a6391391619"

  url "https://windsurf-stable.codeiumdata.com/linux-x64/stable/#{version.csv.second}/Devin-linux-x64-#{version.csv.first}.tar.gz",
      verified: "windsurf-stable.codeiumdata.com/"
  name "Windsurf (Devin)"
  desc "AI-powered IDE from Codeium/Cognition, formerly Windsurf Editor"
  homepage "https://windsurf.com/"

  livecheck do
    url "https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"
    strategy :json do |json|
      "#{json["windsurfVersion"]},#{json["version"]}"
    end
  end

  binary "Devin-linux-x64-#{version.csv.first}/windsurf", target: "windsurf"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/512x512/apps"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    app_dir = "#{staged_path}/Devin-linux-x64-#{version.csv.first}"

    icon_source = Dir.glob("#{app_dir}/**/*.png").sort_by { |f| -File.size(f) }.first
    icon_target = "#{xdg_data}/icons/hicolor/512x512/apps/windsurf.png"
    FileUtils.cp(icon_source, icon_target) if icon_source && File.exist?(icon_source)

    File.write("#{xdg_data}/applications/windsurf.desktop", <<~EOS)
      [Desktop Entry]
      Name=Windsurf
      Comment=AI-powered IDE from Codeium/Cognition
      GenericName=Text Editor
      Exec=#{HOMEBREW_PREFIX}/bin/windsurf %F
      Icon=#{icon_target}
      Type=Application
      StartupNotify=false
      StartupWMClass=Windsurf
      Categories=TextEditor;Development;IDE;
      MimeType=text/plain;inode/directory;application/x-code-workspace;
      Actions=new-empty-window;
      Keywords=windsurf;code;editor;ai;

      [Desktop Action new-empty-window]
      Name=New Empty Window
      Exec=#{HOMEBREW_PREFIX}/bin/windsurf --new-window %F
      Icon=#{icon_target}
    EOS
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/windsurf.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/512x512/apps/windsurf.png"
  end

  zap trash: [
    "~/.config/Windsurf",
    "~/.config/windsurf",
    "~/.local/share/Windsurf",
  ]
end
