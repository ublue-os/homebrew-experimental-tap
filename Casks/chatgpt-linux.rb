cask "chatgpt-linux" do
  arch arm: "aarch64", intel: "x86_64"
  deb_arch = on_arch_conditional arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "26.915.31945"
  sha256 arm64_linux:  "f0f12033a4dbbc99104a9b6c118614c0204f974ff7c0ecc42e793219a3b8101c",
         x86_64_linux: "ccd1031664428959d9fcfefec7a82b8a27f40d31d9fcf5188a517d16fbe7d8a7"

  url "https://persistent.oaistatic.com/codex-app-prod/linux/rpm/#{arch}/chatgpt-#{version}-1.#{arch}.rpm"
  name "ChatGPT"
  desc "OpenAI's official ChatGPT desktop app"
  homepage "https://chatgpt.com/"

  livecheck do
    url "https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-#{deb_arch}/Packages"
    regex(/^Version:\s*(\d+(?:\.\d+)+)$/i)
  end

  auto_updates true
  depends_on formula: "cpio"
  depends_on formula: "rpm2cpio"
  depends_on linux: :any

  binary "usr/lib/chatgpt/codex-launcher", target: "chatgpt"
  artifact "usr/share/applications/chatgpt.desktop",
           target: "#{Dir.home}/.local/share/applications/chatgpt.desktop"
  artifact "usr/share/pixmaps/chatgpt.png",
           target: "#{Dir.home}/.local/share/icons/chatgpt.png"

  preflight_steps do
    # Normalise the arch- and version-specific RPM filename, then split extraction.
    move "chatgpt-{{version}}-1.*.rpm", "chatgpt.rpm", source_glob: true
    run "{{HOMEBREW_PREFIX}}/bin/rpm2cpio", args:        ["{{staged_path}}/chatgpt.rpm"],
                                            stdout_path: "chatgpt.cpio"
    run "{{HOMEBREW_PREFIX}}/bin/cpio", args: ["-idm", "--quiet"], stdin_path: "chatgpt.cpio",
        chdir: "{{staged_path}}"
    remove ["chatgpt.rpm", "chatgpt.cpio"]

    inreplace "usr/share/applications/chatgpt.desktop", /^Exec=.*/,
              "Exec={{HOMEBREW_PREFIX}}/bin/chatgpt %U", audit_result: false
    inreplace "usr/share/applications/chatgpt.desktop", /^Icon=.*/, "Icon=chatgpt", audit_result: false
  end

  zap trash: [
        "~/.cache/ChatGPT",
        "~/.cache/Codex",
        "~/.config/ChatGPT",
        "~/.config/Codex",
        "~/.local/share/ChatGPT",
        "~/.local/share/Codex",
      ],
      rmdir: "~/.codex"
end
