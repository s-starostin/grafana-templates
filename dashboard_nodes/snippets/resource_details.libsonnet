local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local stat = grafana.statPanel;

local resourceDetailsFieldConfig = {
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
    },
    overrides: [
      {
        matcher: {
          id: 'byName',
          options: 'Uptime',
        },
        properties: [
          {
            id: 'unit',
            value: 'dtdurations',
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
              ],
            },
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'Total memory',
        },
        properties: [
          {
            id: 'unit',
            value: 'decbytes',
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'CPU busy',
        },
        properties: [
          {
            id: 'unit',
            value: 'percent',
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'CPU IOWait',
        },
        properties: [
          {
            id: 'unit',
            value: 'percent',
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'RAM used',
        },
        properties: [
          {
            id: 'unit',
            value: 'percent',
          },
        ],
      },
    ],
  },
};

{
  new::
    (
      stat.new(
        ' ',
        transparent=true,
        datasource='${prometheus_datasource}'
      ).addTargets([
        prometheus.target(
          'avg(time() - node_boot_time_seconds{instance=~"$instance"})',
          instant=true,
          legendFormat='Uptime',
          format='time_series'
        ),
        prometheus.target(
          '100 - (avg(irate(node_cpu_seconds_total{instance=~"$instance",mode="idle"}[5m])) * 100)',
          instant=true,
          legendFormat='CPU busy',
          format='time_series'
        ),
        prometheus.target(
          'avg(irate(node_cpu_seconds_total{instance=~"$instance",mode="iowait"}[5m])) * 100',
          instant=true,
          legendFormat='CPU IOWait',
          format='time_series'
        ),
        prometheus.target(
          'with (cf={instance=~"$instance"}) avg((1 - (node_memory_MemAvailable_bytes{cf} / (node_memory_MemTotal_bytes{cf})))* 100)-0',
          instant=true,
          legendFormat='RAM used',
          format='time_series'
        ),
      ]) + resourceDetailsFieldConfig
    ),
}
