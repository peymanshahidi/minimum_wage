#!/usr/bin/env bash
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

source writeup/.env
echo "Downloading..."
wget -q -O remote_data.tar.gz.gpg $DROPBOX_URL & 
spinner
echo "Download complete"
#curl -s -o remote_data.tar.gz.gpg $DROPBOX_URL --progress-bar
gpg --batch --quiet --passphrase "$GPG_PASSPHRASE" --decrypt remote_data.tar.gz.gpg > data.tar.gz
tar -xvf data.tar.gz
