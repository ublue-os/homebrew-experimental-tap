cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.30.0"
  sha256 arm64_linux:  "7a41094bdf39d792fadfb76616a2f3790b77d8908b905e73b72e3f2f76f761e5",
         x86_64_linux: "2e913eb21c44f8bf70ee194fffbbc8dbd4c2ed586e3614e663d02247a8477777"

  url "https://prod.download.cli.kiro.dev/stable/#{version}/kirocli-#{arch}-linux.zip"
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

  postflight_steps do
    # Create `q` symlink for backward compatibility with Amazon Q CLI
    symlink "bin/kiro-cli", "bin/q", source_base: :homebrew_prefix, target_base: :homebrew_prefix,
            overwrite: true
  end

  uninstall_postflight_steps do
    remove "bin/q", base: :homebrew_prefix
  end

  zap trash: [
    "~/.config/kiro",
    "~/.kiro",
    "~/.local/share/kiro",
  ]
end
