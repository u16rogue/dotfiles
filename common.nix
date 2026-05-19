{ ... }: {
    nix.settings = {
        experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
        extra-experimental-features = [ "pipe-operators" ];
    };
    nixpkgs.config.allowUnfree = true;
    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
    };
    programs.vim.enable = true;
    users.mutableUsers = false;
}
