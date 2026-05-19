#!/usr/bin/env bash

# ctl - rebuild this nixos config for the current host.
#
# usage:
#   ./ctl                rebuild and switch (auto-detects hostname)
#   ./ctl bootstrap      first-time setup (run once per host, after install)
#   ./ctl user-password  prompt for a new login password, hash + encrypt to
#                        secrets/user-password.age (overwrites existing)
#
# secrets backend: ragenix (rust drop-in for agenix, in nixpkgs). consumes
# the same secrets.nix manifest as agenix, same CLI flags (-e, --rekey).
#
# everything else (editing arbitrary secrets, rekeying, building without
# activating) uses upstream tools directly:
#   nix run nixpkgs#ragenix -- -e secrets/<file>.age     # edit a secret
#   nix run nixpkgs#ragenix -- --rekey                   # re-encrypt all
#   nixos-rebuild build  --flake .#<host>                # build only
#   nixos-rebuild test   --flake .#<host>                # test, no boot entry
#   nixos-rebuild boot   --flake .#<host>                # next boot only

SCRIPT_NAME=$(basename "${0}")
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SECRETS_DIR="${SCRIPT_DIR}/secrets"
SECRETS_MANIFEST="${SECRETS_DIR}/secrets.nix"

err_exit() {
    printf "\n[${SCRIPT_NAME}] [err] %s\n" "${1}" >&2
    exit 1
}

println() {
    printf "\n[${SCRIPT_NAME}] %s" "${1}"
}

# encrypt content from stdin into secrets/<rel>. agenix detects non-tty
# stdin and uses `cp -- /dev/stdin` as the editor.
agenix_write_stdin() {
    local rel_path="${1}"
    (
        cd "${SECRETS_DIR}" || exit 1
        EDITOR='cp -- /dev/stdin' nix run "nixpkgs#ragenix" -- -e "${rel_path}"
    )
}

# prompt twice, hash via mkpasswd, encrypt to secrets/user-password.age.
write_user_password() {
    local pass1 pass2
    while true; do
        printf "\n[${SCRIPT_NAME}] password (hidden): "
        read -rs pass1
        printf "\n[${SCRIPT_NAME}] confirm: "
        read -rs pass2
        printf "\n"
        [[ "${pass1}" == "${pass2}" ]] && break
        println "[warn] passwords did not match. try again."
    done
    local hash
    hash=$(printf '%s' "${pass1}" | nix run "nixpkgs#mkpasswd" -- -m sha-512 --stdin) \
        || err_exit "mkpasswd failed."
    unset pass1 pass2
    # we are writing a fresh password from scratch — there is no value in
    # the existing file. removing it first means ragenix does not try to
    # decrypt-then-edit, which would fail on any machine that is not a
    # recipient (e.g. inside a devshell). encryption itself only needs
    # the recipient pubkeys from secrets.nix, so this works anywhere.
    rm -f "${SECRETS_DIR}/user-password.age"
    printf '%s' "${hash}" | agenix_write_stdin "user-password.age" \
        || err_exit "failed to encrypt user-password.age."
    unset hash
    println "wrote secrets/user-password.age."
}

# ====================================================================================================
# rebuild

cmd_rebuild() {
    local host
    host=$(hostname -s 2>/dev/null) || err_exit "could not detect hostname."
    [[ -d "${SCRIPT_DIR}/host/${host}" ]] || err_exit "no flake config for host '${host}'."

    println "rebuilding '${host}'..."
    printf "\n"
    sudo nixos-rebuild switch --flake "${SCRIPT_DIR}#${host}" \
        || err_exit "rebuild failed."
    println "done."
    printf "\n"
}

# ====================================================================================================
# bootstrap (run once per host)

cmd_bootstrap() {
    local host
    host=$(hostname -s 2>/dev/null) || err_exit "could not detect hostname."
    [[ -d "${SCRIPT_DIR}/host/${host}" ]] || err_exit "no flake config for host '${host}'."

    println "bootstrapping for host '${host}'..."

    # 1. patch secrets.nix with this host's pubkey
    local pubkey_file="/etc/ssh/ssh_host_ed25519_key.pub"
    [[ -r "${pubkey_file}" ]] || err_exit "host pubkey not found at '${pubkey_file}'."
    local host_pubkey
    host_pubkey=$(< "${pubkey_file}")

    local placeholder
    placeholder="ssh-ed25519 AAAA__REPLACE_WITH_$(printf '%s' "${host}" | tr '[:lower:]' '[:upper:]')_HOST_PUBKEY__"
    if grep -qF "${placeholder}" "${SECRETS_MANIFEST}"; then
        local escaped
        escaped=$(printf '%s' "${host_pubkey}" | sed 's:[/&\]:\\&:g')
        sed -i "s|${placeholder}|${escaped}|" "${SECRETS_MANIFEST}" \
            || err_exit "failed to patch secrets.nix."
        println "patched secrets.nix with host pubkey."
    else
        println "host pubkey already registered, skipping manifest patch."
    fi

    # 2. admin pubkey (if still placeholder)
    if grep -q "__REPLACE_WITH_YOUR_ADMIN_PUBKEY__" "${SECRETS_MANIFEST}"; then
        printf "\n[${SCRIPT_NAME}] paste your personal ssh-ed25519 or age1 pubkey (blank to skip): "
        local admin_pubkey
        read -r admin_pubkey
        if [[ -n "${admin_pubkey}" ]]; then
            local escaped
            escaped=$(printf '%s' "${admin_pubkey}" | sed 's:[/&\]:\\&:g')
            sed -i "s|ssh-ed25519 AAAA__REPLACE_WITH_YOUR_ADMIN_PUBKEY__|${escaped}|" "${SECRETS_MANIFEST}" \
                || err_exit "failed to set admin pubkey."
            println "admin pubkey set."
        fi
    fi

    # 3. user password
    if [[ -f "${SECRETS_DIR}/user-password.age" ]]; then
        println "secrets/user-password.age already exists, skipping."
    else
        write_user_password
    fi

    # 4. rekey everything (best-effort)
    #
    # rekey is decrypt-then-re-encrypt — it needs an identity matching one
    # of the existing recipients. on a fresh host that has no host ssh key
    # available (e.g. running from a devshell, or before the first boot)
    # this will fail with "no usable identity". that's fine for an initial
    # bootstrap because we just CREATED the only secret with the current
    # recipient set; nothing actually needs rekeying.
    #
    # the rekey only matters when you ADD a new host/admin and want the
    # PRE-EXISTING secrets to also become readable by them. for that case,
    # run `./ctl bootstrap` from a host that IS already a recipient, or
    # run `nix run nixpkgs#ragenix -- --rekey` directly.
    println "attempting to rekey existing secrets..."
    printf "\n"
    if (cd "${SECRETS_DIR}" && nix run "nixpkgs#ragenix" -- --rekey 2>&1); then
        println "rekey done."
    else
        printf "\n"
        println "[warn] rekey skipped (no usable identity on this machine)."
        println "       this is normal on a fresh host. existing secrets are still"
        println "       readable by their original recipients; only NEW secrets"
        println "       created here will include this host."
        println "       to rekey later, run from a host that is already a recipient:"
        println "         nix run nixpkgs#ragenix -- --rekey"
    fi

    printf "\n\n"
    println "bootstrap done. next:"
    println "  - review:  git diff secrets/"
    println "  - commit:  git add secrets/ && git commit -m 'bootstrap'"
    println "  - rebuild: ./${SCRIPT_NAME}"
    printf "\n"
}

# ====================================================================================================
# user-password (rotate the encrypted user password hash file)

cmd_user_password() {
    [[ -f "${SECRETS_MANIFEST}" ]] || err_exit "no secrets/secrets.nix. run './${SCRIPT_NAME} bootstrap' first."
    if grep -q "__REPLACE_WITH_" "${SECRETS_MANIFEST}"; then
        err_exit "secrets/secrets.nix still has placeholder pubkeys. run './${SCRIPT_NAME} bootstrap' first."
    fi
    println "rotating user password..."
    write_user_password
    printf "\n"
    println "rotation done. activate with: ./${SCRIPT_NAME}"
    printf "\n"
}

# ====================================================================================================
# entry

case "${1:-rebuild}" in
    rebuild|switch|"") cmd_rebuild ;;
    bootstrap)         cmd_bootstrap ;;
    user-password)     cmd_user_password ;;
    *) err_exit "unknown subcommand '${1}'. usage: ${SCRIPT_NAME} [bootstrap|user-password]" ;;
esac
