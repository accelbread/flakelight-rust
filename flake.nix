# flakelite-rust -- Rust module for flakelite
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

{
  inputs = {
    flakelite.url = "github:accelbread/flakelite";
    crane.url = "github:ipetkov/crane";
  };
  outputs = { flakelite, ... }@inputs:
    flakelite.lib.mkFlake ./. inputs {
      outputs.flakeliteModule = import ./. inputs;
    };
}
