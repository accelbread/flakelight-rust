# flakelight-rust

Rust module for [flakelight][1].

[1]: https://github.com/accelbread/flakelight

## Configured options

Sets `package` to the crate at the flake source. `description` and `licence` is
set from `Cargo.toml`.

Adds `rust-analyzer`, `cargo`, `clippy`, `rustc`, and `rustfmt` to the default
devShell and sets `RUST_SRC_PATH`.

Adds checks for crate tests and clippy warnings.

Configures `rs` files to be formatted with `rustfmt`.

## Example flake

```nix
{
  inputs = {
    flakelight.url = "github:accelbread/flakelight";
    flakelight-rust.url = "github:accelbread/flakelight-rust";
  };
  outputs = { flakelight, flakelight-rust, ... }: flakelight ./. {
    imports = [ flakelight-rust.flakelightModules.default ];
  };
}
```
