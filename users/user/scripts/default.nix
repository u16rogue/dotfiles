{ pkgs, ... }: [
    (import ./mkignore/package.nix { inherit pkgs; })
    (import ./nix-develop/package.nix { inherit pkgs; })
    (import ./nix-pkgvercmp/package.nix { inherit pkgs; })
    (import ./tmuxss/package.nix { inherit pkgs; })

    (pkgs.writeShellScriptBin "git-macs" /*bash*/ ''
        ${pkgs.git}/bin/git add . && ${pkgs.git}/bin/git commit -S -m "$1"
    '')

    # Ammend previous unsigned commit to signed
    (pkgs.writeShellScriptBin "git-cans" /*bash*/ ''
        ${pkgs.git}/bin/git commit --amend --no-edit -S
    '')

    # === doesn't work ===
    ## Nix flake devshell pins - list pinned devshells
    #(pkgs.writeShellScriptBin "nixfds-pins" /*bash*/ ''
    #    ${pkgs.coreutils}/bin/ls -la /nix/var/nix/gcroots/auto | ${pkgs.coreutils}/bin/grep "projects"
    #'')

    ## Nix flake devshell pin - pin current devshell
    #(pkgs.writeShellScriptBin "nfds-pin" /*bash*/ ''
    #    ${pkgs.nix}/bin/nix develop --profile .nix-gc-root
    #'')
    # === doesn't work ===
]
