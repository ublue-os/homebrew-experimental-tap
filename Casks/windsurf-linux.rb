cask "windsurf-linux" do
  version "3.4.27,0d4bf12ed4a7597cb8ae9016fe8474468aad98a2"
  sha256 "80850124b31331f63c24a201d1317bdacdfb438fb2bcc9b31c9b7a6391391619"

  url "https://windsurf-stable.codeiumdata.com/linux-x64/stable/#{version.csv.second}/Devin-linux-x64-#{version.csv.first}.tar.gz"
  name "Windsurf (Devin)"
  desc "AI-powered IDE from Codeium/Cognition, formerly Windsurf Editor"
  homepage "https://windsurf.com/"

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
