class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/tuna-os/bluefin-cli"
  url "https://github.com/tuna-os/bluefin-cli/archive/refs/tags/v0.11.16.tar.gz"
  sha256 "e6b56489091a4c488b8071138b64ad70fbbd6ce54572de818fb12200400cc370"
  license "Apache-2.0"
  head "https://github.com/tuna-os/bluefin-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.11.15"
    rebuild 7
    sha256 cellar: :any_skip_relocation, arm64_linux:  "4767768acf4a3fd9c1cd67485e72e6b33a0d61b6cf5171f5ac62c25d62539384"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "262fcb46ce9cb91dc753abe98755dfbcad02cbdd3c98c8a64ed93216b1d0b56b"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    # Matches upstream .goreleaser.yaml. Without the -X flag the `version`
    # variable in cmd/root.go keeps its "dev" default and `--version` reports
    # "bluefin-cli version dev", which fails the test block below.
    #
    # Read the module path from go.mod rather than hardcoding it: upstream moved
    # from github.com/hanthor/bluefin-cli to github.com/tuna-os/bluefin-cli
    # between 0.6.4 and 0.10.7, and a stale path silently leaves version at "dev".
    go_module = File.read(buildpath/"go.mod")[/^module\s+(\S+)/, 1]
    odie "could not read module path from go.mod" if go_module.blank?

    system "go", "build", *std_go_args(ldflags: "-X #{go_module}/cmd.version=#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bluefin-cli --version")
  end
end
