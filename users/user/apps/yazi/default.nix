{ username, ... }: { ... }: {
    home-manager.users.${username}.programs.yazi = {
        enable = true;
        settings = {
            mgr = {
                show_hidden = true;
            };
        };
    };
}
