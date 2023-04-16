# flakelite-rust -- Rust module for flakelite
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

localInputs: { src }: {
  inputs = { inherit (localInputs) crane; };
  withOverlay = final: { flakelite, ... }: {
    craneLib = flakelite.inputs'.crane.lib;
    cargoToml = builtins.fromTOML (builtins.readFile (src + "/Cargo.toml"));
    cargoArtifacts = final.craneLib.buildDepsOnly { inherit src; };
  };
  package = { lib, craneLib, cargoToml, cargoArtifacts, flakelite }:
    craneLib.buildPackage {
      inherit src cargoArtifacts;
      doCheck = false;
      meta = flakelite.meta // {
        inherit (cargoToml.package) description;
      } // (lib.optionalAttrs (! flakelite.meta ? license) {
        # Root license will be needed if Cargo license is a complex expression
        license = lib.meta.getLicenseFromSpdxId cargoToml.package.license;
      });
    };
  devTools = pkgs: with pkgs; [ rust-analyzer cargo clippy rustc rustfmt ];
  env = { rustPlatform }: { RUST_SRC_PATH = "${rustPlatform.rustLibSrc}"; };
  checks = { craneLib, cargoArtifacts }: {
    test = craneLib.cargoTest { inherit src cargoArtifacts; };
    clippy = craneLib.cargoClippy {
      inherit src cargoArtifacts;
      cargoClippyExtraArgs = "--all-targets -- --deny warnings";
    };
  };
  formatters."*.rs" = "rustfmt";
}
