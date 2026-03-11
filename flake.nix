# TODO: for packages username shouldn't be hardcoded / sourced
{
    outputs = { self, nixpkgs, ... }@inputs:
        let
            system = "x86_64-linux";
        in {
            nixosConfigurations = {
                # TODO: enumerate ./host instead
                mistylake = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit inputs system; };
                    modules = [
                        inputs.nur.modules.nixos.default
                        inputs.impermanence.nixosModules.impermanence
                        inputs.home-manager.nixosModules.home-manager
                        ./common.nix
                        ./host/mistylake/configuration.nix
                        ((import ./users/user/default.nix) {
                            persist_path = "/persist"; # TODO: this should be provided by the host
                            username = "user";
                        })
                    ];
                };
            };
        };
    #/outputs

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
        nur = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        impermanence = {
            url = "github:nix-community/impermanence";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        wrappers = {
            url = "github:lassulus/wrappers";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        jail-nix = { # bwrap utility
            url = "sourcehut:~alexdavid/jail.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nvf = { # neovim
            url = "github:notashelf/nvf";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixpak = { # bwrap utility
            url = "github:nixpak/nixpak";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        #nixwrap = {
        #    url = "github:rti/nixwrap";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
        #stylix = {
        #    url = "github:nix-community/stylix";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
    };
}
