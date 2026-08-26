cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.19.2"
  sha256 arm64_linux:  "36eba43b2b9188d013ada3a1c12d3c8f393f6283c02c3ceed8f6e5fe0e3d4a41",
         x86_64_linux: "940d1d348d990ac9d479fd7b41d6ec51f3aafe345a40bff22f5744893f1438aa"

  url "https://prod.download.cli.kiro.dev/stable/#{version}/kirocli-#{arch}-linux.zip",
      verified: "prod.download.cli.kiro.dev/"
  name "Kiro CLI"
  desc "Amazon Q Developer CLI - AI-powered command-line assistant"
  homepage "https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html"

  livecheck do
    url "https://prod.download.cli.kiro.dev/stable/latest/manifest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on linux: :any

  binary "kirocli/bin/kiro-cli"
  binary "kirocli/bin/kiro-cli-chat"
  binary "kirocli/bin/kiro-cli-term"

  postflight do
    # Create `q` symlink for backward compatibility with Amazon Q CLI
    q_link = "#{HOMEBREW_PREFIX}/bin/q"
    FileUtils.rm(q_link, force: true)
    FileUtils.ln_s "#{HOMEBREW_PREFIX}/bin/kiro-cli", q_link
  end

  uninstall_postflight do
    FileUtils.rm("#{HOMEBREW_PREFIX}/bin/q", force: true)
  end

  zap trash: [
    "~/.config/kiro",
    "~/.kiro",
    "~/.local/share/kiro",
  ]
end
