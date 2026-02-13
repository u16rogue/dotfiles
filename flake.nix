#   user_entries
#|> builtins.attrNames
#|> builtins.filter (e: user_entries.${e} == "directory")
#|> builtins.map (p: ./users/${p}/default.nix)

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
                        # stylix.nixosModules.stylix
                        inputs.nur.modules.nixos.default
                        inputs.impermanence.nixosModules.impermanence
                        inputs.home-manager.nixosModules.home-manager
                        ./common.nix
                        ./host/mistylake/configuration.nix
                    ] ++ (
                        let
                            persist_path = "/persist"; # TODO: this should be provided by the host
                            users_dir = builtins.readDir ./users;
                            user_entries = nixpkgs.lib.pipe users_dir [
                                builtins.attrNames
                                (builtins.filter (e: users_dir.${e} == "directory"))
                                (builtins.map (username: {
                                    inherit username;
                                    inherit persist_path;
                                    module = import ./users/${username}/default.nix { inherit username persist_path inputs; };
                                }))
                            ];
                            result = []
                                ++ # base users (TODO: detect the hosts array inside if it should be enabled for this host)
                                builtins.map ({ username, ... }: {
                                    users.users.${username}.enable = true;
                                }) user_entries
                                ++ # home-manager
                                builtins.map ({ username, module, ... }: {
                                    home-manager.users.${username} = module.home-manager;
                                }) user_entries
                                ++ # nixos-system
                                builtins.map ({ module, ... }: module.nixos-system) user_entries
                            ;
                        in result
                    );
                };
            };
        };
    #/outputs

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "nixpkgs/nixos-25.11";
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
        jail-nix = { # bwrap utility
            url = "sourcehut:~alexdavid/jail.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nvf = { # neovim
            url = "github:notashelf/nvf";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        #nixpak = {
        #    url = "github:nixpak/nixpak";
        #    inputs.nixpkgs.follows = "nixpkgs";
        #};
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
