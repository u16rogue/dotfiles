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
        echo "new session created"
    '')
]
