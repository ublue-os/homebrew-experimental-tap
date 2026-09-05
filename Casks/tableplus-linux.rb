cask "tableplus-linux" do
  version "0.1.308"
  sha256 "b2a880fa2099aea1cf224876e097a3b5f06f20bb59b771cdd9b29fff549cef5e"

  url "https://deb.tableplus.com/debian/22/pool/main/t/tableplus/tableplus_#{version}_amd64.deb"
  name "TablePlus"
  desc "Modern, native database GUI client supporting multiple databases"
  homepage "https://tableplus.com/"

  livecheck do
    url "https://deb.tableplus.com/debian/22/pool/main/t/tableplus/"
    regex(/tableplus_([0-9.]+)_amd64\.deb/i)
  end

  depends_on linux: :any
  depends_on arch: :x86_64
  depends_on formula: "dpkg"
  # the preflight below extracts the deb itself; without :naked, brew's
  # container sniffing trips over the zstd-compressed members of newer debs
  container type: :naked

  binary "usr/bin/tableplus", target: "tableplus"

  preflight_steps do
    # Normalise the versioned deb filename, then extract.
    move "tableplus_*_amd64.deb", "tableplus.deb", source_glob: true
    run "{{HOMEBREW_PREFIX}}/opt/dpkg/bin/dpkg-deb",
        args: ["-x", "{{staged_path}}/tableplus.deb", "{{staged_path}}"]
    remove "tableplus.deb"
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/256x256/apps", base: :home

    # Select the largest icon and the first desktop file within staged_path first,
    # mirroring the original `Dir.glob(...).min_by { -File.size }` / `.first` picks.
    run "sh", args: ["-eu", "-c", <<~'SH']
      staged="{{staged_path}}"
      tab=$(printf '\t')
      icon_src=$(find "$staged/usr/share/icons" -type f -name '*.png' -printf '%s\t%p\0' 2>/dev/null |
        LC_ALL=C sort -z -t "$tab" -k1,1nr -k2,2 | head -z -n 1 | cut -z -f2-)
      if [ -n "$icon_src" ] && [ -f "$icon_src" ]; then
        cp "$icon_src" "$staged/tableplus.icon.png"
      fi
      desktop_src=$(ls "$staged"/usr/share/applications/*.desktop 2>/dev/null | head -1)
      if [ -n "$desktop_src" ] && [ -f "$desktop_src" ]; then
        cp "$desktop_src" "$staged/tableplus.desktop"
      fi
    SH

    if_path_exists "tableplus.icon.png" do
      copy "tableplus.icon.png", ".local/share/icons/hicolor/256x256/apps/tableplus.png",
           target_base: :home
    end

    if_path_exists "tableplus.desktop" do
      copy "tableplus.desktop", ".local/share/applications/tableplus.desktop", target_base: :home
      inreplace ".local/share/applications/tableplus.desktop", /^Exec=.*/,
                "Exec={{HOMEBREW_PREFIX}}/bin/tableplus %U", base: :home, audit_result: false
      inreplace ".local/share/applications/tableplus.desktop", /^Icon=.*/,
                "Icon=tableplus", base: :home, audit_result: false
    end
    unless_path_exists "tableplus.desktop" do
      write_file ".local/share/applications/tableplus.desktop", <<~EOS, base: :home
        [Desktop Entry]
        Name=TablePlus
        Comment=Modern, native database GUI client
        GenericName=Database GUI
        Exec={{HOMEBREW_PREFIX}}/bin/tableplus %U
        Icon=tableplus
        Type=Application
        StartupNotify=true
        StartupWMClass=TablePlus
        Categories=Development;Database;
        MimeType=x-scheme-handler/tableplus;
        Keywords=database;sql;mysql;postgresql;sqlite;redis;
      EOS
    end
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/tableplus.desktop", base: :home
    remove ".local/share/icons/hicolor/256x256/apps/tableplus.png", base: :home
  end

  zap trash: [
    "~/.config/TablePlus",
    "~/.local/share/tableplus",
  ]
end
