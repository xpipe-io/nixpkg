{ stdenvNoCC
, lib
, fetchurl
, makeDesktopItem
, autoPatchelfHook
, zlib
, fontconfig
, udev
, gtk3
, freetype
, alsa-lib
, makeShellWrapper
, libX11
, libXext
, libXdamage
, libXfixes
, libxcb
, libXcomposite
, libXcursor
, libXi
, libXrender
, libXtst
, libXxf86vm
, util-linux
, socat
, xdg-utils
, hicolor-icon-theme
, undmg
, darwin
}:

let
  inherit (stdenvNoCC.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix = {
    x86_64-linux = "linux-x86_64.tar.gz";
    aarch64-linux = "linux-arm64.tar.gz";
    x86_64-darwin = "macos-x86_64.dmg";
    aarch64-darwin = "macos-arm64.dmg";
  }.${system} or throwSystem;

  hash = {
    x86_64-linux = "sha256-7GAouZyO6HlsrSf9AjTi5I4OE6F1D5iuT8nrryUdUDc=";
    aarch64-linux = "";
    x86_64-darwin = "";
    aarch64-darwin = "sha256-uS5xb+VmkeNeecVjE+XU4EfN4BceXwMLDxeC88mBzmE=";
  }.${system} or throwSystem;

  displayname = "XPipe PTB";

in stdenvNoCC.mkDerivation rec {
  pname = "xpipe-ptb";
  version = "21.4-2";

  src = fetchurl {
    url = "https://github.com/xpipe-io/${pname}/releases/download/${version}/xpipe-portable-${suffix}";
    inherit hash;
  };

  sourceRoot = lib.optional stdenvNoCC.hostPlatform.isDarwin "${displayname}.app";

  nativeBuildInputs = [
    makeShellWrapper
  ]
  ++ lib.optionals (!stdenvNoCC.hostPlatform.isDarwin) [
    autoPatchelfHook
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    undmg
    darwin.autoSignDarwinBinariesHook
  ];

  dontConfigure = true;
  dontBuild = true;

  # Ignore libavformat dependencies as we don't need them
  autoPatchelfIgnoreMissingDeps = true;

  buildInputs = []
  ++ lib.optionals (!stdenvNoCC.hostPlatform.isDarwin) [
      fontconfig
      zlib
      udev
      freetype
      gtk3
      alsa-lib
      libX11
      libX11
      libXext
      libXdamage
      libXfixes
      libxcb
      libXcomposite
      libXcursor
      libXi
      libXrender
      libXtst
      libXxf86vm
      util-linux
      socat
      xdg-utils
      hicolor-icon-theme
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
  ];

  desktopItem = makeDesktopItem {
    categories = [ "Network" ];
    comment = "XPipe Public Test Build releases";
    desktopName = displayname;
    exec = "/opt/${pname}/bin/xpipe open %U";
    genericName = "Shell connection hub";
    icon = "/opt/${pname}/logo.png";
    name = displayname;
  };

  installPhase =
    if !stdenvNoCC.hostPlatform.isDarwin then
    ''
    runHook preInstall

    pkg="${pname}"
    mkdir -p $out/opt/$pkg
    cp -r ./ $out/opt/$pkg

    mkdir -p "$out/bin"
    ln -s "$out/opt/$pkg/bin/xpipe" "$out/bin/$pkg"

    mkdir -p "$out/share/applications"
    cp -r "${desktopItem}/share/applications/" "$out/share/"

    substituteInPlace "$out/share/applications/${displayname}.desktop" --replace "Exec=" "Exec=$out"
    substituteInPlace "$out/share/applications/${displayname}.desktop" --replace "Icon=" "Icon=$out"

    mv "$out/opt/$pkg/bin/xpiped" "$out/opt/$pkg/bin/xpiped_raw"
    mv "$out/opt/$pkg/lib/app/xpiped.cfg" "$out/opt/$pkg/lib/app/xpiped_raw.cfg"
    mv "$out/opt/$pkg/scripts/xpiped_debug.sh" "$out/opt/$pkg/scripts/xpiped_debug_raw.sh"

    makeShellWrapper "$out/opt/$pkg/bin/xpiped_raw" "$out/opt/$pkg/bin/xpiped" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig gtk3 udev util-linux socat xdg-utils ]}"
    makeShellWrapper "$out/opt/$pkg/scripts/xpiped_debug_raw.sh" "$out/opt/$pkg/scripts/xpiped_debug.sh" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig gtk3 udev util-linux socat xdg-utils ]}"

    runHook postInstall
  ''
  else
  ''
    runHook preInstall

    mkdir -p "$out/Applications/${displayname}.app"
    cp -R . "$out/Applications/${displayname}.app"
    mkdir -p "$out/bin"
    ln -s "$out/Applications/${displayname}.app/Contents/MacOS/xpipe" "$out/bin/${pname}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "XPipe Public Test Build releases";
    homepage = "https://github.com/xpipe-io/${pname}";
    downloadPage = "https://github.com/xpipe-io/${pname}/releases/latest";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    changelog = "https://github.com/xpipe-io/${pname}/releases/tag/${version}";
    license = [ licenses.asl20 licenses.unfree ];
    maintainers = with maintainers; [ crschnick ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = pname;
  };
}
