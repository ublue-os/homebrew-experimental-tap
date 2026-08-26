cask "chatgpt-linux" do
  arch arm: "aarch64", intel: "x86_64"
  deb_arch = on_arch_conditional arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "26.820.60940"
  sha256 arm64_linux:  "6ebfe98508ced6c70bc12ba00aad9d52ee51bb97f9eafbbd85e033a3f15d6556",
         x86_64_linux: "0c83159243c9ab18f05fbbcae85bd367d4b9fc7c05e65e41b706032aab955ed6"

  url "https://persistent.oaistatic.com/codex-app-prod/linux/rpm/#{arch}/chatgpt-#{version}-1.#{arch}.rpm"
  name "ChatGPT"
  desc "OpenAI's official ChatGPT desktop app"
  homepage "https://chatgpt.com/"

  livecheck do
    url "https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-#{deb_arch}/Packages"
    regex(/^Version:\s*(\d+(?:\.\d+)+)$/i)
  end

  auto_updates true
  depends_on linux: :any
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
