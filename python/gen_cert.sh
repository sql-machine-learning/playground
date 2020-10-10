#!/bin/bash

# Copyright 2020 The SQLFlow Authors. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is to create certification file for playground's client.
# We will create a slef-signed ca file, and issue new cert file from
# this ca. It basically is intend to be used in test environment.
#

org="sqlflow.tech"

function create_ca() {
  if [[ -f ca/ca.crt ]]; then
    return
  fi
  mkdir ca && pushd ca
  cat >ca_cert.conf <<EOF
[ req ]
distinguished_name = dn
prompt = no

[ dn ]
O = ${org} CA
EOF

  openssl genrsa -out ca.key 2048
  openssl req -out ca.req -key ca.key -new -config ./ca_cert.conf
  openssl x509 -req -in ca.req -signkey ca.key -sha256 -out ca.crt
  openssl x509 -in ca.crt -outform PEM -out ca_crt.pem
  rm ca.req ca_cert.conf
  popd
}

function create_cert() {
  if [[ -z "$1" ]]; then
    exit 1
  fi
  target="$1"
  if [[ -f certs/${target}.crt ]]; then
    echo "Cert file for ${target} already exists!"
    return
  fi
  mkdir -p certs && pushd certs
  cat >${target}.conf <<EOF
[ req ]
distinguished_name = dn
prompt = no

[ dn ]
O = ${org}
CN = sqlflow-playground-${target}
EOF
  openssl genrsa -out ${target}.key 2048
  openssl req -out ${target}.req -key ${target}.key -new -config ${target}.conf
  openssl x509 -req -in ${target}.req -out ${target}.crt \
    -sha256 -CAcreateserial -days 5000 \
    -CA ../ca/ca.crt -CAkey ../ca/ca.key
  openssl rsa -in ${target}.key -out ${target}.pem
  openssl x509 -in ${target}.crt -outform PEM -out ${target}_crt.pem
  rm ${target}.req ${target}.conf
  popd
}

if [[ -z "$1" ]]; then
  echo "Usage: ./gen_cert.sh target_name"
  exit 1
fi

create_ca
create_cert "$1"
