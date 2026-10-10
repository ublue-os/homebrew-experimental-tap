class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/tuna-os/bluefin-cli"
  url "https://github.com/tuna-os/bluefin-cli/archive/refs/tags/v0.11.7.tar.gz"
  sha256 "55a611b122917474c540bb52fd7c859d3e0f05d717fccdc69773c2ea6d75fd92"
  license "Apache-2.0"
  head "https://github.com/tuna-os/bluefin-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.11.6"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_linux:  "2c07c4fb2e2414a03d35bcd88fa834d75a8c33ae62a32745016a4cc901764753"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0f3624385e014c69f90084cb434b0f760b4f7d37b842b3bb8cd279cdfcedc62c"
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
