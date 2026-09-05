# Universal Blue Experimental Homebrew Tap

> [!WARNING]
> This tap is **for maintainers only**. Packages are in-progress, provided as-is with no support, and may break, change, or be removed without notice.

A staging area to test new Homebrew formulas and casks before they're moved to the [main tap](https://github.com/ublue-os/homebrew-tap).

## Installation

`brew install ublue-os/experimental-tap/<formula>`

Or `brew tap ublue-os/experimental-tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "ublue-os/experimental-tap"
brew "<formula>"
```

## When to use this tap

- You're testing a new formula or cask before moving it to production
- You want to validate package builds and configurations
- You're gathering feedback on work-in-progress packages

## Before you proceed

- **No stability** - Packages may not work, or may break existing installations
- **No support** - Issues and pull requests may not be addressed
- **Subject to change** - Packages can be modified, moved, or deleted at any time
- **Not for production** - Do not use for critical workflows

## Linux desktop compatibility

Migrated Linux desktop and icon integrations use `~/.local/share` rather than a custom `XDG_DATA_HOME`.
Docker context setup uses `~/.docker`, and Webex MIME registration uses `~/.config`, rather than custom
`DOCKER_CONFIG` or `XDG_CONFIG_HOME` values.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Next steps

Once a formula or cask is stable and ready, open a PR to move it to the [production tap](https://github.com/ublue-os/homebrew-tap).
