class RocmSmiLib < Formula
  desc "AMD ROCm System Management Interface library (provides librocm_smi64.so)"
  homepage "https://github.com/ROCm/rocm_smi_lib"
  url "https://github.com/ROCm/rocm_smi_lib/archive/refs/tags/rocm-7.2.4.tar.gz"
  sha256 "bf28d4ae385aad841474240510b6c52c44cc387bad30749b464b2b0cb8f59626"
  license "MIT"

  livecheck do
    url :stable
    regex(/^rocm-(\d+(?:\.\d+)+)$/i)
    strategy :github_tag
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/rocm-smi-lib-7.2.4"
    sha256 cellar: :any, arm64_linux:  "88a5bac639b69a09172d59c4136ee0f17a7073f1cde722672fd66c990b1a5b5c"
    sha256 cellar: :any, x86_64_linux: "1af2128b2722461814fae449f00825ccf91416f21f08632324f2cd366764575f"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libdrm"
  depends_on :linux

  def install
    # Pass explicit version numbers so cmake doesn't need git to detect them.
    # Produces librocm_smi64.so -> librocm_smi64.so.1 -> librocm_smi64.so.1.0
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_INSTALL_LIBDIR=lib",
           "-DBUILD_TESTS=OFF",
           "-DBUILD_SHARED_LIBS=ON",
           "-DCPACK_PACKAGE_VERSION_MAJOR=7",
           "-DCPACK_PACKAGE_VERSION_MINOR=2",
           "-DCPACK_PACKAGE_VERSION_PATCH=0",
           *std_cmake_args
    system "cmake", "--build", "build", "-j#{ENV.make_jobs}"
    system "cmake", "--install", "build"
  end

  def caveats
    conf_file = "/etc/ld.so.conf.d/rocm-smi-lib.conf"
    fish_conf = "#{Dir.home}/.config/fish/conf.d/rocm-smi-lib.fish"

    <<~EOS
      librocm_smi64.so has been installed to #{lib}.

      For btop and other tools to find it, its lib directory must be in the
      dynamic linker path. Choose one of these options:

      Option A – system-wide (survives reboots on bootc/ostree, recommended):
        sudo sh -c 'echo "#{lib}" >> #{conf_file} && ldconfig'

      Option B – current user only (fish shell, no sudo required):
        echo 'set -gx LD_LIBRARY_PATH "#{lib}" $LD_LIBRARY_PATH' \\
          >> #{fish_conf}
        set -gx LD_LIBRARY_PATH "#{lib}" $LD_LIBRARY_PATH

      Then restart any tool that uses librocm_smi64.so (e.g. btop).
    EOS
  end

  test do
    assert_path_exists lib/"librocm_smi64.so"
    assert_path_exists include/"rocm_smi/rocm_smi.h"
  end
end
