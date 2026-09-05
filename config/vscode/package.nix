{
  pkgs,
  release ? builtins.fromJSON (builtins.readFile ./release.json),
}:
let
  inherit (release) app;
  source = app.platforms.${pkgs.stdenv.hostPlatform.system};
in
pkgs.vscode.overrideAttrs (old: {
  inherit (app) version;
  src = pkgs.fetchurl source;
  passthru = old.passthru // {
    vscodeVersion = app.version;
    rev = app.commit;
    vscodeServer = pkgs.srcOnly {
      name = "vscode-server-${app.commit}.tar.gz";
      src = pkgs.fetchurl app.server;
      stdenv = pkgs.stdenvNoCC;
    };
  };
})
