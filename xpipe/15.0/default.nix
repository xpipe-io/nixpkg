{ stdenvNoCC
, lib
, fetchzip
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
, hicolor-icon-theme
}:

let
  inherit (stdenvNoCC.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  arch = {
    x86_64-linux = "x86_64";
    aarch64-linux = "arm64";
  }.${system} or throwSystem;

  hash = {
    x86_64-linux = "sha256-lkckMr4s/YabNNAhIgl33HGO7tqhan00OhpnSynR/ro=";
    aarch64-linux = "sha256-n+mB8JAUSqhL5UVhKbvgGVKw37Wnm5SoBV87L5qHSgY=";
  }.${system} or throwSystem;

  displayname = "XPipe";

in stdenvNoCC.mkDerivation rec {
  pname = "xpipe";
  version = "15.0";

  src = fetchzip {
    url = "https://github.com/xpipe-io/${pname}/releases/download/${version}/xpipe-portable-linux-${arch}.tar.gz";
    inherit hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeShellWrapper
  ];

  # Ignore libavformat dependencies as we don't need them
  autoPatchelfIgnoreMissingDeps = true;

  buildInputs = [
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
      hicolor-icon-theme
    ];

  desktopItem = makeDesktopItem {
    categories = [ "Network" ];
    comment = "Your entire server infrastructure at your fingertips";
    desktopName = displayname;
    exec = "/opt/${pname}/bin/xpipe open %U";
    genericName = "Shell connection hub";
    icon = "/opt/${pname}/logo.png";
    name = displayname;
  };

  installPhase = ''
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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig gtk3 udev ]}"
    makeShellWrapper "$out/opt/$pkg/scripts/xpiped_debug_raw.sh" "$out/opt/$pkg/scripts/xpiped_debug.sh" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig gtk3 udev ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Your entire server infrastructure at your fingertips";
    homepage = "https://github.com/xpipe-io/${pname}";
    downloadPage = "https://github.com/xpipe-io/${pname}/releases/latest";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    changelog = "https://github.com/xpipe-io/${pname}/releases/tag/${version}";
    license = [ licenses.asl20 licenses.unfree ];
    maintainers = with maintainers; [ crschnick ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = pname;
  };
}
