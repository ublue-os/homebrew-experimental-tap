class Libgda < Formula
  desc "GNOME Data Access library"
  homepage "https://www.gnome-db.org/"
  url "https://download.gnome.org/sources/libgda/6.0/libgda-6.0.0.tar.xz"
  sha256 "995f4b420e666da5c8bac9faf55e7aedbe3789c525d634720a53be3ccf27a670"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://download.gnome.org/sources/libgda/cache.json"
    regex(/LATEST-IS-(\d+(?:\.\d+)+)/i)
  end

  depends_on "gobject-introspection" => :build
  depends_on "intltool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "glib"
  depends_on "iso-codes"
  depends_on "json-glib"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "readline"
  depends_on "sqlite"
  uses_from_macos "gettext"
  uses_from_macos "ncurses"

  def install
    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja", "install", "-v"
    end
  end

  test do
    system "#{bin}/gda-sql", "--version"
  end
end