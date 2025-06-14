#!/bin/bash

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=sriauronet.lan"
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365

