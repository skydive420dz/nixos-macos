{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  libsForQt5,
  writeText,
  vialSrc,
}:

let
  version = "0.7.5";

  pythonEnv = python3.withPackages (
    ps: with ps; [
      certifi
      hidapi
      pyqt5
      simpleeval
    ]
  );

  qtPluginPath = "${lib.getBin libsForQt5.qtbase}/${libsForQt5.qtbase.qtPluginPrefix}";

  infoPlist = writeText "Vial-Info.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDevelopmentRegion</key>
      <string>English</string>
      <key>CFBundleDisplayName</key>
      <string>Vial</string>
      <key>CFBundleExecutable</key>
      <string>Vial</string>
      <key>CFBundleIdentifier</key>
      <string>today.vial.nix</string>
      <key>CFBundleInfoDictionaryVersion</key>
      <string>6.0</string>
      <key>CFBundleName</key>
      <string>Vial</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleShortVersionString</key>
      <string>${version}</string>
      <key>CFBundleVersion</key>
      <string>${version}</string>
      <key>LSMinimumSystemVersion</key>
      <string>11.0</string>
      <key>NSHighResolutionCapable</key>
      <true/>
      <key>NSPrincipalClass</key>
      <string>NSApplication</string>
    </dict>
    </plist>
  '';

  smokeTest = writeText "vial-gui-smoke.py" ''
    from pathlib import Path
    import platform

    import hid
    import main

    context = main.VialApplicationContext()
    resource = Path(context.get_resource("qmk_settings.json"))
    assert resource.is_file(), resource

    devices = hid.enumerate()
    print(
        "Vial GUI smoke test passed:",
        f"machine={platform.machine()}",
        f"qt_platform={context.app.platformName()}",
        f"hid_devices={len(devices)}",
        f"resource={resource}",
    )
    context.app.quit()
  '';
in
stdenvNoCC.mkDerivation {
  pname = "vial";
  inherit version;

  src = vialSrc;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    sourceRoot="$out/share/vial/source"
    shimRoot="$out/share/vial/runtime-shim"
    appRoot="$out/Applications/Vial.app"

    mkdir -p \
      "$sourceRoot" \
      "$shimRoot" \
      "$appRoot/Contents/MacOS" \
      "$appRoot/Contents/Resources" \
      "$out/bin"

    cp -R . "$sourceRoot/"
    cp -R ${./vial-runtime-shim}/. "$shimRoot/"
    install -m 444 ${infoPlist} "$appRoot/Contents/Info.plist"

    makeWrapper ${pythonEnv}/bin/python "$appRoot/Contents/MacOS/Vial" \
      --chdir "$sourceRoot" \
      --prefix PYTHONPATH : "$shimRoot:$sourceRoot/src/main/python" \
      --set QT_PLUGIN_PATH "${qtPluginPath}" \
      --set VIAL_SOURCE_ROOT "$sourceRoot" \
      --add-flags "$sourceRoot/src/main/python/main.py"

    makeWrapper ${pythonEnv}/bin/python "$out/bin/vial-smoke-test" \
      --chdir "$sourceRoot" \
      --prefix PYTHONPATH : "$shimRoot:$sourceRoot/src/main/python" \
      --set QT_PLUGIN_PATH "${qtPluginPath}" \
      --set VIAL_SOURCE_ROOT "$sourceRoot" \
      --add-flags ${smokeTest}

    ln -s ../Applications/Vial.app/Contents/MacOS/Vial "$out/bin/vial"

    runHook postInstall
  '';

  meta = {
    description = "Open-source GUI for configuring Vial keyboards";
    homepage = "https://get.vial.today";
    license = lib.licenses.gpl2Plus;
    mainProgram = "vial";
    platforms = [ "aarch64-darwin" ];
  };
}
