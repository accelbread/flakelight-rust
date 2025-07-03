# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  description = "Rust module for flakelite";
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    crane.url = "github:ipetkov/crane";
  };
  outputs = { flakelight, crane, ... }: flakelight ./. {
    imports = [ flakelight.flakelightModules.extendFlakelight ];
    flakelightModule = { lib, ... }: {
      imports = [ ./flakelight-rust.nix ];
      inputs.crane = lib.mkDefault crane;
    };
    templates = import ./templates;
  };
}
