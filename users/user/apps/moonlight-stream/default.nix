{ username, persist_path, ... }: { inputs, pkgs, ... }: let
    jail = inputs.jail-nix.lib.init pkgs;
in {
    home-manager.users.${username} = {

        home.persistence."${persist_path}".directories = [ ".emulated-root/moonlight-stream/home/${username}" ];

        xdg.desktopEntries.moonlight-qt = {
            name = "Moonlight Stream";
            exec = "moonlight";
            icon = "${pkgs.moonlight-qt}/share/icons/hicolor/scalable/apps/moonlight.svg";
            terminal = false;
            categories = [ "Game" "Network" ];
        };

        home.packages = [
            (jail "moonlight" pkgs.moonlight-qt (with jail.combinators; [
                network
                gui
                gpu
                (rw-bind (noescape "~/.emulated-root/moonlight-stream/home/${username}") (noescape "~/"))
            ]))
        ];
    };
}
