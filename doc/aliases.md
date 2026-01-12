# Aliases

Shell aliases are defined in `dotfiles/.bashconfig/aliases.template`.

## Templating

Some aliases need to reference the nixfig repository path. Rather than hardcoding this, we use templating:

1. `aliases.template` contains `$NIXFIG_DIR` as a placeholder
2. Running `just` (or `just template`) generates `aliases` with the actual path substituted
3. The generated file is then stowed to `~/.bashconfig/aliases`

The generated `aliases` file is gitignored.

**Note:** The repo path is baked in at template time. If you move the repository, you'll need to re-run `just` to regenerate the aliases file.

## Adding new aliases

For simple aliases, just add them to `aliases.template`:

```bash
alias foo='bar'
```

If an alias needs the repo path, use `$NIXFIG_DIR`:

```bash
alias myalias='some-command $NIXFIG_DIR/path/to/thing'
```
