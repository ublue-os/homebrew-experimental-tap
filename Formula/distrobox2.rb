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

  depends_on "go" => :build

  def install
    # Build the distrobox binary
    system "go", "build",
           "-ldflags", "-s -w -X main.Version=#{version}",
           "-o", "distrobox2",
           "./cmd/distrobox"

    bin.install "distrobox2"
  end

  test do
    output = shell_output("#{bin}/distrobox2 --version")
    assert_includes output, "distrobox"
  end
end
