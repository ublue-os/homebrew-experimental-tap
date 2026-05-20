cask "antigravity-cli-linux" do
  arch arm: "arm", intel: "x64"

  version "0.1.0,5196844826651648"

  on_linux do
    sha256 arm64_linux:  "9cf45fb073a4c7f8299e05bb0c8f33be30373db74abc0210f184f59150fbc54f",
           x86_64_linux: "5fb55952d23691526bd3191dc5fad6a1d5310a27707661ebabc474cd21287df5"
  end

  url do
    url_arch = on_arch_conditional(arm: "arm64", intel: "x64")
    "https://storage.googleapis.com/antigravity-public/antigravity-cli/v#{version.csv.first}-#{version.csv.second}/linux-#{arch}/cli_linux_#{url_arch}"
  end
  verified "storage.googleapis.com/antigravity-public/"
  name "Antigravity CLI"
  desc "Command-line interface for Antigravity"
  homepage "https://antigravity.google/"

  binary do
    binary_arch = on_arch_conditional(arm: "arm64", intel: "x64")
    "cli_linux_#{binary_arch}"
  end, target: "antigravity"

  caveats <<~EOS
    To complete Antigravity CLI setup, authenticate:
      antigravity auth login
  EOS

  test do
    system bin/"antigravity", "--version"
  end
end
