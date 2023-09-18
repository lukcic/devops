
How to monitor authenticated API endpoint that requires username and password using Blackbox exporter.

Edit the blackbox.yml
```yml
modules:
  http_2xx:    # Prometheus.yml file
    prober: http
    timeout: 5s
    http:
      valid_status_codes: [200]
      method: GET # post ,put ,delete

  http_2xx_auth:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      method: GET
      fail_if_ssl: false
      fail_if_not_ssl: true
      tls_config:
        insecure_skip_verify: true
      basic_auth:
        username: "username"
        password: "password"
```

Edit the prometheus.yml
```yml
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://ww.xyx.com
        - https://app.pqs.cloud
        - https://app.abc.cloud/actuator/health
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115
  - job_name: 'blackbox_auth_based'
    metrics_path: /probe
    params:
      module: [http_2xx_auth]
    static_configs:
      - targets:
        - https://api.auth.com/actuator/health   # It is authenticated by username and password
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115  # The blackbox exporter's real hostname:port.
```