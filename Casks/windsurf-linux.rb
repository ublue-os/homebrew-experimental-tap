cask "windsurf-linux" do
  os linux: "linux"

  version "3.15.14,cfa79668e1a5e000e036cea74fc23449b0aedec3-c16c32bf7d9d42345cd0c798c527a68e"
  sha256 "6cd616eae9890237d2b77d0d410fc6f83151eacce0c862bfb707e2c5d9eac703"

  url "https://windsurf-stable.codeiumdata.com/linux-x64/stable/#{version.csv.second}/Devin-linux-x64-#{version.csv.first}.tar.gz"
  name "Windsurf (Devin)"
  desc "AI-powered IDE from Codeium/Cognition, formerly Windsurf Editor"
  homepage "https://cognition.com/"

  livecheck do
    url "https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"
    strategy :json do |json|
      # The download directory is the commit hash plus a build suffix, so take it from the URL.
      dir = json["url"]&.[](%r{/stable/([^/]+)/[^/]+$}, 1)
      next if dir.blank? || json["windsurfVersion"].blank?

      "#{json["windsurfVersion"]},#{dir}"
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
