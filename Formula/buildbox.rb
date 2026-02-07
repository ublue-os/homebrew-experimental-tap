class Buildbox < Formula
  desc "Set of tools for remote worker build execution"
  homepage "https://gitlab.com/BuildGrid/buildbox/buildbox"
  url "https://gitlab.com/BuildGrid/buildbox/buildbox/-/archive/1.3.52/buildbox-1.3.52.tar.gz"
  sha256 "4b48e97a000c725f326b8c4f78513954360018b4a56612cc453bf2643e8c99d4"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/ublue-os/homebrew-tap/releases/download/buildbox-1.3.52"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e7ea00d44718e91554b302c04818df85829f7ef537663f4e1cc25b9ee80a6e45"
  end

  depends_on "cmake" => :build
  depends_on "gflags" => :build
  depends_on "glog" => :build
  depends_on "google-benchmark" => :build
  depends_on "nlohmann-json" => :build
  depends_on "pkg-config" => :build
  depends_on "tomlplusplus" => :build
  depends_on "abseil"
  depends_on "grpc"
  depends_on "openssl@3"
  depends_on "protobuf"

  def install
    args = std_cmake_args + %w[
      -DTOOLS=OFF
      -DCASD=ON
      -DFUSE=ON
      -DRUN_BUBBLEWRAP=ON
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    bin.install_symlink "buildbox-run-bubblewrap" => "buildbox-run"
  end

  test do
    system "#{bin}/buildbox-casd", "--version"
    system "#{bin}/buildbox-fuse", "--version"
    system "#{bin}/buildbox-run", "--version"
  end
end