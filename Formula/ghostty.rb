class Ghostty < Formula
  desc "Fast, native, feature-rich terminal emulator using platform-native UI"
  homepage "https://ghostty.org/"
  url "https://release.files.ghostty.org/1.3.1/ghostty-1.3.1.tar.gz"
  sha256 "3349d25600ffbda281197a18314f7d18791969cffe9474f0ff16a45a9ebfccdb"
  license "MIT"

  livecheck do
    url "https://api.github.com/repos/ghostty-org/ghostty/tags?per_page=10"
    strategy :json do |json|
      json.filter_map { |t| t["name"]&.delete_prefix("v") if t["name"] != "tip" }.first
    end
  end

  depends_on "pkg-config" => :build
  depends_on "zig" => :build
  depends_on :linux

  # Ghostty requires GTK4 and libadwaita for the Linux GUI
  depends_on "gtk4"
  depends_on "libadwaita"
  depends_on "blueprint-compiler" => :build

  # Additional dependencies for font rendering and system integration
  uses_from_macos "libpng"
  uses_from_macos "zlib"

  def install
    # Ghostty uses Zig's build system
    system "zig", "build",
           "-p", prefix,
           "-Doptimize=ReleaseFast",
           "-Dcpu=baseline"
  end

  def post_install
    # Install desktop file and icons
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"

    desktop_src = share/"applications/com.mitchellh.ghostty.desktop"
    desktop_dest = "#{xdg_data}/applications/com.mitchellh.ghostty.desktop"
    FileUtils.cp(desktop_src, desktop_dest) if File.exist?(desktop_src)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ghostty --version")
  end
end
