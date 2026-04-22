class Ydotool < Formula
  desc "Generic command-line automation tool (no X!)"
  homepage "https://github.com/ReimuNotMoe/ydotool"
  url "https://github.com/ReimuNotMoe/ydotool/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "ba075a43aa6ead51940e892ecffa4d0b8b40c241e4e2bc4bd9bd26b61fde23bd"
  license "AGPL-3.0-only"
  head "https://github.com/ReimuNotMoe/ydotool.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "scdoc" => :build
  depends_on :linux

  def install
    # Patch CMakeLists.txt to update minimum required version
    inreplace "CMakeLists.txt", /cmake_minimum_required\(VERSION [^)]+\)/,
              "cmake_minimum_required(VERSION 3.5)"

    system "cmake", "-S", ".", "-B", "build",
           "-DSYSTEMD_USER_SERVICE=OFF",
           *std_cmake_args
    system "cmake", "--build", "build", "-j#{ENV.make_jobs}"
    system "cmake", "--install", "build"
  end

  service do
    run [opt_bin/"ydotoold", "--socket-path=/run/user/#{Process.uid}/.ydotool_socket"]
    keep_alive true
    error_log_path var/"log/ydotoold.log"
    log_path var/"log/ydotoold.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      ydotool requires the ydotoold daemon to be running.

      The socket will be created at: /run/user/#{Process.uid}/.ydotool_socket

      Start the service with:
        brew services start ydotool

      Or run manually:
        ydotoold --socket-path=/run/user/#{Process.uid}/.ydotool_socket

      You may need to add your user to the input group:
        sudo usermod -a -G input $USER

      Then log out and back in for the changes to take effect.
    EOS
  end

  test do
    assert_match "Usage: ydotool <cmd> <args>", shell_output("#{bin}/ydotool --help")
    assert_match "ydotool Daemon", shell_output("#{bin}/ydotoold --help")
  end
end
