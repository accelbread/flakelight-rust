# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ lib, src, config, flakelight, ... }:
let
  inherit (builtins) elem readFile pathExists;
  inherit (lib) mkDefault mkIf mkMerge mkOption warnIf;
  inherit (lib.fileset) fileFilter toSource;
  inherit (flakelight.types) fileset;

  cargoToml = fromTOML (readFile (src + /Cargo.toml));
  tomlPackage = cargoToml.package or cargoToml.workspace.package;
in
warnIf (! builtins ? readFileType) "Unsupported Nix version in use."
{
  options.fileset = mkOption {
    type = fileset;
    default = fileFilter
      (file: file.hasExt "rs" || elem file.name [ "Cargo.toml" "Cargo.lock" ])
      src;
  };

  config = mkMerge [
    (mkIf (pathExists (src + /Cargo.toml)) {
      withOverlays = final: { inputs, ... }: rec {
        craneLib = inputs.crane.mkLib final;
        cargoArtifacts = craneLib.buildDepsOnly
          { inherit src; strictDeps = true; };
      };

      description = mkIf (tomlPackage ? description) tomlPackage.description;

      # license will need to be set if Cargo license is a complex expression
      license = mkIf (tomlPackage ? license) (mkDefault tomlPackage.license);

      pname = tomlPackage.name;

      package = { craneLib, cargoArtifacts, defaultMeta }:
        craneLib.buildPackage {
          src = toSource { root = src; inherit (config) fileset; };
          inherit cargoArtifacts;
          doCheck = false;
          strictDeps = true;
          meta = defaultMeta;
        };

      checks = { craneLib, cargoArtifacts, ... }: {
        test = craneLib.cargoTest { inherit src cargoArtifacts; };
        clippy = craneLib.cargoClippy {
          inherit src cargoArtifacts;
          strictDeps = true;
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        };
      };
    })

    {
      devShell = {
        packages = pkgs: with pkgs; [ rust-analyzer cargo clippy rustc rustfmt ];

        env = { rustPlatform, ... }: {
          RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
        };
      };

      formatters = pkgs: {
        "*.rs" = "${pkgs.rustfmt}/bin/rustfmt";
      };
    }
  ];
}
