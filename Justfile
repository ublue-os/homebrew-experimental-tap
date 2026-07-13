# Run local Homebrew CI tests (syntax, style, and audit checks)
test:
    brew test-bot --only-tap-syntax --tap=ublue-os/experimental-tap

init-local-repo:
    @brew tap | grep -q 'local/ublue-experimental-tap' || brew tap-new local/ublue-experimental-tap
    mkdir -p $(brew --repository local/ublue-experimental-tap)/Casks

untap-local:
    brew untap local/ublue-experimental-tap

build-formula:
    #!/bin/bash
    just init-local-repo
    FORMULA=$(realpath ./Formula/$(ls ./Formula | fzf))
    cp $FORMULA $(brew --repository local/ublue-experimental-tap)/Formula/
    brew reinstall -sy local/ublue-experimental-tap/$(basename $FORMULA .rb)

assemble-cask:
    #!/bin/bash
    just init-local-repo
    CASK=$(realpath ./Casks/$(ls ./Casks | fzf))
    cp $CASK $(brew --repository local/ublue-experimental-tap)/Casks/
    brew install --cask local/ublue-experimental-tap/$(basename $CASK .rb)
