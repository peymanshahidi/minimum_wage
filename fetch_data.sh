#!/usr/bin/env bash
source writeup/.env
wget -O remote_data.tar.gz.gpg $DROPBOX_URL
gpg --batch --passphrase "$GPG_PASSPHRASE" --decrypt remote_data.tar.gz.gpg > data.tar.gz
tar -xvf data.tar.gz
