{
  _config+:: {
    SLOs: {
      apiserver: {
        days: 30,  // The number of days we alert on burning too much error budget for.
        target: 0.99,  // The target percentage of availability between 0-1. (0.99 = 99%, 0.999 = 99.9%)

        // Only change these windows when you really understand multi burn rate errors.
        // Even though you can change the days above (which will change availability calculations)
        // these windows will alert on a 30 days sliding window. We're looking into basing these windows on the given days too.
        windows: [
          { severity: 'critical', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
          { severity: 'critical', 'for': '15m', long: '6h', short: '30m', factor: 6 },
          { severity: 'warning', 'for': '1h', long: '1d', short: '2h', factor: 3 },
          { severity: 'warning', 'for': '3h', long: '3d', short: '6h', factor: 1 },
        ],
      },
    },

    // Selectors are inserted between {} in Prometheus queries.
    cadvisorSelector: 'job="cadvisor"',
    kubeletSelector: 'job="kubelet"',
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
    nodeExporterSelector: 'job="node"',
    kubeSchedulerSelector: 'job="kube-scheduler"',
    kubeControllerManagerSelector: 'job="kube-controller-manager"',
    kubeApiserverSelector: 'job="kube-apiserver"',
    kubeProxySelector: 'job=~"kube-proxy|kube-proxy-windows"',
    podLabel: 'pod',
    hostNetworkInterfaceSelector: 'device!~"veth.+"',
    hostMountpointSelector: 'mountpoint="/"',
    windowsExporterSelector: 'job="windows-exporter"',
    containerfsSelector: 'container!=""',

    // Grafana dashboard IDs are necessary for stable links for dashboards
    grafanaDashboardIDs: {
      'apiserver.json': std.md5('apiserver.json'),
      'cluster-total.json': std.md5('cluster-total.json'),
      'controller-manager.json': std.md5('controller-manager.json'),
      'k8s-resources-cluster.json': 'efa86fd1d0c121a26444b636a3f56738',
      'k8s-resources-multicluster.json': std.md5('k8s-resources-multicluster.json'),
      'k8s-resources-namespace.json': '85a562078cdf77779eaa1add43cc6738',
      'k8s-resources-node.json': '200ac8fdbfbb74b39aff88118e4d6738',
      'k8s-resources-pod.json': '6581e46e4e5c7ba40a07646395ef6738',
      'k8s-resources-windows-cluster.json': '6438557df4391b100730f2494bcc6738',
      'k8s-resources-windows-namespace.json': '98e54027a2724ab1d4c45666c1fa6738',
      'k8s-resources-windows-pod.json': '56497a7ea5610e936dc6ed374a7c6738',
      'k8s-resources-workload.json': 'a164a7f0339f99e89cea5cb47e9b6738',
      'k8s-resources-workloads-namespace.json': 'a87fb0d919ec0ea5f6543124e16c6738',
      'k8s-windows-cluster-rsrc-use.json': 'VESDB6738',
      'k8s-windows-node-rsrc-use.json': 'YCBDf6738',
      'kubelet.json': '3138fa155d5915769fbded898ac06738',
      'namespace-by-pod.json': std.md5('namespace-by-pod.json'),
      'namespace-by-workload.json': std.md5('namespace-by-workload.json'),
      'persistentvolumesusage.json': std.md5('persistentvolumesusage.json'),
      'pod-total.json': std.md5('pod-total.json'),
      'proxy.json': std.md5('proxy.json'),
      'scheduler.json': std.md5('scheduler.json'),
      'workload-total.json': std.md5('workload-total.json'),
    },

    // Support for Grafana 7.2+ `$__rate_interval` instead of `$__interval`
    grafana72: true,
    grafanaIntervalVar: if self.grafana72 then '$__rate_interval' else '$__interval',

    // Config for the Grafana dashboards in the Kubernetes Mixin
    grafanaK8s: {
      dashboardNamePrefix: 'Kubernetes / ',
      dashboardTags: ['kubernetes-mixin'],

      // For links between grafana dashboards, you need to tell us if your grafana
      // servers under some non-root path.
      linkPrefix: '',

      // The default refresh time for all dashboards, default to 10s
      refresh: '1m',
      minimumTimeInterval: '1m',

      // Timezone for Grafana dashboards:: UTC, browser, ...
      grafanaTimezone: 'UTC',
    },

    // Opt-in to multiCluster dashboards by overriding this and the clusterLabel.
    showMultiCluster: true,
    clusterLabel: 'cluster',

    namespaceLabel: 'namespace',

    // Default datasource name
    datasourceName: 'default',

    // Datasource instance filter regex
    datasourceFilterRegex: '',

    // This list of filesystem is referenced in various expressions.
    fstypes: ['ext[234]', 'btrfs', 'xfs', 'zfs'],
    fstypeSelector: 'fstype=~"%s"' % std.join('|', self.fstypes),

    // This list of disk device names is referenced in various expressions.
    diskDevices: ['mmcblk.p.+', 'nvme.+', 'rbd.+', 'sd.+', 'vd.+', 'xvd.+', 'dm-.+', 'dasd.+'],
    diskDeviceSelector: 'device=~"(/dev.+)|%s"' % std.join('|', self.diskDevices),

    // Certain workloads (e.g. KubeVirt/CDI) will fully utilise the persistent volume they claim
    // the size of the PV will never grow since they consume the entirety of the volume by design.
    // This selector allows an admin to 'pre-mark' the PVC of such a workload (or for any other use case)
    // so that specific storage alerts will not fire.With the default selector, adding a label `exclude-from-alerts: 'true'`
    // to the PVC will have the desired effect.
    pvExcludedSelector: 'label_excluded_from_alerts="true"',

    // Default timeout value for k8s Jobs. The jobs which are active beyond this duration would trigger KubeJobNotCompleted alert.
    kubeJobTimeoutDuration: 12 * 60 * 60,
  },
}
