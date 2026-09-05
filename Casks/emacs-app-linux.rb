cask "emacs-app-linux" do
  arch arm: "arm64", intel: "amd64"

  version "30.2-18"
  sha256 arm64_linux:  "d2471179e3a7691148a585c04c573a9dc95ee26b448624f4a8131d73c2234698",
         x86_64_linux: "2d3d1c145fe8f0edf51f1275c5109eee116f98e2899498ca710ab96858fa0a70"

  url "https://github.com/daegalus/linux-app-builds/releases/download/emacs-pgtk-#{version}/emacs-pgtk-#{version.split("-").first}-fedora-latest-#{arch}.tar.gz"
  name "Emacs PGTK"
  desc "Text editor with PGTK support (Native Wayland and X11)"
  homepage "https://github.com/daegalus/linux-app-builds"

  livecheck do
    url :url
    regex(/^emacs-pgtk[._-]v?(\d+(?:\.\d+)+-\d+)$/i)
  end

  depends_on linux: :any
  depends_on formula: "libgccjit"
  depends_on formula: "tree-sitter@0.25"

  binary "emacs/run-emacs.sh", target: "emacs"
  binary "emacs/bin/emacs-#{version.split("-").first}", target: "emacs-#{version.split("-").first}"
  binary "emacs/bin/emacsclient"
  binary "emacs/bin/ctags"
  binary "emacs/bin/ebrowse"
  binary "emacs/bin/etags"
  manpage "emacs/share/man/man1/ctags.1.gz"
  manpage "emacs/share/man/man1/ebrowse.1.gz"
  manpage "emacs/share/man/man1/emacs.1.gz"
  manpage "emacs/share/man/man1/emacsclient.1.gz"
  manpage "emacs/share/man/man1/etags.1.gz"
  artifact "emacs/lib", target: "#{HOMEBREW_PREFIX}/opt/emacs-app-linux/lib"
  artifact "emacs/share", target: "#{HOMEBREW_PREFIX}/opt/emacs-app-linux/share"
  artifact "emacs/libexec", target: "#{HOMEBREW_PREFIX}/opt/emacs-app-linux/libexec"

  preflight_steps do
    # Resolve the full upstream version and architecture from this payload, not
    # the host CPU, so the same serialized steps work on both Linux architectures.
    run "sh", args: ["-eu", "-c", <<~'SH']
      export LC_ALL=C
      emacs_version="{{version}}"
      emacs_version=${emacs_version%%-*}
      set -- "{{staged_path}}"/emacs-pgtk-"$emacs_version"-fedora-latest-*
      [ "$#" -eq 1 ] && [ -d "$1" ]
      payload=$1
      case "$payload" in
        *-arm64) target_triplet=aarch64-unknown-linux-gnu ;;
        *-amd64) target_triplet=x86_64-pc-linux-gnu ;;
        *) exit 1 ;;
      esac
      printf "emacs_version='%s'\ntarget_triplet='%s'\n" "$emacs_version" "$target_triplet" > "$payload/emacs-paths.sh"

      # Emacs finds this relative dump link next to its versioned binary.
      for dump in "$payload/libexec/emacs/$emacs_version/$target_triplet/"*.pdmp; do
        [ -e "$dump" ] || break
        ln -sf "../libexec/emacs/$emacs_version/$target_triplet/${dump##*/}" "$payload/bin/emacs-$emacs_version.pdmp"
        break
      done

      wm_class="emacs-$(printf '%s' "$emacs_version" | tr . -)"
      for name in emacs emacsclient emacs-mail emacsclient-mail; do
        desktop="$payload/share/applications/$name.desktop"
        [ -f "$desktop" ] || continue
        sed -i \
          -e 's#Exec=emacs#Exec={{HOMEBREW_PREFIX}}/bin/emacs#g' \
          -e 's#Exec=/usr/local/bin/emacs#Exec={{HOMEBREW_PREFIX}}/bin/emacs#g' \
          -e 's#Exec=/usr/local/bin/emacsclient#Exec={{HOMEBREW_PREFIX}}/bin/emacsclient#g' \
          -e 's#Exec=emacsclient#Exec={{HOMEBREW_PREFIX}}/bin/emacsclient#g' "$desktop"
        if [ "$name" != emacs ]; then
          sed -i '/^StartupWMClass=.*/Id' "$desktop"
        elif grep -qi '^StartupWMClass=' "$desktop"; then
          sed -i "s/^StartupWMClass=.*/StartupWMClass=$wm_class/I" "$desktop"
        elif grep -qi '^StartupNotify=' "$desktop"; then
          sed -i "0,/^StartupNotify=.*$/Is//&\nStartupWMClass=$wm_class/" "$desktop"
        elif grep -qi '^Categories=' "$desktop"; then
          sed -i "0,/^Categories=.*$/Is//StartupWMClass=$wm_class\n&/" "$desktop"
        else
          printf '\nStartupWMClass=%s\n' "$wm_class" >> "$desktop"
        fi
      done
    SH
    # Linux sandbox setup creates the future inreplace path as a directory.
    # Clear that cask-owned placeholder before moving the extracted payload.
    remove "emacs", recursive: true
    move "emacs-pgtk-*-fedora-latest-*", "emacs", source_glob: true
    set_permissions "emacs/run-emacs.sh", "+x"

    inreplace(
      "emacs/run-emacs.sh",
      %r{# Add Homebrew paths.*?\n  export LD_LIBRARY_PATH="/home/linuxbrew/\.linuxbrew/lib:\$LD_LIBRARY_PATH"\nfi}m,
      <<~PATHS,
        # Add Homebrew paths if they exist (for systems like immutable distros)
        if [ -d "{{HOMEBREW_PREFIX}}/lib" ]; then
          export LD_LIBRARY_PATH="{{HOMEBREW_PREFIX}}/lib:$LD_LIBRARY_PATH"
        fi
        # Add libgccjit (required for native compilation)
        if [ -d "{{HOMEBREW_PREFIX}}/opt/libgccjit/lib/gcc/current" ]; then
          export LD_LIBRARY_PATH="{{HOMEBREW_PREFIX}}/opt/libgccjit/lib/gcc/current:$LD_LIBRARY_PATH"
        fi
        # Add tree-sitter@0.25 (keg-only)
        if [ -d "{{HOMEBREW_PREFIX}}/opt/tree-sitter@0.25/lib" ]; then
          export LD_LIBRARY_PATH="{{HOMEBREW_PREFIX}}/opt/tree-sitter@0.25/lib:$LD_LIBRARY_PATH"
        fi
      PATHS
      audit_result: false,
    )
    inreplace "emacs/run-emacs.sh",
              'export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/share/glib-2.0/schemas"',
              <<~ENVVARS, audit_result: false
                export GSETTINGS_SCHEMA_DIR="$SCRIPT_DIR/share/glib-2.0/schemas"
                . "{{staged_path}}/emacs/emacs-paths.sh"

                # Use the linked opt tree, or fall back to the staged data.
                if [ -d "{{HOMEBREW_PREFIX}}/opt/emacs-app-linux/share/emacs/$emacs_version" ]; then
                  export EMACSDATA="{{HOMEBREW_PREFIX}}/opt/emacs-app-linux/share/emacs/$emacs_version/etc"
                  export EMACSPATH="{{HOMEBREW_PREFIX}}/opt/emacs-app-linux/libexec/emacs/$emacs_version/$target_triplet"
                  export EMACSDOC="{{HOMEBREW_PREFIX}}/opt/emacs-app-linux/share/emacs/$emacs_version/etc"
                  export EMACSLOADPATH="{{HOMEBREW_PREFIX}}/opt/emacs-app-linux/share/emacs/$emacs_version/lisp:"
                else
                  export EMACSDATA="$SCRIPT_DIR/share/emacs/$emacs_version/etc"
                  export EMACSPATH="$SCRIPT_DIR/bin"
                  export EMACSDOC="$SCRIPT_DIR/share/emacs/$emacs_version/etc"
                  export EMACSLOADPATH="$SCRIPT_DIR/share/emacs/$emacs_version/lisp:"
                fi
              ENVVARS
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor", base: :home
    mkdir_p ".local/share/glib-2.0/schemas", base: :home

    if_path_exists "opt/emacs-app-linux/share/glib-2.0/schemas/gschemas.compiled", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/glib-2.0/schemas/gschemas.compiled",
           ".local/share/glib-2.0/schemas/gschemas.compiled", source_base: :homebrew_prefix, target_base: :home
      copy "opt/emacs-app-linux/share/glib-2.0/schemas/org.gnu.emacs.defaults.gschema.xml",
           ".local/share/glib-2.0/schemas/org.gnu.emacs.defaults.gschema.xml",
           source_base: :homebrew_prefix, target_base: :home
    end

    if_path_exists "opt/emacs-app-linux/share/icons/hicolor/16x16/apps/emacs.png", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/icons/hicolor/16x16/apps/emacs.png",
           ".local/share/icons/hicolor/16x16/apps/emacs.png", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/icons/hicolor/24x24/apps/emacs.png", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/icons/hicolor/24x24/apps/emacs.png",
           ".local/share/icons/hicolor/24x24/apps/emacs.png", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/icons/hicolor/32x32/apps/emacs.png", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/icons/hicolor/32x32/apps/emacs.png",
           ".local/share/icons/hicolor/32x32/apps/emacs.png", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/icons/hicolor/48x48/apps/emacs.png", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/icons/hicolor/48x48/apps/emacs.png",
           ".local/share/icons/hicolor/48x48/apps/emacs.png", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/icons/hicolor/128x128/apps/emacs.png", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/icons/hicolor/128x128/apps/emacs.png",
           ".local/share/icons/hicolor/128x128/apps/emacs.png", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/icons/hicolor/scalable/apps/emacs.svg", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/icons/hicolor/scalable/apps/emacs.svg",
           ".local/share/icons/hicolor/scalable/apps/emacs.svg", source_base: :homebrew_prefix, target_base: :home
    end

    if_path_exists "opt/emacs-app-linux/share/applications/emacs.desktop", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/applications/emacs.desktop", ".local/share/applications/emacs.desktop",
           source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/applications/emacsclient.desktop", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/applications/emacsclient.desktop",
           ".local/share/applications/emacsclient.desktop", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/applications/emacs-mail.desktop", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/applications/emacs-mail.desktop",
           ".local/share/applications/emacs-mail.desktop", source_base: :homebrew_prefix, target_base: :home
    end
    if_path_exists "opt/emacs-app-linux/share/applications/emacsclient-mail.desktop", base: :homebrew_prefix do
      copy "opt/emacs-app-linux/share/applications/emacsclient-mail.desktop",
           ".local/share/applications/emacsclient-mail.desktop", source_base: :homebrew_prefix, target_base: :home
    end

    mkdir_p "emacs-user-data"
    symlink ".local/share", "emacs-user-data/share", source_base: :home, overwrite: true
    if_path_exists "gtk-update-icon-cache", base: :search_path do
      run "gtk-update-icon-cache", args: ["{{staged_path}}/emacs-user-data/share/icons/hicolor", "-f", "-t"],
                                   must_succeed: false,
                                   writable_paths: [".local/share/icons/hicolor"], writable_base: :home
    end
    if_path_exists "update-desktop-database", base: :search_path do
      run "update-desktop-database", args: ["{{staged_path}}/emacs-user-data/share/applications"],
                                     must_succeed: false,
                                     writable_paths: [".local/share/applications"], writable_base: :home
    end
  end

  uninstall_postflight_steps do
    remove [
      ".local/share/applications/emacs.desktop",
      ".local/share/applications/emacsclient.desktop",
      ".local/share/applications/emacs-mail.desktop",
      ".local/share/applications/emacsclient-mail.desktop",
      ".local/share/icons/hicolor/16x16/apps/emacs.png",
      ".local/share/icons/hicolor/24x24/apps/emacs.png",
      ".local/share/icons/hicolor/32x32/apps/emacs.png",
      ".local/share/icons/hicolor/48x48/apps/emacs.png",
      ".local/share/icons/hicolor/128x128/apps/emacs.png",
      ".local/share/icons/hicolor/scalable/apps/emacs.svg",
      ".local/share/glib-2.0/schemas/gschemas.compiled",
      ".local/share/glib-2.0/schemas/org.gnu.emacs.defaults.gschema.xml",
    ], base: :home

    mkdir_p "emacs-user-data"
    symlink ".local/share", "emacs-user-data/share", source_base: :home, overwrite: true
    if_path_exists "gtk-update-icon-cache", base: :search_path do
      run "gtk-update-icon-cache", args: ["{{staged_path}}/emacs-user-data/share/icons/hicolor", "-f", "-t"],
                                   must_succeed: false,
                                   writable_paths: [".local/share/icons/hicolor"], writable_base: :home
    end
    if_path_exists "update-desktop-database", base: :search_path do
      run "update-desktop-database", args: ["{{staged_path}}/emacs-user-data/share/applications"],
                                     must_succeed: false,
                                     writable_paths: [".local/share/applications"], writable_base: :home
    end
  end
end
