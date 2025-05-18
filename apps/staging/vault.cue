bundle: {
	apiVersion: "v1alpha1"
	name:       "vault"
	instances: {
		"vault": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "vault"
			values: {
				repository: url: "https://helm.releases.hashicorp.com"
				chart: {
					name: "vault"
					version: "0.28.1"
				}
				helmValues: {
					server: {
						ha: {
							enabled:  true
							replicas: 3
							// apiAddr:  "https://vault.westelh.dev"
							raft: enabled: true
						}
						auditStorage: enabled: false
						ingress: {
							enabled:          true
							hosts: [{host: "localhost"}]
							tls: [{
								secretName: "vault-ingress-tls"
								hosts: ["localhost"]
							}]
						}
						extraInitContainers: [{
							name:  "init"
							image: "busybox"
							env: [{
								name: "CONFIG_VALUE"
								value: """
												[INPUT]
												    Name tcp
												    Format json
												[FILTER]
												    Name expect
												    Match *
												    key_exists $request['id']
												    key_val_is_not_null $request['id']
												    action warn
												[OUTPUT]
												    Name opentelemetry
												    Match *
												    Host grafana-k8s-monitoring-alloy.monitoring.svc
												    Port 4318
												    log_response_payload true
												    logs_trace_id_message_key $request['id']
												    add_label service vault
												    add_label type audit
												"""
							}]
							volumeMounts: [{
								name:      "fluent-bit-config"
								mountPath: "/etc/fluent-bit"
							}]
							args: [
								"/bin/sh",
								"-c",
								"echo \"$CONFIG_VALUE\" > /etc/fluent-bit/fluent-bit.conf",
							]
						}]
						extraContainers: [{
							name:  "audit"
							image: "cr.fluentbit.io/fluent/fluent-bit:3.2.1"
							args: [
								"-c",
								"/etc/fluent-bit/fluent-bit.conf",
							]
							volumeMounts: [{
								name:      "fluent-bit-config"
								mountPath: "/etc/fluent-bit"
							}]
						}]
						volumes: [{
							name: "fluent-bit-config"
							emptyDir: {}
						}]
					}
				}
			}
		}
	}
}
