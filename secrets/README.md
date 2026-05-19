# Secrets

age-encrypted secrets, committable to git. Anything in this directory ending
in `.age` is encrypted with the recipients listed in [`secrets.nix`](./secrets.nix).
Anything else (e.g. `.pub` files) is plaintext-committed verbatim.

## Layout

```
secrets/
├── secrets.nix              # access manifest (PUBLIC keys + recipient rules)
├── user-password.age        # the user's hashed password (mkpasswd -m sha-512 output)
├── ssh/                     # auto-enumerated → installed to ~/.ssh/
│   ├── id_ed25519.age       # → ~/.ssh/id_ed25519 (mode 0400)
│   ├── id_ed25519.pub       # → ~/.ssh/id_ed25519.pub (plaintext, mode 0444)
│   ├── known_hosts.age      # → ~/.ssh/known_hosts (optional)
│   └── config.age           # → ~/.ssh/config (optional)
├── gpg/                     # auto-enumerated → installed to ~/.gnupg/
│   ├── private.age          # → ~/.gnupg/private, then `gpg --import` on boot
│   └── ownertrust.age       # → ~/.gnupg/ownertrust, then `gpg --import-ownertrust`
└── api-keys/                # auto-decrypted to /run/secrets/api-keys-<name>
```

`~/.ssh` and `~/.gnupg` are **NOT** in impermanence — they are wiped on
every boot and re-installed from this directory. The repo is the single
source of truth.

## Bootstrap

The first rebuild on a fresh machine will FAIL until the secrets exist.
Order of operations:

### 1. Install agenix on your laptop

```bash
nix profile install github:ryantm/agenix
```

(Or `nix-shell -p age --run 'age --help'` if you just want to inspect.)

### 2. Edit `secrets.nix` to put real pubkeys in

Replace the three placeholders:

- `mistylake`  — content of mistylake's `/etc/ssh/ssh_host_ed25519_key.pub`
- `mistyriver` — content of mistyriver's `/etc/ssh/ssh_host_ed25519_key.pub`
- `admin`     — YOUR personal SSH or age pubkey (the laptop you edit from)

> **First-time chicken-and-egg.** On a brand-new install, the host SSH key
> doesn't exist yet. Install once with `users.mutableUsers = true` and a
> temporary `initialPassword` set, boot, grab the pubkey from
> `/etc/ssh/ssh_host_ed25519_key.pub`, then come back here.

### 3. Create the password secret

```bash
mkpasswd -m sha-512                  # type your password, copy the hash
cd secrets/
agenix -e user-password.age          # paste the hash, save, quit
```

### 4. Create SSH keys (if you want them in git)

```bash
ssh-keygen -t ed25519 -f /tmp/id_ed25519 -N ""
agenix -e ssh/id_ed25519.age         # paste contents of /tmp/id_ed25519
cp /tmp/id_ed25519.pub ssh/id_ed25519.pub
shred -u /tmp/id_ed25519
```

### 5. Create GPG keys (if you want them in git)

```bash
gpg --export-secret-keys --armor YOUR_KEY_ID > /tmp/gpg-priv.asc
gpg --export-ownertrust > /tmp/gpg-trust.txt
agenix -e gpg/private.age            # paste contents of /tmp/gpg-priv.asc
agenix -e gpg/ownertrust.age         # paste contents of /tmp/gpg-trust.txt
shred -u /tmp/gpg-priv.asc /tmp/gpg-trust.txt
```

### 6. Commit and rebuild

```bash
git add secrets/
git commit -m "bootstrap secrets"
sudo nixos-rebuild switch --flake .
```

## Editing existing secrets

```bash
agenix -e secrets/<file>.age         # opens $EDITOR with decrypted content
```

## Adding a new host

1. Install the new host (with a temporary `mutableUsers = true` + initialPassword).
2. `ssh new-host cat /etc/ssh/ssh_host_ed25519_key.pub`
3. Add the pubkey to `secrets.nix` `hosts` list.
4. `cd secrets/ && agenix -r` — re-encrypts every file for the new recipient set.
5. Commit, push.
6. On the new host: `git pull && sudo nixos-rebuild switch --flake .`

## Adding a new secret category (e.g. `api-keys/anthropic.age`)

Just drop the file in. `users/user/secrets.nix` and `secrets/secrets.nix`
auto-enumerate any `*.age` under `ssh/`, `gpg/`, `api-keys/`. If you want
the secret installed somewhere specific (not `~/.ssh` or `~/.gnupg`), wire
it manually wherever you need it via `config.age.secrets.<name>.path`.

## Temporary GPG public keys (signature verification)

Don't pollute the declarative keyring. Use a scratch keyring:

```bash
gpg --no-default-keyring --keyring /tmp/scratch.gpg --import some-pubkey.asc
gpg --no-default-keyring --keyring /tmp/scratch.gpg --verify file.sig file
```
