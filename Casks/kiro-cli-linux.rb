cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "3.4.0"
  sha256 arm64_linux:  "98401395ca36eda9682445062c090b2c81413640d9f1e7433e741fa3147dde6e",
         x86_64_linux: "95b85a724ecda5340cc5c98ddc979f4d0a6e96712fb29a36b3e7afaf6c70d389"

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
