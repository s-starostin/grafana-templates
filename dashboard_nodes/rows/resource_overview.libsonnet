//Defaults
local defaults = import '../../.defaults/parameters.libsonnet';

//Templates
local graphTemplates = import '../templates/graph.libsonnet';

local table = import '../../.grafonnet-lib-custom/table_panel.libsonnet';
local transformation = import '../../.grafonnet-lib-custom/transformation.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

{
  panels:: [
    table.new(
      'Server Resource Overview',
      description='Partition utilization, disk read, disk write, download bandwidth, upload bandwidth, if there are multiple network cards or multiple partitions, it is the value of the network card or partition with the highest utilization rate collected.',
      datasource='${prometheus_datasource}'
    ) {
      gridPos: { h: defaults.blockHeight, w: 3 * defaults.blockWidth, x: 0, y: 0 },
    }
    .addTargets([
      prometheus.target(
        'label_replace(node_uname_info{job="node_exporter"}, "shortname", "$1", "instance", "(.*):.*")',
        instant=true,
        legendFormat='hostname',
        format='table'
      ),
      prometheus.target(
        'time() - node_boot_time_seconds{job="node_exporter"}',
        instant=true,
        legendFormat='uptime',
        format='table'
      ),
      prometheus.target(
        'node_load5{job="node_exporter"}',
        instant=true,
        legendFormat='load5',
        format='table'
      ),
      prometheus.target(
        '(1 - avg(irate(node_cpu_seconds_total{job="node_exporter",mode="idle"}[5m])) by (instance)) * 100',
        instant=true,
        legendFormat='cpu_used',
        format='table'
      ),
      prometheus.target(
        'with (cf={job="node_exporter"}) (1 - (node_memory_MemAvailable_bytes{cf} / (node_memory_MemTotal_bytes{cf})))* 100',
        instant=true,
        legendFormat='memory_used',
        format='table'
      ),
      prometheus.target(
        'with (cf={job="node_exporter",fstype="ext.?|xfs"}) max((node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}) *100/(node_filesystem_avail_bytes {job="node_exporter",fstype="ext.?|xfs"}+(node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf})))by(instance)',
        instant=true,
        legendFormat='partition_used',
        format='table'
      ),
      prometheus.target(
        'max(irate(node_disk_read_bytes_total{job="node_exporter"}[5m])) by (instance)',
        instant=true,
        legendFormat='disk_read',
        format='table'
      ),
      prometheus.target(
        'max(irate(node_disk_written_bytes_total{job="node_exporter"}[5m])) by (instance)',
        instant=true,
        legendFormat='disk_write',
        format='table'
      ),
      prometheus.target(
        'max(irate(node_network_receive_bytes_total{job="node_exporter"}[5m])*8) by (instance)',
        instant=true,
        legendFormat='net_recieve',
        format='table'
      ),
      prometheus.target(
        'max(irate(node_network_transmit_bytes_total{job="node_exporter"}[5m])*8) by (instance)',
        instant=true,
        legendFormat='net_send',
        format='table'
      ),
    ])
    .addTransformations([
      transformation.new('filterFieldsByName', options={
        include: {
          names: [
            'instance',
            'shortname',
            'Value #D',
            'Value #E',
            'Value #F',
            'Value #G',
            'Value #H',
            'Value #I',
            'Value #J',
          ],
        },
      }),
      transformation.new('seriesToColumns', options={
        byField: 'instance',
      }),
      transformation.new('organize', options={
        excludeByName: {
          'instance': true,
        },
        indexByName: {
          'shortname': 0,
          'Value #B': 2,
          'Value #C': 3,
          'Value #D': 1,
          'Value #E': 4,
        },
        renameByName: {
          'shortname': 'IP',
          'Value #B': 'Uptime',
          'Value #C': '5m load',
          'Value #D': 'CPU used %',
          'Value #E': 'Memory used %',
          'Value #F': 'Partition Used %',
          'Value #G': 'Disk read',
          'Value #H': 'Disk write',
          'Value #I': 'Net recv',
          'Value #J': 'Net send',
        },
      }),
    ])
    + self.fieldConfigs.resourceOverview,
  ],
  fieldConfigs:: {
    resourceOverview:: {
      fieldConfig: {
        defaults: {
          custom: {
            align: null,
          },
          mappings: [],
          thresholds: {
            mode: 'absolute',
            steps: [
              {
                color: 'green',
                value: null,
              },
            ],
          },
          unit: 'none',
        },
        overrides: [
          {
            matcher: {
              id: 'byName',
              options: 'Uptime',
            },
            properties: [
              {
                id: 'custom.align',
                value: null,
              },
              {
                id: 'unit',
                value: 's',
              },
              {
                id: 'decimals',
                value: 1,
              },
              {
                id: 'custom.width',
                value: 70,
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Memory',
            },
            properties: [
              {
                id: 'unit',
                value: 'decbytes',
              },
              {
                id: 'decimals',
                value: 2,
              },
              {
                id: 'custom.width',
                value: 79,
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'IP',
            },
            properties: [
              {
                id: 'links',
                value: [
                  {
                    title: 'Browse host details',
                    url: '/d/dtcrt-nodes/?orgId=1&var-instance=${__data.fields[shortname]}&var-device=All',
                  },
                ],
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'CPU used %',
            },
            properties: [
              {
                id: 'unit',
                value: 'percent',
              },
              {
                id: 'custom.displayMode',
                value: 'lcd-gauge',
              },
              {
                id: 'decimals',
                value: 2,
              },
              {
                id: 'thresholds',
                value: {
                  mode: 'absolute',
                  steps: [
                    {
                      color: 'green',
                      value: null,
                    },
                    {
                      color: '#EAB839',
                      value: 70,
                    },
                    {
                      color: 'red',
                      value: 85,
                    },
                  ],
                },
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: '5m load',
            },
            properties: [
              {
                id: 'decimals',
                value: 2,
              },
              {
                id: 'custom.width',
                value: 66,
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Memory used %',
            },
            properties: [
              {
                id: 'unit',
                value: 'percent',
              },
              {
                id: 'custom.displayMode',
                value: 'lcd-gauge',
              },
              {
                id: 'thresholds',
                value: {
                  mode: 'absolute',
                  steps: [
                    {
                      color: 'green',
                      value: null,
                    },
                    {
                      color: 'yellow',
                      value: 70,
                    },
                    {
                      color: 'red',
                      value: 85,
                    },
                  ],
                },
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Partition Used %',
            },
            properties: [
              {
                id: 'unit',
                value: 'percent',
              },
              {
                id: 'custom.displayMode',
                value: 'gradient-gauge',
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Disk read',
            },
            properties: [
              {
                id: 'unit',
                value: 'Bps',
              },
              {
                id: 'custom.displayMode',
                value: 'color-background',
              },
              {
                id: 'thresholds',
                value: {
                  mode: 'absolute',
                  steps: [
                    {
                      color: 'green',
                      value: null,
                    },
                    {
                      color: 'orange',
                      value: 10485760,
                    },
                    {
                      color: 'red',
                      value: 20485760,
                    },
                  ],
                },
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Disk write',
            },
            properties: [
              {
                id: 'unit',
                value: 'Bps',
              },
              {
                id: 'custom.displayMode',
                value: 'color-background',
              },
              {
                id: 'thresholds',
                value: {
                  mode: 'absolute',
                  steps: [
                    {
                      color: 'green',
                      value: null,
                    },
                    {
                      color: 'orange',
                      value: 10485760,
                    },
                    {
                      color: 'red',
                      value: 20485760,
                    },
                  ],
                },
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Net recv',
            },
            properties: [
              {
                id: 'unit',
                value: 'Bps',
              },
              {
                id: 'custom.displayMode',
                value: 'color-background',
              },
              {
                id: 'thresholds',
                value: {
                  mode: 'absolute',
                  steps: [
                    {
                      color: 'green',
                      value: null,
                    },
                    {
                      color: 'orange',
                      value: 30485760,
                    },
                    {
                      color: 'red',
                      value: 104857600,
                    },
                  ],
                },
              },
            ],
          },
          {
            matcher: {
              id: 'byName',
              options: 'Net send',
            },
            properties: [
              {
                id: 'unit',
                value: 'Bps',
              },
              {
                id: 'custom.displayMode',
                value: 'color-background',
              },
              {
                id: 'thresholds',
                value: {
                  mode: 'absolute',
                  steps: [
                    {
                      color: 'green',
                      value: null,
                    },
                    {
                      color: 'orange',
                      value: 30485760,
                    },
                    {
                      color: 'red',
                      value: 104857600,
                    },
                  ],
                },
              },
            ],
          },
        ],
      },
    },
  },
}
