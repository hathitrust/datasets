{
  local config = $._config.search_client,

  phineas:: {
    external_ip_service: {
      new(name, external_ip, port): {
        service: {
          apiVersion: "v1",
          kind: "Service",
          metadata: { name: name },
          spec: {
            clusterIP: "None",
            ports: [ {
              port: port,
              protocol: "TCP",
              targetPort: port
            } ],
            sessionAffinity: "None",
            type: "ClusterIP"
          }
        },
        endpoints: {
          apiVersion: "v1",
          kind: "Endpoints",
          metadata: { name: name },
          subsets: [
            {
              addresses: [ { ip: external_ip } ],
              ports: [ { port: port, protocol: "TCP" } ]
            }
          ]
        }
      }
    }
  }

}
