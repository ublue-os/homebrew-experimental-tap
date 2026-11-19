class Distrobox2 < Formula
  desc "Use any linux distribution inside your terminal. (Release Candidate for v2)"
  homepage "https://github.com/89luca89/distrobox"
  url "https://github.com/89luca89/distrobox/archive/refs/tags/2.0.0-rc.3.tar.gz"
  sha256 "d3f011429cebb8511ea30e0526216a4cb60b9545b45a8e20fa8852852e484514"
  license "GPL-3.0-or-later"
  head "https://github.com/89luca89/distrobox.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/distrobox2-2.0.0-rc.3"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_linux:  "275e35c2ea762ce4797200c396b23606330447d3eb046884b8b78d2f7fe6b330"
    sha256 cellar: :any,                 x86_64_linux: "96795b7980eec6c109362d0692932b3ba9e1ce26a41f9ea2a3378b2581092456"
  end

  depends_on "go" => :build

  def install
    # Build the distrobox binary
    system "go", "build",
           "-ldflags", "-s -w -X github.com/89luca89/distrobox/pkg/version.Version=#{version}",
           "-o", "distrobox2",
           "./cmd/distrobox"

    bin.install "distrobox2"
  end

  test do
    output = shell_output("#{bin}/distrobox2 --help")
    assert_match version.to_s, output
  end
end
