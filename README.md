# zebroc/homebrew-tap

Homebrew formulae for my own tools.

```sh
brew tap zebroc/tap
```

## Formulae

| Formula | Description |
| --- | --- |
| [`localsend-cli`](Formula/localsend-cli.rb) | [CLI server & client for localsend in go](https://github.com/zebroc/localsend-cli) |
| [`fs-watch-ai-runner`](Formula/fs-watch-ai-runner.rb) | Daemon that watches directories and runs programs or Claude Code on file events (private repo, installs via SSH) |

```sh
brew install localsend-cli
brew services start localsend-cli    # accept incoming transfers into ~/Downloads
```

## Updating a formula after a release

```sh
version=0.2.0
url="https://github.com/zebroc/localsend-cli/archive/refs/tags/v${version}.tar.gz"
shasum -a 256 <(curl -sL "$url")
# then edit url + sha256 in Formula/localsend-cli.rb and commit
```
