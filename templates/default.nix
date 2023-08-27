# flakelight-rust -- Rust module for flakelight
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: MIT

rec {
  default = rust-bin;
  rust-bin = {
    path = ./rust-bin;
    description = "Template Rust application.";
    welcomeText = ''
      # Flakelight Rust template
      Update the placeholders in `Cargo.toml`!
    '';
  };
}
