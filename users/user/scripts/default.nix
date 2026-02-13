{ pkgs, ... }: [
    (pkgs.writeShellScriptBin "mkignore" (builtins.readFile ./mkignore))
    (pkgs.writeShellScriptBin "tmuxss" (builtins.readFile ./tmuxss))
]
