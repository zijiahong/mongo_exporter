#!/bin/bash

mkdir -p /data/db

chmod 600 /etc/mongo/mongo.key

echo 'Mongod Server Starting'

mongod --config /etc/mongo.conf