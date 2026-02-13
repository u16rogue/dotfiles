{ username, ... }: { ... }: {
    programs.fish.enable = true;
    home-manager.users.${username}.programs.fish = {
        enable = true;
        interactiveShellInit = builtins.readFile ./config.fish;
    };
}
