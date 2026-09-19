# RedAmon Codespaces configuration

This directory contains the complete Codespaces configuration. The files are intentionally kept at these exact paths:

- `.devcontainer/devcontainer.json` — Codespaces definition
- `.devcontainer/setup-redamon.sh` — install/start bootstrap script
- `.devcontainer/README.md` — this documentation

## What happens automatically

1. A new Codespace runs the lightweight install:

   ```bash
   ./redamon.sh install
   ```

   It does **not** enable GVM/OpenVAS or the optional Knowledge Base.

2. The bootstrap supplies the admin details non-interactively when RedAmon asks for them.

3. Later Codespace starts run:

   ```bash
   ./redamon.sh up
   ```

4. The admin account is ensured after startup.

The web UI is forwarded on port `3000`.

## Admin credentials

Credentials are stored outside the Git repository at:

```text
/workspaces/.redamon-admin-credentials
```

The file is created with permissions `600` and is not committed to the repository.

The default generated values are:

- name: `Codespace Admin`
- email: `admin@codespace.local`
- password: a generated password of at least 12 characters

To choose your own values, define these before creating/rebuilding the Codespace:

```text
REDAMON_ADMIN_NAME
REDAMON_ADMIN_EMAIL
REDAMON_ADMIN_PASSWORD
```

GitHub Codespaces secrets are recommended for the password. These variables override the generated defaults and are also saved to `/workspaces/.redamon-admin-credentials` for subsequent starts of the same Codespace.

## Manual commands

From the repository root:

```bash
bash .devcontainer/setup-redamon.sh install
bash .devcontainer/setup-redamon.sh start
bash .devcontainer/setup-redamon.sh ensure-admin
./redamon.sh status
./redamon.sh down
```

Deleting a Codespace deletes `/workspaces/.redamon-admin-credentials`. To reuse the same login in a new Codespace, set the three `REDAMON_ADMIN_*` values as Codespaces secrets or environment variables before the new Codespace is created.
