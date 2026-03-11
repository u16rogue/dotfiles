{ pkgs, ... }: [
    (pkgs.writeShellScriptBin "mkignore" (builtins.readFile ./mkignore))

    (pkgs.writeShellScriptBin "tmuxss" /*bash*/ ''
        if [ -z "$1" ]; then
            echo "Missing directory. Usage: $0 <directory>"
            exit 1
        fi
        
        SESSION_DIR=$(${pkgs.coreutils}/bin/realpath "$1")
        if [ ! -d "$SESSION_DIR" ]; then
            echo "Invalid directory. Not found: $SESSION_DIR"
            exit 1
        fi
        
        SESSION_NAME=$(${pkgs.coreutils}/bin/basename "$1")
        
        # Session
        ${pkgs.tmux}/bin/tmux new-session -d -s "$SESSION_NAME" -A -c "$SESSION_DIR"
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
            fi
        else
            echo "[error] command 'nixos-version' is unavailable."
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
            fi
        else
            echo "[error] flake.lock missing at '$LOCK_FILE'"
        fi

        [[ "$NIXOS_REV" == "$FLAKE_REV" ]] && echo "in sync" || { echo "out of sync"; exit 1; }
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
