class Foundry < Formula
  desc "Command-line tool for building and managing IDE-like development environments"
  homepage "https://gitlab.gnome.org/GNOME/foundry"
  url "https://gitlab.gnome.org/GNOME/foundry.git", tag: "1.0.1", revision: "f6d82499d3ef5004526049c6abd9d09bbe2301d5"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "cmark"
  depends_on "editorconfig"
  depends_on "glib"
  depends_on "gom"
  depends_on "json-glib"
  depends_on "libadwaita"
  depends_on "libdex"
  depends_on "libgit2"
  depends_on "libpanel"
  depends_on "libpeas"
  depends_on "libsoup"
  depends_on "libxml2"
  depends_on "sysprof"
  depends_on "template-glib"
  depends_on "universal-ctags"

  def install
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("glib")/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("libgit2")/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("gettext")/"pkgconfig"

    # Set C_INCLUDE_PATH to ensure headers are found
    include_dirs = [
      formula_opt_include("glib")/"glib-2.0",
      formula_opt_lib("glib")/"glib-2.0/include",
      formula_opt_include("glib")/"gio-unix-2.0",
      formula_opt_include("libxml2")/"libxml2",
      formula_opt_include("libdex")/"libdex-1",
      formula_opt_include("json-glib")/"json-glib-1.0",
      formula_opt_include("libpeas")/"libpeas-2",
      formula_opt_include("template-glib")/"template-glib-1.0",
      formula_opt_include("libsoup")/"libsoup-3.0",
      formula_opt_include("gom")/"gom-1.0",
      formula_opt_include("sysprof")/"sysprof-6",
    ]

    ENV["C_INCLUDE_PATH"] = include_dirs.join(":")
    ENV["CPLUS_INCLUDE_PATH"] = include_dirs.join(":")

    args = %W[
      --wrap-mode=nofallback
      --prefix=#{prefix}
      --libdir=#{lib}
      --buildtype=plain
      -Dgtk=false
      -Dintrospection=disabled
      -Ddocs=false
      -Dfeature-flatpak=false
      -Dfeature-llm=false
    ]

    mkdir "build" do
      system "meson", "..", *args
      system "meson", "compile", "--verbose"
      system "meson", "install"
      # Remove compiled schema file to avoid linking conflicts
      rm("#{share}/glib-2.0/schemas/gschemas.compiled")
    end

    # Fix lib64 issue if it still occurs
    ln_s "lib64", prefix/"lib" if (prefix/"lib64").exist? && !(prefix/"lib").exist?
  end

  def caveats
    <<~EOS
      To complete foundry setup:

      1. Set the schema directory:
         export GSETTINGS_SCHEMA_DIR=#{opt_prefix}/share/glib-2.0/schemas:$GSETTINGS_SCHEMA_DIR

      2. Compile the schemas:
         glib-compile-schemas #{opt_prefix}/share/glib-2.0/schemas

      3. Add the export to your shell profile to make it permanent:
         echo 'export GSETTINGS_SCHEMA_DIR=#{opt_prefix}/share/glib-2.0/schemas:$GSETTINGS_SCHEMA_DIR' >> ~/.bashrc
         # or ~/.zshrc if using zsh

      After setup, foundry will be ready to use in your development projects.
    EOS
  end

  test do
    system bin/"foundry", "--help"
  end
end
