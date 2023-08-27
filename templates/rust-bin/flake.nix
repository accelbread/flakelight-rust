{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flakelight.url = "github:accelbread/flakelight";
    flakelight-rust.url = "github:accelbread/flakelight-rust";
  };
  outputs = { flakelight, flakelight-rust, ... }@inputs: flakelight ./. {
    imports = [ flakelight-rust.flakelightModules.default ];
    inherit inputs;
  };
}
