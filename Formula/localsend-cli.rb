class LocalsendCli < Formula
  desc "CLI server & client for localsend in go"
  homepage "https://github.com/zebroc/localsend-cli"
  url "https://github.com/zebroc/localsend-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "093596a1c9316e15691eee167d4cd14e2dae5858b65492ab60133be464ee3d87"
  head "https://github.com/zebroc/localsend-cli.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}")
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"localsend-cli", "--daemon", "--dstdir", "#{Dir.home}/Downloads"]
    keep_alive true
    working_dir Dir.home
    # The configuration directory (certificate, alias, peer cache) is derived
    # from HOME, which launchd does not always provide.
    environment_variables HOME: Dir.home
    log_path var/"log/localsend-cli.log"
    error_log_path var/"log/localsend-cli.log"
  end

  def caveats
    <<~EOS
      The daemon accepts every incoming transfer and stores it in ~/Downloads:

        brew services start localsend-cli

      Only one LocalSend instance can hold port 53317, so quit the official
      LocalSend app before starting the service. Logs:

        #{var}/log/localsend-cli.log
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/localsend-cli --version")

    # Sending without any path must fail with guidance instead of reaching the
    # network, which keeps this test offline.
    output = shell_output("#{bin}/localsend-cli somedevice 2>&1", 1)
    assert_match "no files given", output
  end
end
