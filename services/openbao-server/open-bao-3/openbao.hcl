storage "raft" {
  path    = "/opt/openbao/data"
  node_id = "open-bao-3"

  retry_join {
    leader_api_addr     = "https://192.168.253.30:8200"
    leader_ca_cert_file = "/opt/openbao/tls/rootCA.pem"
  }
  retry_join {
    leader_api_addr     = "https://192.168.253.31:8200"
    leader_ca_cert_file = "/opt/openbao/tls/rootCA.pem"
  }
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/openbao/tls/tls.crt"
  tls_key_file  = "/opt/openbao/tls/tls.key"
}

api_addr     = "https://192.168.253.32:8200"
cluster_addr = "https://192.168.253.32:8201"

ui = true
