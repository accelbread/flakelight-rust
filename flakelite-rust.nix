# flakelite-rust -- Rust module for flakelite
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ lib, src, ... }:
let
  inherit (builtins) readFile;
  inherit (lib) mkDefault;

  cargoToml = fromTOML (readFile (src + /Cargo.toml));
in
{
  withOverlays = _: { inputs', ... }: rec {
    craneLib = inputs'.crane.lib;
    cargoArtifacts = craneLib.buildDepsOnly { inherit src; };
  };

  description = cargoToml.package.description;

  # license will need to be set if Cargo license is a complex expression
  license = mkDefault cargoToml.package.license;

  package = { craneLib, cargoArtifacts, defaultMeta }:
    craneLib.buildPackage {
      inherit src cargoArtifacts;
      doCheck = false;
      meta = defaultMeta;
    };

  devShell = {
    packages = pkgs: with pkgs; [ rust-analyzer cargo clippy rustc rustfmt ];

    env = { rustPlatform, ... }: {
      RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
    };
  };

  checks = { craneLib, cargoArtifacts, ... }: {
    test = craneLib.cargoTest { inherit src cargoArtifacts; };
    clippy = craneLib.cargoClippy {
      inherit src cargoArtifacts;
      cargoClippyExtraArgs = "--all-targets -- --deny warnings";
    };
  };

  formatters."*.rs" = "rustfmt";
}
