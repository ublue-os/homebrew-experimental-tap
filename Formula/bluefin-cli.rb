class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/tuna-os/bluefin-cli"
  url "https://github.com/tuna-os/bluefin-cli/archive/refs/tags/v0.11.17.tar.gz"
  sha256 "21d79b81c0d0c57a76cb68f04d4de3264c98014744e57ac1a228da2c32805742"
  license "Apache-2.0"
  head "https://github.com/tuna-os/bluefin-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.11.17"
    rebuild 8
    sha256 cellar: :any_skip_relocation, arm64_linux:  "b964adbbe6bc3989e2ddd27ff869b49ac10be4c3cba93a47340a93c1842bb105"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b95473989ec2dc24579396c753a07578aef58b3de4e0bc8b15487380d2e0ee41"
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
