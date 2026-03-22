
# TODO: turn into a shell application instead (pkgs.writeShellApplication)

{ pkgs, ... }: let
    realpath = "${pkgs.coreutils}/bin/realpath";
    basename = "${pkgs.coreutils}/bin/basename";
    tmux = "${pkgs.tmux}/bin/tmux";
    git = "${pkgs.git}/bin/git";
    jq = "";
in [
    (pkgs.writeShellScriptBin "mkignore" (builtins.readFile ./mkignore))

    (pkgs.writeShellScriptBin "tmuxss" /*bash*/ ''
        if [ -z "$1" ]; then
            echo "Missing directory. Usage: $0 <directory>"
            exit 1
        fi
        
        SESSION_DIR=$(${realpath} "$1")
        if [ ! -d "$SESSION_DIR" ]; then
            echo "Invalid directory. Not found: $SESSION_DIR"
            exit 1
        fi
        
        SESSION_NAME=$(${basename} "$1")
        
        # Session
        if ! ${tmux} new-session -d -s "$SESSION_NAME" -A -c "$SESSION_DIR"; then
            echo "failed to create new session"
            exit 1
        fi

        if [[ -d "$SESSION_DIR/.devshells" ]]; then
            if ! ${tmux} send-keys -t "$SESSION_NAME" "nix-develop" C-m; then
                echo "failed to load dev env"
                exit 1
            fi
        fi

        exit 0
    '')

    (pkgs.writeShellScriptBin "git-macs" /*bash*/ ''
        ${pkgs.git}/bin/git add . && ${pkgs.git}/bin/git commit -S -m "$1"
    '')

    # Ammend previous unsigned commit to signed
    (pkgs.writeShellScriptBin "git-cans" /*bash*/ ''
        ${pkgs.git}/bin/git commit --amend --no-edit -S
    '')

    # nix flake package version compare
    (pkgs.writeShellScriptBin "nix-pkgvercmp" ''
        # Get nixos
        printf "nixos: "
        if command -v "nixos-version" &> /dev/null; then
            NIXOS_REV=$(nixos-version --json | ${pkgs.jq}/bin/jq -r '.nixpkgsRevision')
            if [[ -n "$NIXOS_REV" && "$NIXOS_REV" != "null" ]]; then
                echo "$NIXOS_REV"
            else
                echo "[error] invalid rev: '$NIXOS_REV'"
                NIXOS_REV='<error_nixos>'
            fi
        else
            echo "[error] command 'nixos-version' is unavailable."
            NIXOS_REV='<error_nixos>'
        fi

        # Get current flake
        LOCK_FILE="$PWD/flake.lock"
        printf "flake: "
        if [[ -f "$LOCK_FILE" ]]; then
            FLAKE_REV=$(${pkgs.jq}/bin/jq -r '
                .nodes
                | to_entries[]
                | select((.value.locked.owner // "" | ascii_downcase) == "nixos"
                    and  (.value.locked.repo // "" | ascii_downcase) == "nixpkgs"
                  )
                | .value.locked.rev
            ' "$LOCK_FILE" | head -1)
            if [[ -n "$FLAKE_REV" && "$FLAKE_REV" != "null" ]]; then
                echo "$FLAKE_REV"
            else
                echo "[error] invalid rev: '$FLAKE_REV'"
                FLAKE_REV='<error_flake>'
            fi
        else
            echo "[error] flake.lock missing at '$LOCK_FILE'"
            FLAKE_REV='<error_flake>'
        fi

        printf "status: "
        [[ "$NIXOS_REV" == "$FLAKE_REV" ]] && { echo "in sync"; exit 0; } || { echo "out of sync"; exit 1; }
    '')

    (pkgs.writeShellScriptBin "nix-develop" ''
        if [[ ! -e "$PWD/flake.nix" ]]; then
            echo "[error] no flake.nix found in '$PWD/flake.nix'"
            exit 1
        fi

        if ! command -v nix-pkgvercmp &> /dev/null; then
            read -p "[warn] 'nix-pkgvercmp' is not available. continue? [y/*]: " answer
            [[ "$answer" != "y" ]] && exit 1
        fi

        if ! nix-pkgvercmp; then
            read -p "[warn] nix revision versions are mismatched. continue? [y/*]: " answer
            [[ "$answer" != "y" ]] && exit 1
        fi

        exec nix develop
    '')

    (pkgs.writeShellScriptBin "git-init" ''
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
