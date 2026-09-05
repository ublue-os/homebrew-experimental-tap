cask "fw-fanctrl-linux" do
  version "1.0.4,2"
  sha256 "d716bf48c72504264a06cd58aa2865d533485a504921f99f9e2587f769606855"

  release_tag = "fw-fanctrl-#{version.csv.first}-#{version.csv.second}"
  release_root = "fw-fanctrl-#{version.csv.first}-x86_64"

  url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/#{release_tag}/#{release_root}.tar.gz"
  name "fw-fanctrl"
  desc "Framework laptop fan controller daemon and CLI"
  homepage "https://github.com/TamtamHero/fw-fanctrl"

  livecheck do
    url "https://api.github.com/repos/ublue-os/homebrew-experimental-tap/releases"
    strategy :json do |json|
      json.filter_map do |rel|
        match = rel["tag_name"].to_s.match(/^fw-fanctrl-(\d+(?:\.\d+)+)-(\d+)$/)
        next if match.nil?

        "#{match[1]},#{match[2]}"
      end.max
    end
  end

  binary "release/usr/bin/fw-fanctrl"
  binary "release/usr/bin/ectool"

  preflight_steps do
    # Normalise the versioned payload directory before install.
    move "fw-fanctrl-*", "release", source_glob: true
  end

  postflight_steps do
    # The payload is installed under canonical system paths via a sudo-brokered
    # shell step. Commands mirror the original `system("sudo", ...)` calls,
    # which ignore non-zero exits, so the script does not `set -e`; failures
    # inside are tolerated exactly as the legacy code tolerated them.
    run "sh",
        sudo: true,
        args: ["-c", <<~SH]
          root_prefix="/opt/ublue-fw-fanctrl"
          root_bin_dir="$root_prefix/bin"
          systemd_dir="/etc/systemd/system"
          sleep_dir="/etc/systemd/system-sleep"
          config_dir="/etc/fw-fanctrl"
          release_dir="{{staged_path}}/release"

          service_src="$release_dir/usr/lib/systemd/system/fw-fanctrl.service"
          sleep_src="$release_dir/usr/lib/systemd/system-sleep/fw-fanctrl-suspend"
          config_src="$release_dir/usr/share/fw-fanctrl/config.json"
          schema_src="$release_dir/usr/share/fw-fanctrl/config.schema.json"

          getenforce_cmd=""; for p in /usr/sbin/getenforce /usr/bin/getenforce /bin/getenforce; do
            [ -x "$p" ] && getenforce_cmd="$p" && break; done
          restorecon_cmd=""; for p in /usr/sbin/restorecon /usr/bin/restorecon /bin/restorecon; do
            [ -x "$p" ] && restorecon_cmd="$p" && break; done
          semanage_cmd=""; for p in /usr/sbin/semanage /usr/bin/semanage /bin/semanage; do
            [ -x "$p" ] && semanage_cmd="$p" && break; done
          chcon_cmd=""; for p in /usr/sbin/chcon /usr/bin/chcon /bin/chcon; do
            [ -x "$p" ] && chcon_cmd="$p" && break; done
          systemctl_cmd=""; for p in /usr/bin/systemctl /bin/systemctl; do
            [ -x "$p" ] && systemctl_cmd="$p" && break; done

          install -d "$root_bin_dir" "$systemd_dir" "$sleep_dir" "$config_dir"
          install -Dm0755 "$release_dir/usr/bin/fw-fanctrl" "$root_bin_dir/fw-fanctrl"
          install -Dm0755 "$release_dir/usr/bin/ectool" "$root_bin_dir/ectool"
          install -Dm0644 "$service_src" "$systemd_dir/fw-fanctrl.service"
          install -Dm0755 "$sleep_src" "$sleep_dir/fw-fanctrl-suspend"
          install -Dm0644 "$schema_src" "$config_dir/config.schema.json"
          if [ ! -f "$config_dir/config.json" ]; then
            install -Dm0644 "$config_src" "$config_dir/config.json"
          fi

          if [ -n "$getenforce_cmd" ]; then
            selinux_mode="$("$getenforce_cmd" 2>/dev/null)"
          else
            selinux_mode="Disabled"
          fi
          selinux_mode="${selinux_mode:-Disabled}"

          if [ "$selinux_mode" != "Disabled" ]; then
            bin_pattern="$root_bin_dir(/.*)?"
            if [ -n "$semanage_cmd" ]; then
              if "$semanage_cmd" fcontext -a -t bin_t "$bin_pattern" 2>/dev/null; then
                :
              else
                "$semanage_cmd" fcontext -m -t bin_t "$bin_pattern" 2>/dev/null || true
              fi
            elif [ -n "$chcon_cmd" ]; then
              "$chcon_cmd" -R -t bin_t "$root_bin_dir" 2>/dev/null || true
            fi
            if [ -n "$restorecon_cmd" ]; then
              for path in "$root_prefix" "$systemd_dir" "$sleep_dir" "$config_dir"; do
                [ -e "$path" ] && "$restorecon_cmd" -RFv "$path" 2>/dev/null || true
              done
            fi
          fi

          [ -z "$systemctl_cmd" ] || "$systemctl_cmd" daemon-reload 2>/dev/null || true
        SH
  end

  uninstall_preflight_steps do
    # The payload is removed under canonical system paths via a sudo-brokered
    # shell step. Commands mirror the original `system("sudo", ...)` semantics
    # (errors ignored), so the script does not `set -e`.
    run "sh",
        sudo: true,
        args: ["-c", <<~SH]
          root_prefix="/opt/ublue-fw-fanctrl"
          root_bin_dir="$root_prefix/bin"
          systemd_dir="/etc/systemd/system"
          sleep_dir="/etc/systemd/system-sleep"
          config_dir="/etc/fw-fanctrl"

          getenforce_cmd=""; for p in /usr/sbin/getenforce /usr/bin/getenforce /bin/getenforce; do
            [ -x "$p" ] && getenforce_cmd="$p" && break; done
          restorecon_cmd=""; for p in /usr/sbin/restorecon /usr/bin/restorecon /bin/restorecon; do
            [ -x "$p" ] && restorecon_cmd="$p" && break; done
          semanage_cmd=""; for p in /usr/sbin/semanage /usr/bin/semanage /bin/semanage; do
            [ -x "$p" ] && semanage_cmd="$p" && break; done
          systemctl_cmd=""; for p in /usr/bin/systemctl /bin/systemctl; do
            [ -x "$p" ] && systemctl_cmd="$p" && break; done

          [ -z "$systemctl_cmd" ] || "$systemctl_cmd" disable --now fw-fanctrl.service 2>/dev/null

          if [ -n "$getenforce_cmd" ]; then
            selinux_mode="$("$getenforce_cmd" 2>/dev/null)"
          else
            selinux_mode="Disabled"
          fi
          selinux_mode="${selinux_mode:-Disabled}"
          if [ "$selinux_mode" != "Disabled" ] && [ -n "$semanage_cmd" ]; then
            "$semanage_cmd" fcontext -d "$root_bin_dir(/.*)?" 2>/dev/null || true
          fi

          rm -f "$systemd_dir/fw-fanctrl.service"
          rm -f "$sleep_dir/fw-fanctrl-suspend"
          rm -f "$config_dir/config.schema.json"
          rm -rf "$root_prefix"
          if [ -d "$config_dir" ] && [ -z "$(ls -A "$config_dir" 2>/dev/null)" ]; then
            rmdir "$config_dir" 2>/dev/null || true
          fi

          [ -z "$systemctl_cmd" ] || "$systemctl_cmd" daemon-reload 2>/dev/null || true
          if [ -n "$restorecon_cmd" ] && [ "$selinux_mode" != "Disabled" ]; then
            "$restorecon_cmd" -RFv /opt /var/opt 2>/dev/null || true
          fi
        SH
  end

  caveats <<~EOS
    fw-fanctrl is installed under:
      /opt/ublue-fw-fanctrl/bin/{fw-fanctrl,ectool}
      /etc/systemd/system/fw-fanctrl.service
      /etc/systemd/system-sleep/fw-fanctrl-suspend
      /etc/fw-fanctrl/config.json (default; not overwritten on upgrade)
      /etc/fw-fanctrl/config.schema.json

    To activate the daemon:
      sudo systemctl enable --now fw-fanctrl.service

    To change fan curves, edit /etc/fw-fanctrl/config.json, then:
      sudo fw-fanctrl reload

    Requires system CPython 3.14 at /usr/bin/python3.14.
    Framework laptops only; upstream: https://github.com/TamtamHero/fw-fanctrl
  EOS
end
