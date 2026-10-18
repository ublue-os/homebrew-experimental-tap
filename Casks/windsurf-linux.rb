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

  binary "windsurf/bin/devin-desktop", target: "windsurf"
  binary "windsurf/bin/devin-desktop", target: "devin"

  preflight_steps do
    # Normalise the versioned app directory before referring to it below.
    move "Devin*", "windsurf", source_glob: true
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home
  end

  postflight_steps do
    run "sh", args: ["-eu", "-c", <<~'SH']
      staged="{{staged_path}}"
      if [ -f "$staged/windsurf/resources/app/resources/linux/code.png" ]; then
        cp "$staged/windsurf/resources/app/resources/linux/code.png" "$staged/windsurf.icon.png"
      else
        tab=$(printf '\t')
        icon_src=$(find "$staged/windsurf" -type f -name '*.png' -printf '%s\t%p\n' 2>/dev/null |
          LC_ALL=C sort -t "$tab" -k1,1nr -k2,2 | head -n 1 | cut -f2-)
        if [ -n "$icon_src" ] && [ -f "$icon_src" ]; then
          cp "$icon_src" "$staged/windsurf.icon.png"
        fi
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
      StartupWMClass=devin-desktop
      Categories=TextEditor;Development;IDE;
      MimeType=text/plain;inode/directory;application/x-code-workspace;
      Actions=new-empty-window;
      Keywords=windsurf;devin;code;editor;ai;

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
    "~/.config/Devin",
    "~/.config/Windsurf",
    "~/.config/windsurf",
    "~/.devin",
    "~/.local/share/Devin",
    "~/.local/share/Windsurf",
  ]
end
