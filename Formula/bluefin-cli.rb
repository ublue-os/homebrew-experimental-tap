class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/tuna-os/bluefin-cli"
  url "https://github.com/tuna-os/bluefin-cli/archive/refs/tags/v0.11.20.tar.gz"
  sha256 "1a3d9012e124831726432693790ed4d84a4af8f2eccd8a275f997416c22d8d2d"
  license "Apache-2.0"
  head "https://github.com/tuna-os/bluefin-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.11.20"
    rebuild 11
    sha256 cellar: :any_skip_relocation, arm64_linux:  "7ef388083faf3b4b1e177bafc3aac2bc71c7de0e47f5f32d404f14b8c64dc099"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "51665822de0a8e7192e57a58365880fdf2889f39c3a18b08a8ee0f5695178882"
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
