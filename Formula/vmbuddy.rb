class Vmbuddy < Formula
  desc "QEMU wrapper with sensible defaults"
  homepage "https://github.com/tulilirockz/vmbuddy"
  url "https://github.com/tulilirockz/vmbuddy/archive/refs/tags/0.1.0.tar.gz"
  sha256 "065ceb3e72987c0a60e28e138c9ca410154279fefc60b1495822a5d6b8135345"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)$/i)
  end

  def install
    bin.install "vmbuddy.sh" => "vmbuddy"
    bin.install_symlink "vmbuddy" => "vm"
  end

  test do
    assert_match "usage", shell_output("#{bin}/vmbuddy --help 2>&1", 1)
  end
end
