cask "emacs-app-linux" do
  arch arm: "arm64", intel: "amd64"

  version "30.2-18"
  sha256 arm64_linux:  "d2471179e3a7691148a585c04c573a9dc95ee26b448624f4a8131d73c2234698",
         x86_64_linux: "2d3d1c145fe8f0edf51f1275c5109eee116f98e2899498ca710ab96858fa0a70"

  url "https://github.com/daegalus/linux-app-builds/releases/download/emacs-pgtk-#{version}/emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}.tar.gz",
      verified: "github.com/daegalus/linux-app-builds/"
  name "Emacs PGTK"
  desc "Text editor with PGTK support (Native Wayland and X11)"
  homepage "https://github.com/daegalus/linux-app-builds"

  livecheck do
    url :url
    regex(/^emacs-pgtk[._-]v?(\d+(?:\.\d+)+-\d+)$/i)
  end

  depends_on formula: "libgccjit"
  depends_on formula: "tree-sitter@0.25"

  # Binaries
  binary "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/run-emacs.sh", target: "emacs"
  binary "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/bin/emacs-#{version.split("-").first}", target: "emacs-#{version.split("-").first}"
  binary "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/bin/emacsclient"
  binary "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/bin/ctags"
  binary "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/bin/ebrowse"
  binary "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/bin/etags"
  # Man pages
  manpage "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/share/man/man1/ctags.1.gz"
  manpage "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/share/man/man1/ebrowse.1.gz"
  manpage "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/share/man/man1/emacs.1.gz"
  manpage "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/share/man/man1/emacsclient.1.gz"
  manpage "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/share/man/man1/etags.1.gz"
  # Libraries (needed for emacs to run)
  artifact "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/lib",
           target: "#{HOMEBREW_PREFIX}/opt/emacs-app-linux/lib"
  # Share directory (elisp, icons, schemas, man pages, etc.)
  artifact "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/share",
           target: "#{HOMEBREW_PREFIX}/opt/emacs-app-linux/share"
  # Libexec (helper binaries and compiled modules)
  artifact "emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}/libexec",
           target: "#{HOMEBREW_PREFIX}/opt/emacs-app-linux/libexec"

  preflight do
    arch_str = arch

    emacs_version = version.split("-").first
    staged_prefix = "#{staged_path}/emacs-pgtk-#{emacs_version}-fedora-latest-#{arch_str}"

    # Defensive cleanup for Linux reinstall flows: ensure managed target
    # directories don't pre-exist before artifact moves.
    #
    # Why this workaround exists here:
    # - We cannot patch Homebrew core from this tap.
    # - On Linux, `brew reinstall --cask` can hit a Homebrew Generic Artifact
    #   move/quarantine path that incorrectly references macOS-only constants
    #   (`Cask::Quarantine::MacOS`).
    # - Removing these managed targets preflight keeps reinstall idempotent and
    #   avoids that upstream Homebrew path until a core fix is available.
    emacs_opt_root = "#{HOMEBREW_PREFIX}/opt/emacs-app-linux"
    %w[lib share libexec].each do |subdir|
      FileUtils.rm_rf("#{emacs_opt_root}/#{subdir}")
    end

    # Make run-emacs.sh executable
    FileUtils.chmod "+x", "#{staged_prefix}/run-emacs.sh"

    # Create symlink to pdmp file in bin directory - Emacs automatically finds it there
    # Emacs looks for {binary-name}.pdmp next to the binary (e.g., emacs-30.2.pdmp)
    # Using a relative symlink saves ~12MB compared to copying
    target_triplet = case arch_str
                     when "arm64"
                       "aarch64-unknown-linux-gnu"
                     else
                       "x86_64-pc-linux-gnu"
                     end
    pdmp_source = Dir.glob("#{staged_prefix}/libexec/emacs/#{emacs_version}/#{target_triplet}/*.pdmp").first
    if pdmp_source
      relative_path = "../libexec/emacs/#{emacs_version}/#{target_triplet}/#{File.basename(pdmp_source)}"
      FileUtils.ln_sf(relative_path, "#{staged_prefix}/bin/emacs-#{emacs_version}.pdmp")
    end

    # Update the run-emacs.sh script to include all necessary Homebrew library paths
    script_path = "#{staged_prefix}/run-emacs.sh"
    content = File.read(script_path)

    # Add tree-sitter and libgccjit paths after the Homebrew lib path check
    homebrew_paths = <<~PATHS
      # Add Homebrew paths if they exist (for systems like immutable distros)
      if [ -d "/home/linuxbrew/.linuxbrew/lib" ]; then
        export LD_LIBRARY_PATH="/home/linuxbrew/.linuxbrew/lib:$LD_LIBRARY_PATH"
      fi
      # Add libgccjit (required for native compilation)
      if [ -d "/home/linuxbrew/.linuxbrew/opt/libgccjit/lib/gcc/current" ]; then
        export LD_LIBRARY_PATH="/home/linuxbrew/.linuxbrew/opt/libgccjit/lib/gcc/current:$LD_LIBRARY_PATH"
      fi
      # Add tree-sitter@0.25 (keg-only)
      if [ -d "/home/linuxbrew/.linuxbrew/opt/tree-sitter@0.25/lib" ]; then
        export LD_LIBRARY_PATH="/home/linuxbrew/.linuxbrew/opt/tree-sitter@0.25/lib:$LD_LIBRARY_PATH"
      fi
    PATHS

    content.gsub!(
      %r{# Add Homebrew paths.*?\n  export LD_LIBRARY_PATH="/home/linuxbrew/\.linuxbrew/lib:\$LD_LIBRARY_PATH"\nfi}m,
      homebrew_paths.strip,
    )

    # Add Emacs data directory environment variables after the GSETTINGS_SCHEMA_DIR line
    emacs_env_vars = <<~ENVVARS
      export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/share/glib-2.0/schemas"

      # Set Emacs data directories (use Homebrew opt path when symlinked)
      if [ -d "/home/linuxbrew/.linuxbrew/opt/emacs-app-linux/share/emacs/#{emacs_version}" ]; then
        export EMACSDATA="/home/linuxbrew/.linuxbrew/opt/emacs-app-linux/share/emacs/#{emacs_version}/etc"
        export EMACSPATH="/home/linuxbrew/.linuxbrew/opt/emacs-app-linux/libexec/emacs/#{emacs_version}/#{target_triplet}"
        export EMACSDOC="/home/linuxbrew/.linuxbrew/opt/emacs-app-linux/share/emacs/#{emacs_version}/etc"
        export EMACSLOADPATH="/home/linuxbrew/.linuxbrew/opt/emacs-app-linux/share/emacs/#{emacs_version}/lisp"
      else
        export EMACSDATA="$SCRIPT_DIR/share/emacs/#{emacs_version}/etc"
        export EMACSPATH="$SCRIPT_DIR/bin"
        export EMACSDOC="$SCRIPT_DIR/share/emacs/#{emacs_version}/etc"
        export EMACSLOADPATH="$SCRIPT_DIR/share/emacs/#{emacs_version}/lisp"
      fi
    ENVVARS

    content.gsub!(
      'export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/share/glib-2.0/schemas"',
      emacs_env_vars.strip,
    )

    File.write(script_path, content)
  end

  postflight do
    # Create necessary directories
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/glib-2.0/schemas"

    emacs_root = "#{HOMEBREW_PREFIX}/opt/emacs-app-linux"

    # Copy compiled gschemas
    if File.exist?("#{emacs_root}/share/glib-2.0/schemas/gschemas.compiled")
      FileUtils.cp(
        "#{emacs_root}/share/glib-2.0/schemas/gschemas.compiled",
        "#{Dir.home}/.local/share/glib-2.0/schemas/",
      )
      FileUtils.cp(
        "#{emacs_root}/share/glib-2.0/schemas/org.gnu.emacs.defaults.gschema.xml",
        "#{Dir.home}/.local/share/glib-2.0/schemas/",
      )
    end

    # Copy icons to user directory
    icon_sizes = %w[16x16 24x24 32x32 48x48 128x128 scalable]
    icon_sizes.each do |size|
      src_icon = "#{emacs_root}/share/icons/hicolor/#{size}/apps/emacs.png"
      src_icon = "#{emacs_root}/share/icons/hicolor/#{size}/apps/emacs.svg" if size == "scalable"

      if File.exist?(src_icon)
        FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/#{size}/apps"
        FileUtils.cp(src_icon, "#{Dir.home}/.local/share/icons/hicolor/#{size}/apps/")
      end
    end

    # Update icon cache if available
    if system("which gtk-update-icon-cache > /dev/null 2>&1")
      system "gtk-update-icon-cache", "#{Dir.home}/.local/share/icons/hicolor", "-f",
             "-t"
    end

    # Install desktop files with corrected Exec paths
    emacs_version = version.split("-").first
    emacs_wm_class = "emacs-#{emacs_version.tr(".", "-")}"
    desktop_files = %w[emacs emacsclient emacs-mail emacsclient-mail]
    desktop_files.each do |desktop_name|
      src_desktop = [
        "#{emacs_root}/share/applications/#{desktop_name}.desktop",
        "#{emacs_root}/share/emacs/#{emacs_version}/etc/#{desktop_name}.desktop",
      ].find { |path| File.exist?(path) }
      next unless src_desktop

      desktop_content = File.read(src_desktop)
      # Fix Exec paths to use homebrew bin directory
      desktop_content.gsub!("Exec=emacs", "Exec=#{HOMEBREW_PREFIX}/bin/emacs")
      desktop_content.gsub!(%r{Exec=/usr/local/bin/emacs}, "Exec=#{HOMEBREW_PREFIX}/bin/emacs")
      desktop_content.gsub!(%r{Exec=/usr/local/bin/emacsclient}, "Exec=#{HOMEBREW_PREFIX}/bin/emacsclient")
      desktop_content.gsub!("Exec=emacsclient", "Exec=#{HOMEBREW_PREFIX}/bin/emacsclient")

      # Fix WMClass to ensure proper window grouping (use hyphen, not dot, to match Emacs binary name)
      # Replace existing StartupWMClass line or add new one if missing
      case desktop_content
      when /^StartupWMClass=/i
        desktop_content.gsub!(/^StartupWMClass=.*/i, "StartupWMClass=#{emacs_wm_class}")
      when /^StartupNotify=/i
        # Insert after StartupNotify line if it exists
        desktop_content.gsub!(/^(StartupNotify=.*?)$/i, "\\1\nStartupWMClass=#{emacs_wm_class}")
      when /^Categories=/i
        # Insert before Categories line if it exists
        desktop_content.gsub!(/^(Categories=.*?)$/i, "StartupWMClass=#{emacs_wm_class}\n\\1")
      end

      File.write("#{Dir.home}/.local/share/applications/#{desktop_name}.desktop", desktop_content)
    end

    # Update desktop database if available
    if system("which update-desktop-database > /dev/null 2>&1")
      system "update-desktop-database",
             "#{Dir.home}/.local/share/applications"
    end
  end

  uninstall_postflight do
    # Clean up desktop files
    %w[emacs emacsclient emacs-mail emacsclient-mail].each do |desktop_name|
      FileUtils.rm_f("#{Dir.home}/.local/share/applications/#{desktop_name}.desktop")
    end

    # Clean up icons
    icon_sizes = %w[16x16 24x24 32x32 48x48 128x128 scalable]
    icon_sizes.each do |size|
      icon_ext = (size == "scalable") ? "svg" : "png"
      FileUtils.rm_f("#{Dir.home}/.local/share/icons/hicolor/#{size}/apps/emacs.#{icon_ext}")
    end

    # Clean up gschemas
    FileUtils.rm_f("#{Dir.home}/.local/share/glib-2.0/schemas/gschemas.compiled")
    FileUtils.rm_f("#{Dir.home}/.local/share/glib-2.0/schemas/org.gnu.emacs.defaults.gschema.xml")

    # Update caches
    if system("which gtk-update-icon-cache > /dev/null 2>&1")
      system "gtk-update-icon-cache", "#{Dir.home}/.local/share/icons/hicolor", "-f",
             "-t"
    end
    if system("which update-desktop-database > /dev/null 2>&1")
      system "update-desktop-database",
             "#{Dir.home}/.local/share/applications"
    end
  end
end
