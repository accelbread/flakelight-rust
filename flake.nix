# flakelite-rust -- Rust module for flakelite
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  inputs = {
    flakelite.url = "github:accelbread/flakelite";
    crane.url = "github:ipetkov/crane";
  };
  outputs = { flakelite, crane, ... }: flakelite ./. {
    outputs.flakeliteModules.default = { lib, ... }: {
      # ensure error messages have useful filename
      imports = [ ./flakelite-rust.nix ];
      inputs.crane = lib.mkDefault crane;
    };
  };
}
