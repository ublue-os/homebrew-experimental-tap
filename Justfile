# Run local Homebrew CI tests (syntax, style, and audit checks)
test:
    brew test-bot --only-tap-syntax --tap=ublue-os/experimental-tap
