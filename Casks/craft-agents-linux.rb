cask "craft-agents-linux" do
  version "0.13.4"
  sha256 "1f6829604cbf745a685155ae988f1646f07fc1d8ea7ef42f3508a1a3b4150a3a"

  url "https://github.com/craft-ai-agents/craft-agents-oss/releases/download/v#{version}/Craft-Agents-#{version}-linux-x64.AppImage"
  name "Craft Agents"
  desc "Work with most powerful agents in the world, with the UX they deserve"
  homepage "https://agents.craft.do/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/@craft-agentelectron", target: "craft-agents"

  preflight_steps do
    # Normalise the versioned AppImage filename before extraction.
    move "Craft-Agents-{{version}}-linux-x64.AppImage", "craft-agents.AppImage", source_glob: true
    set_permissions "craft-agents.AppImage", "+x"
    run "craft-agents.AppImage", args: ["--appimage-extract"], base: :staged_path, chdir: "{{staged_path}}"
    remove "craft-agents.AppImage"
  end

  postflight_steps do
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home
    copy "squashfs-root/usr/share/icons/hicolor/512x512/apps/@craft-agentelectron.png",
         ".local/share/icons/hicolor/512x512/apps/@craft-agentelectron.png", target_base: :home
    inreplace "squashfs-root/@craft-agentelectron.desktop", /^Exec=AppRun/,
              "Exec={{HOMEBREW_PREFIX}}/bin/craft-agents", audit_result: false
    inreplace "squashfs-root/@craft-agentelectron.desktop", /^Icon=.*/,
              "Icon=@craft-agentelectron", audit_result: false
    inreplace "squashfs-root/@craft-agentelectron.desktop", /^StartupWMClass=.*/,
              "StartupWMClass=@craft-agent/electron", audit_result: false
    copy "squashfs-root/@craft-agentelectron.desktop", ".local/share/applications/@craft-agentelectron.desktop",
         target_base: :home
  end

  uninstall_postflight_steps do
    remove ".local/share/icons/hicolor/512x512/apps/@craft-agentelectron.png", base: :home
    remove ".local/share/applications/@craft-agentelectron.desktop", base: :home
  end

  zap trash: [
    "~/.config/Craft Agents",
    "~/.craft-agent",
  ]
end
