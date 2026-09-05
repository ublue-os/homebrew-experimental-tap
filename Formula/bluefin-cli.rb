class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/tuna-os/bluefin-cli"
  url "https://github.com/tuna-os/bluefin-cli/archive/refs/tags/v0.10.9.tar.gz"
  sha256 "2dd27c31d1d42c370c9e670173a8b3db71fbb5eebc680c47f813f5c0a4d6ef26"
  license "Apache-2.0"
  head "https://github.com/tuna-os/bluefin-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.10.7"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_linux:  "76b1fdbee30c36b5374091c3c0d767a319dc091639c516b43e99bb448c6f523f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "86dd89738ce1c51293399db7c9629018c76591f0c8ebd6acf74fd4d423971cd5"
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
