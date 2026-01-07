# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  description = "Rust module for flakelite";
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    naersk.url = "github:nix-community/naersk";
  };
  outputs = { flakelight, naersk, ... }: flakelight ./. {
    imports = [ flakelight.flakelightModules.extendFlakelight ];
    nixDir = ./.;
    flakelightModule = { lib, ... }: {
      imports = [ ./flakelight-rust.nix ];
      inputs.naersk = lib.mkDefault naersk;
    };
  };
}
