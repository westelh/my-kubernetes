bundle: {
    apiVersion: "v1alpha1"
    name:       "podinfo"
    instances: {
        "podinfo": {
            module: url: "oci://ghcr.io/stefanprodan/modules/flux-oci-sync"
            namespace: "flux-system"
            values: {
                artifact: {
                    url:    "oci://ghcr.io/stefanprodan/manifests/podinfo"
                    semver: ">=1.0.0"
                }
                sync: {
                    targetNamespace: "default"
                    wait:            true
                }
            }
        }
    }
}