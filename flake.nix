# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  description = "Rust module for flakelite";
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "flakelight/nixpkgs";
    };
  };
  outputs = { flakelight, crane, ... }: flakelight ./. {
    imports = [ flakelight.flakelightModules.flakelightModule ];
    flakelightModule = { lib, ... }: {
      imports = [ ./flakelight-rust.nix ];
      inputs.crane = lib.mkDefault crane;
    };
  };
}
