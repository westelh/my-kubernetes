bundle: {
	apiVersion: "v1alpha1"
	name:       "ingress-controller"
	instances: {
		"ingress-nginx": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "ingress-nginx"
			values: {
				repository: url: "https://kubernetes.github.io/ingress-nginx"
				chart: {
					name:    "ingress-nginx"
					version: "4.7.5"
				}
				helmValues: {
					controller: {
						ingressClassResource: default: true
						service: annotations: "oci.oraclecloud.com/load-balancer-type": "nlb"
						metrics: {
							enabled: true
							service: annotations: {
								"k8s.grafana.com/scrape":                 "true"
								"k8s.grafana.com/metrics.scrapeInterval": "60s"
							}
							extraArgs: "enable-ssl-passthrough": "true"
						}
					}
				}
			}
		}
	}
}
