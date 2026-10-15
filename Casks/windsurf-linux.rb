cask "windsurf-linux" do
  os linux: "linux"

  version "3.10.67,0b186d6e13a1a48a46430c51fe414dd0747d46f6"
  sha256 "3295f8bdfb460180a7e96961c0a6156f108b6502684287f17b8b512246c35803"

  url "https://windsurf-stable.codeiumdata.com/linux-x64/stable/#{version.csv.second}/Devin-linux-x64-#{version.csv.first}.tar.gz"
  name "Windsurf (Devin)"
  desc "AI-powered IDE from Codeium/Cognition, formerly Windsurf Editor"
  homepage "https://cognition.com/"

  livecheck do
    url "https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"
    strategy :json do |json|
      "#{json["windsurfVersion"]},#{json["version"]}"
    end
  end

  binary "windsurf/windsurf", target: "windsurf"

  preflight_steps do
    # Normalise the versioned app directory before referring to it below.
    move "Devin-linux-x64-*", "windsurf", source_glob: true
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home
  end

  postflight_steps do
    # Select the largest icon within the app dir, mirroring the original
    # `Dir.glob(...).min_by { -File.size }` pick.
    run "sh", args: ["-eu", "-c", <<~'SH']
      staged="{{staged_path}}"
      tab=$(printf '\t')
      icon_src=$(find "$staged/windsurf" -type f -name '*.png' -printf '%s\t%p\0' 2>/dev/null |
        LC_ALL=C sort -z -t "$tab" -k1,1nr -k2,2 | head -z -n 1 | cut -z -f2-)
      if [ -n "$icon_src" ] && [ -f "$icon_src" ]; then
        cp "$icon_src" "$staged/windsurf.icon.png"
      fi
    SH

    if_path_exists "windsurf.icon.png" do
      copy "windsurf.icon.png", ".local/share/icons/hicolor/512x512/apps/windsurf.png", target_base: :home
    end

    write_file ".local/share/applications/windsurf.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=Windsurf
      Comment=AI-powered IDE from Codeium/Cognition
      GenericName=Text Editor
      Exec={{HOMEBREW_PREFIX}}/bin/windsurf %F
      Icon=windsurf
      Type=Application
      StartupNotify=false
      StartupWMClass=Windsurf
      Categories=TextEditor;Development;IDE;
      MimeType=text/plain;inode/directory;application/x-code-workspace;
      Actions=new-empty-window;
      Keywords=windsurf;code;editor;ai;

      [Desktop Action new-empty-window]
      Name=New Empty Window
      Exec={{HOMEBREW_PREFIX}}/bin/windsurf --new-window %F
      Icon=windsurf
    EOS
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/windsurf.desktop", base: :home
    remove ".local/share/icons/hicolor/512x512/apps/windsurf.png", base: :home
  end

  zap trash: [
    "~/.config/Windsurf",
    "~/.config/windsurf",
    "~/.local/share/Windsurf",
  ]
end
