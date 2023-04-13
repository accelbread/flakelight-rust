# flakelite-rust -- Rust module for flakelite
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

defaultInputs: src: inputs: root:
let
  inputs' = defaultInputs // inputs;
  cargoToml = builtins.fromTOML (builtins.readFile (src + "/Cargo.toml"));
in
{
  withOverlay = final: prev: {
    craneLib = inputs'.crane.lib.${prev.system};
    cargoArtifacts = final.craneLib.buildDepsOnly { inherit src; };
  };
  package = { lib, craneLib, cargoArtifacts, flakelite }:
    craneLib.buildPackage {
      inherit src cargoArtifacts;
      doCheck = false;
      meta = flakelite.meta // {
        inherit (cargoToml.package) description;
      } // (lib.optionalAttrs (! flakelite.meta ? license) {
        license = lib.meta.getLicenseFromSpdxId cargoToml.package.license;
      });
    };
  devTools = pkgs: with pkgs; [ rust-analyzer rustc rustfmt ];
  env = { rustPlatform, ... }: {
    RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
  };
  checks = { craneLib, cargoArtifacts, ... }: {
    test = craneLib.cargoTest {
      inherit src cargoArtifacts;
    };
    clippy = craneLib.cargoClippy {
      inherit src cargoArtifacts;
      cargoClippyExtraArgs = "--all-targets -- --deny warnings";
    };
  };
  formatters = {
    "*.rs" = "rustfmt";
  };
}
