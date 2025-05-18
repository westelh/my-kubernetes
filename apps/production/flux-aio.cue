bundle: {
	apiVersion: "v1alpha1"
	name:       "flux-aio"
	instances: {
		"flux": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
			namespace: "flux-system"
			values: {
				controllers: {
					helm: enabled:         true
					kustomize: enabled:    true
					notification: enabled: true
				}
				hostNetwork:     false
				securityProfile: "privileged"
			}
		}

		"capacitor": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-oci-sync"
			namespace: "flux-system"
			values: {
				artifact: {
					url:    "oci://ghcr.io/gimlet-io/capacitor-manifests"
					semver: "^0.4.8"
				}
				sync: {
					targetNamespace: namespace
				}
			}
		}
	}
}
