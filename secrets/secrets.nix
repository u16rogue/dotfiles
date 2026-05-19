# agenix access manifest.
#
# This file is plaintext-committable. It only contains PUBLIC keys and a
# declaration of which recipients can decrypt which encrypted files.
#
# Workflow:
#   - Edit a secret:        agenix -e secrets/<file>.age
#   - Rotate recipients:    agenix -r          (run from secrets/ dir)
#   - Add a new host:       paste its ssh_host_ed25519_key.pub below,
#                           append it to `hosts`, then run agenix -r
#
# Bootstrap: each host's age identity is its sshd-generated
# /etc/ssh/ssh_host_ed25519_key. This file is persisted via
# environment.persistence."/persist" -> /etc/ssh, so it survives reboots.

let
    # ─── Hosts ────────────────────────────────────────────────────────────
    # Replace these with the actual content of each host's
    # /etc/ssh/ssh_host_ed25519_key.pub after first install.
    # `./ctl bootstrap` patches the placeholder for the current host
    # automatically.
    mistylake  = "ssh-ed25519 AAAA__REPLACE_WITH_MISTYLAKE_HOST_PUBKEY__";
    mistyriver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYWxa99sHJ94Cb69bbD+dBknEJNcVRDerPmsgrEdwFW root@mistyriver";
    hosts = [ mistylake mistyriver ];

    # ─── Admin user keys ──────────────────────────────────────────────────
    # YOUR personal age/ssh pubkey(s). These let you decrypt secrets from
    # your laptop when editing. Add as many as you want (multiple machines,
    # backup key, etc.). Use ssh-ed25519 pubkeys or age1... recipients.
    admin = "ssh-ed25519 AAAA__REPLACE_WITH_YOUR_ADMIN_PUBKEY__";
    admins = [ admin ];

    # ─── Recipient resolution ─────────────────────────────────────────────
    # Filter out any placeholder pubkeys so age does not try to encrypt to
    # an unparseable recipient. Keys whose value still contains the
    # "__REPLACE_WITH_" marker are silently skipped. If you forgot to
    # bootstrap a host, secrets will simply not be decryptable on that
    # host until you do.
    isReal = key: builtins.match ".*__REPLACE_WITH_.*" key == null;
    realHosts  = builtins.filter isReal hosts;
    realAdmins = builtins.filter isReal admins;
    rawAll = realHosts ++ realAdmins;

    # Sanity: there must be at least one real recipient or no secret can
    # be encrypted at all. Crash with a useful message rather than letting
    # age silently fail. Inlined into `all` so reading it forces the check.
    all = if rawAll == [] then
        throw "secrets/secrets.nix: every pubkey is still a placeholder. run './ctl bootstrap' on at least one host or replace the placeholders by hand."
    else rawAll;

    # ─── Auto-enumeration ─────────────────────────────────────────────────
    # Walk a subdirectory and produce { "ssh/foo.age" = { publicKeys = all; }; ... }
    # Mirrors the host enumeration pattern used in flake.nix.
    enumerateDir = subdir:
        let
            path = ./. + "/${subdir}";
            entries = if builtins.pathExists path then builtins.readDir path else {};
            ageFiles = builtins.filter
                (name: entries.${name} == "regular" && builtins.match ".*\\.age$" name != null)
                (builtins.attrNames entries);
        in
            builtins.listToAttrs (map (name: {
                name = "${subdir}/${name}";
                value = { publicKeys = all; };
            }) ageFiles);

    # ─── Top-level known secrets ──────────────────────────────────────────
    # These are listed by name (not enumerated) because ragenix needs a
    # rule to EXIST before it will let you CREATE the encrypted file. With
    # filesystem enumeration alone, the first-time creation of these
    # secrets is impossible (chicken-and-egg).
    knownTopLevel = {
        "user-password.age".publicKeys = all;
    };

    # Plus any other *.age the user drops in by hand at the top level.
    enumeratedTopLevel =
        let
            entries = builtins.readDir ./.;
            ageFiles = builtins.filter
                (name: entries.${name} == "regular" && builtins.match ".*\\.age$" name != null)
                (builtins.attrNames entries);
        in
            builtins.listToAttrs (map (name: {
                inherit name;
                value = { publicKeys = all; };
            }) ageFiles);
in
    # Order matters: knownTopLevel wins on key collision, so e.g. if you
    # ever wanted user-password.age restricted to a smaller recipient set
    # you could override it in knownTopLevel without touching the rest.
    enumeratedTopLevel
    // (enumerateDir "ssh")
    // (enumerateDir "gpg")
    // (enumerateDir "api-keys")
    // knownTopLevel
