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
					name:    "vault"
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
						extraEnvironmentVars: {
							VAULT_SEAL_TYPE:                  "ocikms"
							VAULT_OCIKMS_SEAL_KEY_ID:         "ocid1.key.oc1.ap-tokyo-1.eztt6k6vaaa52.abxhiljr74r3r6l6k3zpsml53by45ihmeq4g5z3zppjo2xxzun7pgki42boq"
							VAULT_OCIKMS_CRYPTO_ENDPOINT:     "https://eztt6k6vaaa52-crypto.kms.ap-tokyo-1.oraclecloud.com"
							VAULT_OCIKMS_MANAGEMENT_ENDPOINT: "https://eztt6k6vaaa52-management.kms.ap-tokyo-1.oraclecloud.com"
						}
						auditStorage: enabled: false
						ingress: {
							enabled:          true
							annotations:      "cert-manager.io/cluster-issuer: letsencrypt-issuer"
							ingressClassName: "nginx"
							hosts: [{host: "vault.westelh.dev"}]
							tls: [{
								secretName: "vault-ingress-tls"
								hosts: ["vault.westelh.dev"]
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
