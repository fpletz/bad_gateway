{
  description = "Bad Gateway";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
      eachNginx = nixpkgs.lib.genAttrs [
        "nginxQuic"
        "nginxStable"
        "nginxMainline"
      ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
    in
    {
      packages = eachSystem (system: eachNginx (nginxAttr: (pkgsFor system).${nginxAttr}));

      overlays.default = _final: prev:
        eachNginx (nginxAttr:
          prev.${nginxAttr}.overrideAttrs (attrs: {
            patches = attrs.patches ++ [ ./patches/bad_gateway_nginx_1.25.4.patch ];
          })
        );
    };
}
