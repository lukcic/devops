```sh
# Create TLS certificate
cd /tmp
sudo openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
  -keyout /etc/prometheus_node_exporter/tlsCertificate.key \
  -out /etc/prometheus_node_exporter/tlsCertificate.crt \
  -subj "/CN=`hostname`" \
  -addext "subjectAltName = DNS:`hostname`"
sudo chmod 600 /etc/prometheus_node_exporter/*
sudo chown -r node_exporter:node_exporter /etc/prometheus_node_exporter
```

```sh
sudo cat << 'EOF' >> /etc/prometheus_node_exporter/configuration.yml
tls_server_config:
  cert_file: /etc/prometheus_node_exporter/tlsCertificate.crt
  key_file: /etc/prometheus_node_exporter/tlsCertificate.key

EOF

# Restart Prometheus Node Exporter
sudo systemctl restart node_exporter
```