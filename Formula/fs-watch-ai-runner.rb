class FsWatchAiRunner < Formula
  desc "Daemon that watches directories and runs programs or Claude Code on file events"
  homepage "https://github.com/zebroc/fs-watch-ai-runner"
  # The repository is private: fetch over SSH so the user's GitHub key is used.
  url "git@github.com:zebroc/fs-watch-ai-runner.git",
      using:    :git,
      tag:      "v0.1.0",
      revision: "c816ee10b7fbb6db4af52379f191f2e28c322ad2"
  head "git@github.com:zebroc/fs-watch-ai-runner.git", using: :git, branch: "main"

  depends_on "go" => :build
  depends_on "tmux"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
    pkgshare.install "config.example.yaml"
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"fs-watch-ai-runner", "-config", "#{Dir.home}/.config/fs-watch-ai-runner/config.yaml"]
    keep_alive true
    working_dir Dir.home
    # launchd provides only a minimal environment; claude and tmux must be found.
    environment_variables HOME: Dir.home, PATH: "#{HOMEBREW_PREFIX}/bin:/usr/local/bin:/usr/bin:/bin"
    log_path var/"log/fs-watch-ai-runner.log"
    error_log_path var/"log/fs-watch-ai-runner.log"
  end

  def caveats
    <<~EOS
      Create a configuration from the example and check it:

        mkdir -p ~/.config/fs-watch-ai-runner
        cp #{opt_pkgshare}/config.example.yaml ~/.config/fs-watch-ai-runner/config.yaml
        fs-watch-ai-runner -config ~/.config/fs-watch-ai-runner/config.yaml -check

      Then start the daemon:

        brew services start fs-watch-ai-runner

      Logs: #{var}/log/fs-watch-ai-runner.log
    EOS
  end

  test do
    (testpath/"watched").mkpath
    (testpath/"config.yaml").write <<~YAML
      directories:
        - path: #{testpath}/watched
          actions:
            - name: echo
              on: [create]
              run: ["echo", "{path}"]
    YAML
    assert_match "valid", shell_output("#{bin}/fs-watch-ai-runner -config #{testpath}/config.yaml -check 2>&1")

    (testpath/"bad.yaml").write "directories: []\n"
    assert_match "no directories", shell_output("#{bin}/fs-watch-ai-runner -config #{testpath}/bad.yaml -check 2>&1", 1)
  end
end
