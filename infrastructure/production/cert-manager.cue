bundle: {
	apiVersion: "v1alpha1"
	name:       "cert-manager"
	instances: {
		"cert-manager": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: name
			values: {
				repository: url: "https://charts.jetstack.io"
				chart: {
					name:    "cert-manager"
					version: "1.13.0"
				}
				helmValues: {
					installCRDs: true
				}
			}
		}

		"trust-manager": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: name
			values: {
				repository: url: "https://charts.jetstack.io"
				chart: {
					name:    "trust-manager"
					version: "0.7.0"
				}
			}
		}
	}
}
