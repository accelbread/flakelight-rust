# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ stdenv
, rustPlatform
, rustc
, miri
, makeWrapper
}:
let
  target = stdenv.hostPlatform.rust.rustcTarget;
in
rustPlatform.buildRustPackage {
  pname = "cargo-miri";
  inherit (rustc) version src;
  sourceRoot = "rustc-${rustc.version}-src/src/tools/miri/cargo-miri";
  cargoVendorDir = "../../../../vendor";
  RUSTC_BOOTSTRAP = "1";
  nativeBuildInputs = [ makeWrapper ];
  outputs = [ "out" "sysroot" ];
  postBuild = ''
    export MIRI="${miri}/bin/miri"
    export MIRI_LIB_SRC="${rustPlatform.rustcSrc}/library"
    export MIRI_SYSROOT=$sysroot
    ../../../../target/${target}/release/cargo-miri miri setup
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ../../../../target/${target}/release/cargo-miri $out/bin
    wrapProgram $out/bin/cargo-miri \
      --set-default MIRI "$MIRI" \
      --set-default MIRI_LIB_SRC "$MIRI_LIB_SRC" \
      --set-default MIRI_SYSROOT "$MIRI_SYSROOT"
  '';
}
