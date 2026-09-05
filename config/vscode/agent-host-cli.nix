{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  vscode,
  release,
}:
assert vscode.version == release.app.version;
rustPlatform.buildRustPackage {
  pname = "vscode-agent-host-cli";
  version = release.app.version;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode";
    rev = release.app.commit;
    hash = "sha256-Y6FRttdpn353w/ykJbaE+NjM1NfXQewl9Fgux7m10lk=";
  };
  cargoRoot = "cli";
  buildAndTestSubdir = "cli";
  cargoHash = "sha256-qqjUNP+vpBy+WpInilo2RLbGlhq+pueeyxoNIjOVqao=";
  patches = [ ./agent-host-pin.patch ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    zlib
  ];
  # Keep Microsoft's stable identity, endpoint registry, and token handling.
  VSCODE_CLI_PRODUCT_JSON = "${vscode}/lib/vscode/resources/app/product.json";

  cargoTestFlags = [ "coordinated_" ];
  postInstall = ''
    mv "$out/bin/code" "$out/bin/vscode-agent-host-cli"
    "$out/bin/vscode-agent-host-cli" --version | grep -F '${release.app.commit}'
    "$out/bin/vscode-agent-host-cli" agent host --help > /dev/null
    if "$out/bin/vscode-agent-host-cli" command-shell >guard.log 2>&1; then
      echo "Agent-only CLI accepted command-shell" >&2
      exit 1
    fi
    grep -F 'remote.SSH.useExecServer=false' guard.log
  '';

  meta = {
    description = "VS Code CLI with Agent Host pinned to its application build";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "vscode-agent-host-cli";
  };
}
