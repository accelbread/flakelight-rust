# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ lib, src, config, flakelight, ... }:
let
  inherit (builtins) elem isBool readFile pathExists;
  inherit (lib) mkDefault mkIf mkMerge mkOption warnIf;
  inherit (lib.fileset) fileFilter toSource unions;
  inherit (flakelight.types) fileset;

  cargoToml = fromTOML (readFile (src + /Cargo.toml));
  tomlPackage = cargoToml.package or cargoToml.workspace.package;

  readme =
    if cargoToml ? readme then
      if isBool cargoToml.readme then
        if cargoToml.readme then "README.md" else null
      else cargoToml.readme
    else
      if (pathExists (src + /README.md)) then "README.md"
      else if (pathExists (src + /README.txt)) then "README.txt"
      else if (pathExists (src + /README)) then "README"
      else null;
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
      withOverlays = [ config.inputs.naersk.overlays.default ];

      description = mkIf (tomlPackage ? description) tomlPackage.description;

      # license will need to be set if Cargo license is a complex expression
      license = mkIf (tomlPackage ? license) (mkDefault tomlPackage.license);

      pname = tomlPackage.name;

      package = { naersk, defaultMeta }:
        naersk.buildPackage {
          src = toSource { root = src; inherit (config) fileset; };
          strictDeps = true;
          meta = defaultMeta;
        };

      checks = { naersk, ... }: {
        test = naersk.buildPackage {
          mode = "test";
          name = "test-${tomlPackage.name}";
          src = toSource { root = src; inherit (config) fileset; };
          strictDeps = true;
        };
        clippy = naersk.buildPackage {
          mode = "clippy";
          name = "clippy-${tomlPackage.name}";
          src = toSource {
            root = src;
            fileset =
              if readme == null then config.fileset
              else unions [ config.fileset (src + "/${readme}") ];
          };
          cargoBuildOptions = default: default ++ [ "--all-targets" ];
          strictDeps = true;
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
