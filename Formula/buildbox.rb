class Buildbox < Formula
  desc "Set of tools for remote worker build execution"
  homepage "https://gitlab.com/BuildGrid/buildbox/buildbox"
  url "https://gitlab.com/BuildGrid/buildbox/buildbox/-/archive/1.3.52/buildbox-1.3.52.tar.gz"
  sha256 "4b48e97a000c725f326b8c4f78513954360018b4a56612cc453bf2643e8c99d4"
  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "pkg-config" => :build
  depends_on "tomlplusplus" => :build
  depends_on "abseil"
  depends_on "bubblewrap"
  depends_on "curl"
  depends_on "gflags"
  depends_on "glog"
  depends_on "grpc"
  depends_on "libfuse"
  depends_on :linux
  depends_on "openssl@3"
  depends_on "protobuf"
  depends_on "util-linux"

  def install
    args = std_cmake_args + %w[
      -DTOOLS=OFF
      -DCASD=ON
      -DFUSE=ON
      -DRUN_BUBBLEWRAP=ON
      -DCASD_BUILD_BENCHMARK=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    bin.install_symlink "buildbox-run-bubblewrap" => "buildbox-run"
  end

  test do
    system "#{bin}/buildbox-casd", "--version"
    system "#{bin}/buildbox-fuse", "--version"
    system "#{bin}/buildbox-run", "--version"
  end
end
