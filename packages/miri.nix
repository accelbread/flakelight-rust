# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ rustc
, rustPlatform
, llvm
, stdenvNoCC
}:
let
  target = stdenvNoCC.hostPlatform.rust.rustcTarget;
in
rustPlatform.buildRustPackage {
  pname = "miri";
  inherit (rustc) version src;
  sourceRoot = "rustc-${rustc.version}-src/src/tools/miri";
  cargoVendorDir = "../../../vendor";
  RUSTC_BOOTSTRAP = "1";
  buildInputs = [ llvm ];
  dontCargoCheck = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ../../../target/${target}/release/miri $out/bin
  '';
}
