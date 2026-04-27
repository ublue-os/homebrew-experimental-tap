class RocmSmiLib < Formula
  desc "AMD ROCm System Management Interface library (provides librocm_smi64.so)"
  homepage "https://github.com/ROCm/rocm_smi_lib"
  url "https://github.com/ROCm/rocm_smi_lib/archive/refs/tags/rocm-7.2.0.tar.gz"
  sha256 "9105b70b2ccda45d28c72973bb85df394d457a46d7cb2efbab3416b04d03b9f9"
  license "MIT"

  livecheck do
    url :stable
    regex(/^rocm-(\d+(?:\.\d+)+)$/i)
    strategy :github_tag
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
