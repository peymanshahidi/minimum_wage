#!/usr/bin/env bash
source writeup/.env
tar -zcvf data.tar.gz data
gpg --symmetric --batch --yes --passphrase "$GPG_PASSPHRASE" -o remote_data.tar.gz.gpg -c data.tar.gz
cp remote_data.tar.gz.gpg ~/Dropbox/replication/$project_name/remote_data.tar.gz.gpg
