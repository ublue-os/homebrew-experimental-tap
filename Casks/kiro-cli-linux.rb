cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.23.0"
  sha256 arm64_linux:  "b612418864aae4f7312e72ea7c886a53591294d24a2765da7565e119f9248f6f",
         x86_64_linux: "89748d77c0bbfd4bede93502f7c265aa90ed6d8b1f826643f391539453eef748"

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
