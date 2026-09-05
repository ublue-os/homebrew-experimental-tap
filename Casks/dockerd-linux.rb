cask "dockerd-linux" do
  version "29.8.0"
  sha256 "cc21815cf1e2efed867dc9c8b96b46ffed8ea176ffab32b0aacb54726ded8f25"

  url "https://download.docker.com/linux/static/stable/x86_64/docker-#{version}.tgz"
  name "Dockerd"
  desc "Dockerd and utilities with rootless support by default"
  homepage "https://docs.docker.com/engine/security/rootless/"

  livecheck do
    url "https://download.docker.com/linux/static/stable/x86_64/"
    regex(/href=.*?docker[._-]v?(\d+(?:\.\d+)+)\.tgz/i)
  end

  depends_on formula: "slirp4netns"
  depends_on formula: "fuse-overlayfs"
  depends_on formula: "iproute2"
  depends_on formula: "iptables"
  depends_on formula: "docker"
  depends_on formula: "containerd"
  depends_on formula: "runc"

  # Binaries from the main tgz
  binary "docker/dockerd"
  binary "docker/docker-init"
  binary "docker/docker-proxy"
  # Docker rootless extras
  binary "docker-rootless-extras/dockerd-rootless.sh", target: "dockerd-rootless"
  binary "docker-rootless-extras/rootlesskit"

  preflight_steps do
    run "curl",
        args: ["-L", "https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-{{version}}.tgz",
               "-o", "extras.tgz"],
        chdir: "{{staged_path}}", network_access: true
    run "tar", args: ["-xzf", "extras.tgz"], chdir: "{{staged_path}}"
    remove "extras.tgz"
  end

  postflight_steps do
    mkdir_p ".config/systemd/user", base: :home

    write_file ".config/systemd/user/dockerd-rootless.service", <<~SERVICE, base: :home
      [Unit]
      Description=Docker Application Container Engine (Rootless)
      Documentation=https://docs.docker.com/go/rootless/

      [Service]
      Environment=PATH={{HOMEBREW_PREFIX}}/bin:{{HOMEBREW_PREFIX}}/sbin:/usr/bin:/usr/sbin:/bin
      Environment=XDG_RUNTIME_DIR=/run/user/%U
      ExecStart={{HOMEBREW_PREFIX}}/bin/dockerd-rootless --iptables=false
      ExecReload=/bin/kill -s HUP $MAINPID
      TimeoutSec=0
      RestartSec=2
      Restart=always
      StartLimitBurst=3
      StartLimitInterval=60s
      LimitNOFILE=infinity
      LimitNPROC=infinity
      LimitCORE=infinity
      TasksMax=infinity
      Delegate=yes
      Type=notify
      NotifyAccess=all
      KillMode=mixed

      [Install]
      WantedBy=default.target

      [Install]
      WantedBy=default.target
    SERVICE
    set_permissions ".config/systemd/user/dockerd-rootless.service", "0644", base: :home

    # Give the sandboxed Docker CLI a stable HOME whose .docker directory is a
    # narrow handle onto the real user's config directory.
    mkdir_p ".docker", base: :home
    mkdir_p "docker-home"
    symlink ".docker", "docker-home/.docker", source_base: :home
    write_file "configure-docker-context.sh", <<~SH
      #!/bin/sh
      docker_cli="{{HOMEBREW_PREFIX}}/bin/docker"
      docker_socket="unix:///run/user/$(id -u)/docker.sock"
      "$docker_cli" context inspect rootless >/dev/null 2>&1 || \
        "$docker_cli" context create rootless --docker host="$docker_socket"
      "$docker_cli" context use rootless
    SH
    set_permissions "configure-docker-context.sh", "0755"
    run "configure-docker-context.sh", base: :staged_path,
                                       env: {
                                         "DOCKER_CONFIG" => "{{staged_path}}/docker-home/.docker",
                                         "HOME"          => "{{staged_path}}/docker-home",
                                       },
                                       writable_paths: [".docker"], writable_base: :home
  end

  # Does not seem work...
  zap trash: "~/.config/systemd/user/dockerd-rootless.service"

  caveats <<~EOS
    This cask conflicts with the 'docker-engine' formula. If it is installed,
    uninstall it first:
      brew uninstall docker-engine

    Use 'dockerd-rootless --iptables=false' to start

    To enable and start the systemd service:
      systemctl --user daemon-reload
      systemctl --user enable --now dockerd-rootless

    A "rootless" docker context has been created and selected.
    To switch back to the default context:
      docker context use default
  EOS
end
