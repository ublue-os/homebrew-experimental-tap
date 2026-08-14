cask "chatgpt-linux" do
  arch arm: "aarch64", intel: "x86_64"
  deb_arch = on_arch_conditional arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "26.810.41047"
  sha256 arm:          "3d53e49471c81808bcc7e9a9383ab3b267587220d8cd5a97a859126285b1dd72",
         intel:        "9289dc2848430116f969d0fb75eb5a836f74654a5e7c2ca94269a9a4d49a6949",
         arm64_linux:  "3d53e49471c81808bcc7e9a9383ab3b267587220d8cd5a97a859126285b1dd72",
         x86_64_linux: "9289dc2848430116f969d0fb75eb5a836f74654a5e7c2ca94269a9a4d49a6949"

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

  binary "usr/lib/chatgpt/codex-launcher", target: "chatgpt"
  artifact "usr/share/applications/chatgpt.desktop",
           target: "#{Dir.home}/.local/share/applications/chatgpt.desktop"
  artifact "usr/share/pixmaps/chatgpt.png",
           target: "#{Dir.home}/.local/share/pixmaps/chatgpt.png"

  preflight do
    rpm2cpio = Formula["rpm2cpio"].bin/"rpm2cpio"
    cpio = Formula["cpio"].bin/"cpio"
    rpm_path = staged_path/"chatgpt-#{version}-1.#{arch}.rpm"
    system "sh", "-c", "'#{rpm2cpio}' '#{rpm_path}' | '#{cpio}' -idm --quiet", chdir: staged_path
    FileUtils.rm rpm_path

    desktop_file = staged_path/"usr/share/applications/chatgpt.desktop"
    content = File.read(desktop_file)
    content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/chatgpt %U")
    content.gsub!(/^Icon=.*/, "Icon=#{Dir.home}/.local/share/pixmaps/chatgpt.png")
    File.write(desktop_file, content)
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
