# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  inputs = {
    flakelight.url = "github:accelbread/flakelight";
    crane.url = "github:ipetkov/crane";
  };
  outputs = { flakelight, crane, ... }: flakelight ./. {
    flakelightModule = { lib, ... }: {
      imports = [ ./flakelight-rust.nix ];
      inputs.crane = lib.mkDefault crane;
    };
    templates = import ./templates;
  };
}
