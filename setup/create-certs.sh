#!/bin/bash
# setup/create-certs.sh

set -e

if [ ! -f config/certs/ca.zip ]; then
  echo "Creating CA..."
  bin/elasticsearch-certutil ca --silent --pem --out config/certs/ca.zip
  unzip -o config/certs/ca.zip -d config/certs
fi

if [ ! -f config/certs/certs.zip ]; then
  echo "Creating certificates..."

  cat > config/certs/instances.yml << EOF
instances:
  - name: elasticsearch
    dns:
      - elasticsearch
      - localhost
    ip:
      - 127.0.0.1
  - name: logstash
    dns:
      - logstash
      - localhost
    ip:
      - 127.0.0.1
  - name: kibana
    dns:
      - kibana
      - localhost
    ip:
      - 127.0.0.1
EOF

  echo "Generated instances.yml:"
  cat config/certs/instances.yml

  bin/elasticsearch-certutil cert --silent --pem \
    --ca-cert config/certs/ca/ca.crt \
    --ca-key  config/certs/ca/ca.key \
    --in      config/certs/instances.yml \
    --out     config/certs/certs.zip

  unzip -o config/certs/certs.zip -d config/certs
fi

echo "Setting permissions..."
chown -R 1000:0 config/certs
find config/certs -type d -exec chmod 750 {} \;
find config/certs -type f -exec chmod 640 {} \;

echo "Certificates ready!"
