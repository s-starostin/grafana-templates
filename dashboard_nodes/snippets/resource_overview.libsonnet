local table = import '../../.grafonnet-lib-custom/table_panel.libsonnet';
local transformation = import '../../.grafonnet-lib-custom/transformation.libsonnet';
local grafana = import '../../grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

local resourceOverviewFieldConfig = {
  "fieldConfig": {
    "defaults": {
      "custom": {
        "align": null
      },
      "mappings": [],
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          }
        ]
      },
      "unit": "none"
    },
    "overrides": [
      {
        "matcher": {
          "id": "byName",
          "options": "Uptime"
        },
        "properties": [
          {
            "id": "custom.align",
            "value": null
          },
          {
            "id": "unit",
            "value": "s"
          },
          {
            "id": "decimals",
            "value": 1
          },
          {
            "id": "custom.width",
            "value": 70
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Memory"
        },
        "properties": [
          {
            "id": "unit",
            "value": "bytes"
          },
          {
            "id": "decimals",
            "value": 2
          },
          {
            "id": "custom.width",
            "value": 79
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "IP （Link to details）"
        },
        "properties": [
          {
            "id": "links",
            "value": [
              {
                "title": "Browse host details",
                "url": "/d/dtcrt-nodes/?orgId=1&var-hostname=All&var-node=${__data.fields[instance]}&var-device=All"
              }
            ]
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "CPU used %"
        },
        "properties": [
          {
            "id": "unit",
            "value": "percent"
          },
          {
            "id": "custom.displayMode",
            "value": "lcd-gauge"
          },
          {
            "id": "decimals",
            "value": 2
          },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "#EAB839",
                  "value": 70
                },
                {
                  "color": "red",
                  "value": 85
                }
              ]
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "5m load"
        },
        "properties": [
          {
            "id": "decimals",
            "value": 2
          },
          {
            "id": "custom.width",
            "value": 66
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Memory used %"
        },
        "properties": [
          {
            "id": "unit",
            "value": "percent"
          },
          {
            "id": "custom.displayMode",
            "value": "lcd-gauge"
          },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "yellow",
                  "value": 70
                },
                {
                  "color": "red",
                  "value": 85
                }
              ]
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Partition Used %"
        },
        "properties": [
          {
            "id": "unit",
            "value": "percent"
          },
          {
            "id": "custom.displayMode",
            "value": "gradient-gauge"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Disk read"
        },
        "properties": [
          {
            "id": "unit",
            "value": "Bps"
          },
          {
            "id": "custom.displayMode",
            "value": "color-background"
          },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "orange",
                  "value": 10485760
                },
                {
                  "color": "red",
                  "value": 20485760
                }
              ]
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Disk write"
        },
        "properties": [
          {
            "id": "unit",
            "value": "Bps"
          },
          {
            "id": "custom.displayMode",
            "value": "color-background"
          },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "orange",
                  "value": 10485760
                },
                {
                  "color": "red",
                  "value": 20485760
                }
              ]
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Net recv"
        },
        "properties": [
          {
            "id": "unit",
            "value": "Bps"
          },
          {
            "id": "custom.displayMode",
            "value": "color-background"
          },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "orange",
                  "value": 30485760
                },
                {
                  "color": "red",
                  "value": 104857600
                }
              ]
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Net send"
        },
        "properties": [
          {
            "id": "unit",
            "value": "Bps"
          },
          {
            "id": "custom.displayMode",
            "value": "color-background"
          },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "orange",
                  "value": 30485760
                },
                {
                  "color": "red",
                  "value": 104857600
                }
              ]
            }
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Hostname"
        },
        "properties": [
          {
            "id": "custom.width",
            "value": 189
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Cores"
        },
        "properties": [
          {
            "id": "custom.width",
            "value": 51
          }
        ]
      }
    ]
  }
};

{
    new::
    (
        table.new(
          'Server Resource Overview (10 lines per page)',
          description='Partition utilization, disk read, disk write, download bandwidth, upload bandwidth, if there are multiple network cards or multiple partitions, it is the value of the network card or partition with the highest utilization rate collected.',
          datasource='${prometheus_datasource}'
        )
        .addTargets([
          prometheus.target(
            'node_uname_info{job="node_exporter"}',
            instant=true,
            legendFormat='hostname',
            format='table'
          ),
          prometheus.target(
            'node_memory_MemTotal_bytes{job="node_exporter"}',
            instant=true,
            legendFormat='memory',
            format='table'
          ),
          prometheus.target(
            'count(node_cpu_seconds_total{job="node_exporter",mode="system"}) by (instance)',
            instant=true,
            legendFormat='cpu_cores',
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
            '(1 - (node_memory_MemAvailable_bytes{job="node_exporter"} / (node_memory_MemTotal_bytes{job="node_exporter"})))* 100',
            instant=true,
            legendFormat='memory_used',
            format='table'
          ),
          prometheus.target(
            'max((node_filesystem_size_bytes{job="node_exporter",fstype="ext.?|xfs"}-node_filesystem_free_bytes{job="node_exporter",fstype="ext.?|xfs"}) *100/(node_filesystem_avail_bytes {job="node_exporter",fstype="ext.?|xfs"}+(node_filesystem_size_bytes{job="node_exporter",fstype="ext.?|xfs"}-node_filesystem_free_bytes{job="node_exporter",fstype="ext.?|xfs"})))by(instance)',
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
          )
        ])
        .addTransformations([
              transformation.new("filterFieldsByName", options={
                "include": {
                  "names": [
                    "instance",
                    "nodename",
                    "Value #D",
                    "Value #B",
                    "Value #C",
                    "Value #E",
                    "Value #F",
                    "Value #G",
                    "Value #H",
                    "Value #I",
                    "Value #J",
                    "Value #K",
                    "Value #L"
                  ]
                }
              }),
              transformation.new("seriesToColumns", options={
                "byField": "instance"
              }),
              transformation.new("organize", options={
                "excludeByName": {},
                "indexByName": {
                  "Value #B": 3,
                  "Value #C": 4,
                  "Value #D": 2,
                  "Value #E": 5,
                  "instance": 0,
                  "nodename": 1
                },
                "renameByName": {
                  "Value #B": "Memory",
                  "Value #C": "Cores",
                  "Value #D": "Uptime",
                  "Value #E": "5m load",
                  "Value #F": "CPU used %",
                  "Value #G": "Memory used %",
                  "Value #H": "Partition Used %",
                  "Value #I": "Disk read",
                  "Value #J": "Disk write",
                  "Value #K": "Net recv",
                  "Value #L": "Net send",
                  "instance": "IP （Link to details）",
                  "nodename": "Hostname"
                }
              })
        ])
        + resourceOverviewFieldConfig
    )
}
