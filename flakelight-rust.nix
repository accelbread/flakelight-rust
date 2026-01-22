# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{ lib, src, config, flakelight, inputs, ... }:
let
  inherit (builtins) elem isBool readFile pathExists;
  inherit (lib) mkDefault mkEnableOption mkIf mkMerge mkOption optionalAttrs
    warnIf;
  inherit (lib.fileset) fileFilter maybeMissing toSource unions;
  inherit (flakelight.types) fileset;

  cargoToml = fromTOML (readFile (src + /Cargo.toml));
  tomlPackage = cargoToml.package or cargoToml.workspace.package or { };

  readme =
    if tomlPackage ? readme then
      if isBool tomlPackage.readme then
        if tomlPackage.readme then "README.md" else null
      else tomlPackage.readme
    else
      if (pathExists (src + /README.md)) then "README.md"
      else if (pathExists (src + /README.txt)) then "README.txt"
      else if (pathExists (src + /README)) then "README"
      else null;

  env = optionalAttrs config.rust.enable_unstable {
    RUSTC_BOOTSTRAP = "1";
  };
in
warnIf (! builtins ? readFileType) "Unsupported Nix version in use."
{
  options = {
    fileset = mkOption {
      type = fileset;
      default = unions [
        (fileFilter (file: file.hasExt "rs" || file.name == "Cargo.toml") src)
        (src + /Cargo.lock)
        (maybeMissing (src + /.cargo/config.toml))
      ];
    };

    rust = {
      enable_unstable = mkEnableOption
        "using unstable features with stable compiler";
      enable_miri = mkEnableOption
        "using cargo-miri";
    };
  };

  config = mkMerge [
    (mkIf (pathExists (src + /Cargo.toml)) {
      withOverlays = [ config.inputs.naersk.overlays.default ];

      description = mkIf (tomlPackage ? description) tomlPackage.description;

      # license will need to be set if Cargo license is a complex expression
      license = mkIf (tomlPackage ? license) (mkDefault tomlPackage.license);

      pname = tomlPackage.name or (mkDefault "cargo-workspace");

      package = { naersk, defaultMeta }:
        naersk.buildPackage {
          src = toSource { root = src; inherit (config) fileset; };
          inherit env;
          strictDeps = true;
          meta = defaultMeta;
        };

      checks = { naersk, ... }: {
        test = naersk.buildPackage {
          mode = "test";
          name = "test-${config.pname}";
          src = toSource { root = src; inherit (config) fileset; };
          inherit env;
          strictDeps = true;
        };
        clippy = naersk.buildPackage {
          mode = "clippy";
          name = "clippy-${config.pname}";
          src = toSource {
            root = src;
            fileset =
              if readme == null then config.fileset
              else unions [ config.fileset (src + "/${readme}") ];
          };
          cargoBuildOptions = default: default ++ [ "--all-targets" ];
          inherit env;
          strictDeps = true;
        };
      };
    })

    (mkIf ((pathExists (src + /Cargo.toml) && config.rust.enable_miri)) {
      checks = { naersk, cargo-miri, ... }: {
        miri-test = naersk.buildPackage {
          mode = "test";
          name = "miri-test-${config.pname}";
          src = toSource { root = src; inherit (config) fileset; };
          inherit env;
          strictDeps = true;
          overrideMain = old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [ cargo-miri ];
            preBuild = ''
              cargo_options="miri $cargo_options"
            '';
          };
        };
      };
    })

    {
      devShell = {
        packages = pkgs: with pkgs; [
          rust-analyzer-unwrapped
          cargo
          clippy
          rustc
          rustfmt
        ];

        env = { rustPlatform, ... }: env // {
          RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
        };
      };

      formatters = pkgs: {
        "*.rs" = "${pkgs.rustfmt}/bin/rustfmt";
      };
    }

    (mkIf config.rust.enable_miri {
      withOverlays = [ inputs.flakelight-rust.overlays.default ];
      devShell.packages = pkgs: [ pkgs.cargo-miri ];
    })
  ];
}
