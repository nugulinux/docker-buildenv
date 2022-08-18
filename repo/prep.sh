#! /bin/bash -x

rm -rf /var/lib/apt/lists/*
apt-get update -o Acquire::CompressionTypes::Order::=gz
apt-get update
apt-get dist-upgrade --yes --allow-unauthenticated
