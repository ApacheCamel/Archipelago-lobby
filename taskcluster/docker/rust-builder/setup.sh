#!/bin/bash

set -e

apt update && apt install -y curl
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) WATCHEXEC_ARCH="x86_64-unknown-linux-gnu" ;;
    arm64) WATCHEXEC_ARCH="aarch64-unknown-linux-gnu" ;;
    *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac
curl -fsSL "https://github.com/watchexec/watchexec/releases/download/v2.5.1/watchexec-2.5.1-${WATCHEXEC_ARCH}.deb" -o /tmp/watchexec.deb
dpkg -i /tmp/watchexec.deb
rm /tmp/watchexec.deb
cat > /etc/apt/sources.list.d/debian-backports.sources <<EOF
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: bookworm-backports
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
apt update && apt install -y --no-install-recommends libpq-dev valkey python3 git libssl-dev pkg-config liblzma-dev zlib1g-dev mold
apt autoremove -y
rm -rf /var/lib/apt/lists/*

rustup component add clippy rustfmt

# Add worker user
mkdir -p /builds
useradd -d /builds/worker -s /bin/bash -m worker
mkdir -p /builds/worker/artifacts
chown -R worker:worker /builds/worker
chmod 755 /builds/worker
