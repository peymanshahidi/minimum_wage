#!/usr/bin/env bash
set -euo pipefail

# Spinner for download feedback
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid &> /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Set file names and paths
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRITEUP_DIR="$ROOT_DIR/writeup"
GPG_FILE="$ROOT_DIR/remote_data.tar.gz.gpg"
TAR_FILE="$ROOT_DIR/data.tar.gz"

# Load .env if DROPBOX_URL is not set
if [ -z "${DROPBOX_URL:-}" ] && [ -f "$WRITEUP_DIR/.env" ]; then
    echo "🔐 Loading environment from $WRITEUP_DIR/.env"
    set -a
    source "$WRITEUP_DIR/.env"
    set +a
fi

# 🧼 Strip quotes using eval
DROPBOX_URL=$(eval echo $DROPBOX_URL)
GPG_PASSPHRASE=$(eval echo $GPG_PASSPHRASE)

# Download the file
echo "📦 Downloading to: $GPG_FILE"
curl -L "$DROPBOX_URL" -o "$GPG_FILE" &
spinner

# Confirm download is completed
echo "✅ Download complete"
file "$GPG_FILE" || true
ls -lh "$GPG_FILE" || true

# Decrypt
echo "🔐 Decrypting..."
gpg --batch --quiet --passphrase "$GPG_PASSPHRASE" \
    --decrypt "$GPG_FILE" > "$TAR_FILE"

# Extract
echo "📂 Extracting..."
tar -xzf "$TAR_FILE" -C "$ROOT_DIR"
echo "✅ Data extracted to $ROOT_DIR"