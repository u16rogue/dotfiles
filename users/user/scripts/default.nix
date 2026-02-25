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

    # Nix flake devshell pins - list pinned devshells
    (pkgs.writeShellScriptBin "nfds-pins" /*bash*/ ''
        ${pkgs.coreutils}/bin/ls -la /nix/var/nix/gcroots/auto | ${pkgs.coreutils}/bin/grep "projects"
    '')

    # Nix flake devshell pin - pin current devshell
    (pkgs.writeShellScriptBin "nfds-pin" /*bash*/ ''
        ${pkgs.nix}/bin/nix develop --profile .nix-gc-root
    '')
]
