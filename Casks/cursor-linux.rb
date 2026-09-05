cask "cursor-linux" do
  arch arm: "arm64", intel: "x64"
  file_arch = on_arch_conditional arm: "aarch64", intel: "x86_64"

  version "3.18.9,2ba48ff3f7514cc4643c52ca9f7b3173d9b66137"
  sha256 arm64_linux:  "8e30411a75933139ed7adadeaefd8fe36d4a7a246b182eb679e1e6e1cc3b7851",
         x86_64_linux: "a02023f3b69f69d5e3f0ba02fe778c26237b8ac9760b59af6513b6e91f0478b2"

  url "https://downloads.cursor.com/production/#{version.csv.second}/linux/#{arch}/Cursor-#{version.csv.first}-#{file_arch}.AppImage"
  name "Cursor"
  desc "Write, edit, and chat about your code with AI"
  homepage "https://www.cursor.com/"

  livecheck do
    url "https://api2.cursor.sh/updates/api/update/linux-x64/cursor/0.0.0/stable"
    regex(%r{/production/(\h+)/linux/x64/Cursor[._-]([0-9.]+)[._-]x86_64\.AppImage}i)
    strategy :json do |json, regex|
      match = json["url"]&.match(regex)
      next if match.blank?

      "#{json["version"]},#{match[1]}"
    end
  end

  depends_on linux: :any

  binary "Cursor.AppImage", target: "cursor"
  bash_completion "#{staged_path}/squashfs-root/usr/share/cursor/resources/completions/bash/cursor"
  zsh_completion  "#{staged_path}/squashfs-root/usr/share/cursor/resources/completions/zsh/_cursor"
  artifact "cursor.desktop",
           target: "#{Dir.home}/.local/share/applications/cursor.desktop"
  artifact "cursor.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/cursor.png"

  preflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home

    # Normalise the architecture- and version-specific filename before extraction.
    move "Cursor-*.AppImage", "Cursor.AppImage", source_glob: true
    set_permissions "Cursor.AppImage", "+x"
    run "Cursor.AppImage", args: ["--appimage-extract"], base: :staged_path, chdir: "{{staged_path}}"

    if_path_exists "squashfs-root/usr/share/icons/hicolor/512x512/apps/cursor.png" do
      copy "squashfs-root/usr/share/icons/hicolor/512x512/apps/cursor.png", "cursor.png"
    end

    write_file "cursor.desktop", <<~EOS
      [Desktop Entry]
      Name=Cursor
      Comment=AI-first coding environment
      GenericName=Text Editor
      Exec={{HOMEBREW_PREFIX}}/bin/cursor %F
      Icon=cursor
      Type=Application
      StartupNotify=false
      StartupWMClass=Cursor
      Categories=TextEditor;Development;IDE;
      MimeType=text/plain;inode/directory;application/x-code-workspace;
      Actions=new-empty-window;
      Keywords=cursor;code;editor;

      [Desktop Action new-empty-window]
      Name=New Empty Window
      Exec={{HOMEBREW_PREFIX}}/bin/cursor --new-window %F
      Icon=cursor
    EOS

    # Keep a placeholder when the extracted image has no icon.
    unless_path_exists "cursor.png" do
      touch "cursor.png"
    end
  end

  zap trash: [
    "~/.config/Cursor",
    "~/.cursor",
  ]
end
