class LibvirtFull < Formula
  desc "C virtualization API, now with udev support"
  homepage "https://libvirt.org/"
  url "https://download.libvirt.org/libvirt-11.10.0.tar.xz"
  sha256 "66154fee836235678b712676b2589c45f66e3d6a8721ee0697c9f20a66cad0d8"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  head "https://gitlab.com/libvirt/libvirt.git", branch: "master"

  livecheck do
    url "https://download.libvirt.org"
    regex(/href=.*?libvirt[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 x86_64_linux: "8cbd53c67b20a32b295d02cfd8c08fc9d17834fa712baec2ae1538ea2136922f"
  end

  depends_on "docutils" => :build
  depends_on "gettext" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "acl"
  depends_on "curl"
  depends_on "cyrus-sasl"
  depends_on "glib"
  depends_on "gnutls"
  depends_on "gperf"
  depends_on "json-c"
  depends_on "libiscsi"
  depends_on "libnl"
  depends_on "libpciaccess"
  depends_on "libssh2"
  depends_on "libtirpc"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "readline"
  depends_on "util-linux"

  conflicts_with "libvirt", because: "this is a special build of libvirt with udev support"

  resource "eudev" do
    url "https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz"
    sha256 "8da4319102f24abbf7fff5ce9c416af848df163b29590e666d334cc1927f006f"
  end

  def install
    resource("eudev").stage do
      system "./configure", "--prefix=#{libexec}/eudev",
                            "--disable-introspection",
                            "--disable-hwdb",
                            "--disable-manpages"
      system "make", "install"
    end

    ENV.prepend_path "PKG_CONFIG_PATH", libexec/"eudev/lib/pkgconfig"
    ENV.append "LDFLAGS", "-L#{libexec}/eudev/lib -Wl,-rpath=#{libexec}/eudev/lib"
    ENV.append "CPPFLAGS", "-I#{libexec}/eudev/include"

    args = %W[
      --localstatedir=#{var}
      --mandir=#{man}
      --sysconfdir=#{etc}
      -Dudev=enabled
      -Ddriver_esx=enabled
      -Ddriver_qemu=enabled
      -Ddriver_network=enabled
      -Dinit_script=none
      -Dqemu_datadir=#{Formula["qemu"].opt_pkgshare}
      -Drunstatedir=#{var}/run
    ]
    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  service do
    run [opt_sbin/"libvirtd", "-f", etc/"libvirt/libvirtd.conf"]
    keep_alive true
    environment_variables PATH: HOMEBREW_PREFIX/"bin"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/virsh -v")
  end
end
