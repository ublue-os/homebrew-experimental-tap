class LibxcryptCompat < Formula
  desc "Legacy libcrypt.so.1 ABI compatibility library"
  homepage "https://github.com/besser82/libxcrypt"
  url "https://github.com/besser82/libxcrypt/releases/download/v4.5.2/libxcrypt-4.5.2.tar.xz"
  sha256 "71513a31c01a428bccd5367a32fd95f115d6dac50fb5b60c779d5c7942aec071"
  license "LGPL-2.1-or-later"

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/libxcrypt-compat-4.5.2"
    sha256 cellar: :any, arm64_linux:  "c648502316caefed68f91f52f421d979e662da1e7fbbb1ad25801f7f89214640"
    sha256 cellar: :any, x86_64_linux: "19a35f19c6c15b55c4a7b7d0a2a8affcf98884252a07a7cc507525580e3bdf11"
  end

  keg_only "it provides the legacy libcrypt.so.1 ABI"

  depends_on :linux

  def install
    system "./configure", "--disable-static",
                          "--enable-hashes=strong,glibc",
                          "--enable-obsolete-api=glibc",
                          "--disable-failure-tokens",
                          "--disable-valgrind",
                          *std_configure_args
    system "make", "install"
  end

  test do
    assert_path_exists lib/"libcrypt.so.1"
  end
end
