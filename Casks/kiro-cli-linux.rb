cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.20.2"
  sha256 arm64_linux:  "09f4ecb046a90e91854dba11f80d465571d9961d456305a597c202f6e1b03a53",
         x86_64_linux: "9f5e37230e7f3becbfe16663569a31dca0698004d8f5d0c575ac92812e0087c6"

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
