# flakelight-rust

Rust module for [flakelight][1].

Initializes a Rust project flake from its `Cargo.toml`.

[1]: https://github.com/nix-community/flakelight

## Configured options

Sets `package` to the crate at the flake source. `description` and `licence` is
set from `Cargo.toml`.

Adds `rust-analyzer`, `cargo`, `clippy`, `rustc`, and `rustfmt` to the default
devShell and sets `RUST_SRC_PATH`.

Adds checks for crate tests and clippy warnings.

Configures `rs` files to be formatted with `rustfmt`.

## Options

`fileset` configures the fileset the package is built with. To use all files,
set it to `./.`;

## Getting started

To create a new project in an empty directory, run the following:

```
nix flake init -t github:accelbread/flakelight-rust
```

Existing projects can use one of the example `flake.nix` files below.

## Example flake

You can call this flake directly:

```nix
{
  inputs.flakelight-rust.url = "github:accelbread/flakelight-rust";
  outputs = { flakelight-rust, ... }: flakelight-rust ./. { };
}
```

Alternatively, add this module to your Flakelight config:

```nix
{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    flakelight-rust.url = "github:accelbread/flakelight-rust";
  };
  outputs = { flakelight, flakelight-rust, ... }: flakelight ./. {
    imports = [ flakelight-rust.flakelightModules.default ];
  };
}
```
