cask "docker-rootless-linux" do
  arch intel: "x86_64"

  version "29.1.3"
  sha256 intel: "a9a19e20dd09c61ec1af7d67d9dec2455004d0fbd35120fe1d24588c123f9474"

  url "https://download.docker.com/linux/static/stable/#{arch}/docker-#{version}.tgz"
  name "Docker Rootless"
  desc "Docker static binaries with rootless extras"
  homepage "https://docs.docker.com/engine/security/rootless/"

  livecheck do
    url "https://download.docker.com/linux/static/stable/#{arch}/"
    regex(/href=.*?docker[._-]v?(\d+(?:\.\d+)+)\.tgz/i)
  end

  depends_on formula: "slirp4netns"
  depends_on formula: "fuse-overlayfs"
  depends_on formula: "iproute2"
  depends_on formula: "docker"

  # Binaries from the main tgz
  # The docker cli is aleady in brew
  binary "docker/dockerd"
  binary "docker/docker-init"
  binary "docker/docker-proxy"
  binary "docker/containerd"
  binary "docker/containerd-shim-runc-v2"
  binary "docker/ctr"
  binary "docker/runc"
  # Docker rootless extras
  binary "docker-rootless-extras/dockerd-rootless.sh", target: "dockerd-rootless"
  binary "docker-rootless-extras/rootlesskit"
  binary "docker-rootless-extras/vpnkit"

  preflight do
    extras_url = "https://download.docker.com/linux/static/stable/#{arch}/docker-rootless-extras-#{version}.tgz"

    ohai "Downloading docker-rootless-extras..."
    system_command "curl", args: ["-L", extras_url, "-o", "#{staged_path}/extras.tgz"]

    ohai "Extracting extras..."
    system_command "tar", args: ["-xzf", "#{staged_path}/extras.tgz", "-C", staged_path]

    File.delete("#{staged_path}/extras.tgz")
  end

  postflight do
    require "fileutils"

    systemd_dir = File.expand_path("~/.config/systemd/user")
    service_file = File.join(systemd_dir, "dockerd-rootless.service")

    ohai "Creating systemd user service..."
    FileUtils.mkdir_p(systemd_dir)

    # Normal brew service don't want to work with Casks
    service_content = <<~SERVICE
      [Unit]
      Description=Docker Application Container Engine (Rootless)
      Documentation=https://docs.docker.com/go/rootless/

      [Service]
      Environment=PATH=#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/usr/sbin:/bin
      Environment=XDG_RUNTIME_DIR=/run/user/%U
      ExecStart=#{HOMEBREW_PREFIX}/bin/dockerd-rootless --iptables=false
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

    File.write(service_file, service_content)
    FileUtils.chmod(0644, service_file)

    ohai "Systemd service created at #{service_file}"
    ohai "Run 'systemctl --user daemon-reload' to load the service"
    ohai "Then enable and start with: systemctl --user enable --now dockerd-rootless"

    ohai "Configuring docker context..."
    docker_cli = "#{HOMEBREW_PREFIX}/bin/docker"
    docker_socket = "unix:///run/user/#{Process.uid}/docker.sock"
    context_create_cmd = "#{docker_cli} context create rootless --docker host=#{docker_socket}"
    system_command "sh",
                   args: ["-c", "#{docker_cli} context inspect rootless >/dev/null 2>&1 || #{context_create_cmd}"]
    system_command docker_cli, args: ["context", "use", "rootless"]
  end

  # Does not seem work...
  zap trash: "~/.config/systemd/user/dockerd-rootless.service"

  caveats <<~EOS
    Use 'dockerd-rootless --iptables=false' to start

    To enable and start the systemd service:
      systemctl --user daemon-reload
      systemctl --user enable --now dockerd-rootless

    A "rootless" docker context has been created and selected.
    To switch back to the default context:
      docker context use default
  EOS
end
