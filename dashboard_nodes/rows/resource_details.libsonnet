//Defaults
local colors = import '../../.defaults/colors.libsonnet';
local defaults = import '../../.defaults/parameters.libsonnet';

//Templates
local graphTemplates = import '../templates/graph.libsonnet';

local table = import '../../.grafonnet-lib-custom/table_panel.libsonnet';
local transformation = import '../../.grafonnet-lib-custom/transformation.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local stat = grafana.statPanel;
local graph = grafana.graphPanel;

{
  panels:: [
    stat.new(
        ' ',
        transparent=true,
        datasource='${prometheus_datasource}',
        justifyMode='center'
      ){
        gridPos: { h: 0.5 * defaults.blockHeight, w: 3 * defaults.blockWidth, x: 0, y: 0 },
      }.addTargets([
        prometheus.target(
          'count(node_cpu_seconds_total{instance=~"$instance:.+", mode="system"})',
          instant=true,
          legendFormat='Cores',
          format='time_series'
        ),
        prometheus.target(
          'avg(time() - node_boot_time_seconds{instance=~"$instance:.+"})',
          instant=true,
          legendFormat='Uptime',
          format='time_series'
        ),
        prometheus.target(
          '100 - (avg(irate(node_cpu_seconds_total{instance=~"$instance:.+",mode="idle"}[5m])) * 100)',
          instant=true,
          legendFormat='CPU busy',
          format='time_series'
        ),
        prometheus.target(
          'avg(irate(node_cpu_seconds_total{instance=~"$instance:.+",mode="iowait"}[5m])) * 100',
          instant=true,
          legendFormat='CPU IOWait',
          format='time_series'
        ),
        prometheus.target(
          'with (cf={instance=~"$instance:.+"}) avg((1 - (node_memory_MemAvailable_bytes{cf} / (node_memory_MemTotal_bytes{cf})))* 100)-0',
          instant=true,
          legendFormat='RAM used',
          format='time_series'
        ),
        prometheus.target(
          'with (cf={instance=~"$instance:.+"}) (1 - ((node_memory_SwapFree_bytes{cf} + 1)/ (node_memory_SwapTotal_bytes{cf} + 1))) * 100',
          instant=true,
          legendFormat='SWAP used',
          format='time_series'
        ),
      ]) + self.fieldConfigs.resourceDetails,

    graphTemplates.overallGraph {
      title: 'CPU% Basic',
      legend: {
        alignAsTable: true,
        avg: true,
        current: true,
        hideEmpty: true,
        hideZero: true,
        min: true,
        max: true,
        sort: 'current',
        sortDesc: true,
        values: true,
      },
      yaxes: [
        {
          format: 'percent',
          logBase: 1,
          show: true,
        },
        {
          show: false,
        },
      ],
      decimals: 2,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 0.5 * defaults.blockHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: '/.*Total/',
        color: '#C4162A',
        fill: 0,
      }
    )
    .addTargets([
      {
        expr: 'avg(irate(node_cpu_seconds_total{instance=~"$instance:.+",mode="user"}[5m])) by (instance) *100',
        instant: false,
        legendFormat: 'User',
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'avg(irate(node_cpu_seconds_total{instance=~"$instance:.+",mode="iowait"}[5m])) by (instance) *100',
        instant: false,
        legendFormat: 'IOWait',
        format: 'time_series',
        step: 240,
      },
    ]),

    graphTemplates.overallGraph {
      title: 'Memory Basic',
      legend: {
        alignAsTable: true,
        avg: true,
        current: true,
        hideEmpty: true,
        hideZero: true,
        min: true,
        max: true,
        sort: 'current',
        sortDesc: true,
        values: true,
      },
      yaxes: [
        {
          format: 'decbytes',
          label: null,
          min: '0',
          show: true,
        },
        {
          format: 'percent',
          label: 'Utilization%',
          max: '100',
          min: '0',
          show: true,
        },
      ],
      decimals: 2,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 1.5 * defaults.blockWidth,
        y: 0.5 * defaults.blockHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: 'Total',
        color: '#C4162A',
        dashes: true,
        fill: 0,
        linewidth: 1,
      },
    )
    .addSeriesOverride(
      {
        alias: 'Used%',
        color: '#56A64B',
        fill: 1,
        lines: true,
        yaxis: 2,
      },
    )
    .addTargets([
      {
        expr: 'node_memory_MemTotal_bytes{instance=~"$instance:.+"}',
        instant: false,
        legendFormat: 'Total',
        format: 'time_series',
        step: 4,
      },
      {
        expr: 'node_memory_MemAvailable_bytes{instance=~"$instance:.+"}',
        legendFormat: 'Avaliable',
        format: 'time_series',
        step: 4,
      },
      {
        expr: 'with (cf={instance=~"$instance:.+"}) (1 - (node_memory_MemAvailable_bytes{cf} / (node_memory_MemTotal_bytes{cf})))* 100',
        instant: false,
        legendFormat: 'Used%',
        format: 'time_series',
        intervalFactor: 10,
        step: 4,
      },
    ]),
    
    graphTemplates.overallGraph {
      title: 'Disk Space Used% Basic',
      decimals: 2,
      legend: {
        alignAsTable: true,
        avg: true,
        current: true,
        hideEmpty: true,
        hideZero: true,
        min: true,
        max: true,
        sort: 'current',
        sortDesc: true,
        values: true,
      },
      yaxes: [
        {
          decimals: null,
          format: 'percent',
          label: '',
          logBase: 1,
          max: '100',
          min: '0',
          show: true,
        },
        {
          decimals: 2,
          format: 'percentunit',
          max: 1,
          show: false,
        },
      ],
      linewidth: 1,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 1.5 * defaults.blockHeight,
      },
    }
    .addTargets([
      {
        expr: 'with (cf={instance=~"$instance:.+",fstype=~"ext.*|xfs",mountpoint !~".*pod.*"}) (node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}) *100/(node_filesystem_avail_bytes {cf}+(node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}))',
        instant: false,
        legendFormat: '{{mountpoint}}',
        format: 'time_series',
      },
    ]),
    
    graphTemplates.stackGraph {
      title: 'Network Traffic Basic ($device)',
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 1.5 * defaults.blockWidth,
        y: 1.5 * defaults.blockHeight,
      },
    }
    .addTargets([
      {
        expr: 'increase(node_network_receive_bytes_total{instance=~"$instance:.+",device=~"$device"}[5m])',
        format: 'time_series',
        interval: '60m',
        intervalFactor: 1,
        legendFormat: '{{device}} RX',
        step: 600,
      },
      {
        expr: 'increase(node_network_transmit_bytes_total{instance=~"$instance:.+",device=~"$device"}[5m])',
        format: 'time_series',
        interval: '60m',
        intervalFactor: 1,
        legendFormat: '{{device}} TX',
        step: 600,
      },
    ])
    .addSeriesOverride(
      {
        alias: '/.* TX$/',
        transform: 'negative-Y',
      },
    )
    .resetYaxes()
    .addYaxis(format='decbytes', label='transmit(-)/receive(+)')
    .addYaxis(format='short', show=false),

    graphTemplates.stackGraph {
      title: 'Alerts History',
      legend: {
        alignAsTable: true,
        avg: false,
        current: false,
        hideEmpty: true,
        hideZero: true,
        min: false,
        max: false,
        values: false,
      },
      fill: 1,
      fillGradient: 10,
      yaxes: [
        {
          label: "Firing (-)   /  Pending (+)  ",
          logBase: 1,
          show: true,
        },
        {
          max: "1",
          min: "-1",
          show: false,
        },
      ],
      decimals: 2,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 3 * defaults.blockHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: "/pending/",
        stack: "A"
      }
    )
    .addSeriesOverride(
      {
        alias: "/firing/",
        stack: "B",
        transform: "negative-Y",
        zindex: -3
      }
    )
    .addSeriesOverride(
      {
        alias: "/help_series_x_axes_in_center/",
        bars: false,
        hideTooltip: true,
        legend: false,
        lines: false,
        stack: false,
        yaxis: 2
      }
    )
    .addTargets([
      {
        expr: 'ALERTS{instance=~"$instance:.+"}',
        instant: false,
        legendFormat: '{{alertname}} {{alertstate}} {{datacenter}}',
        "refId": "C"
      },
      {
        expr: '1',
        instant: false,
        legendFormat: 'help_series_x_axes_in_center',
        "refId": "A"
      },
    ]),

    table.new(
      'Alerts',
      datasource='${prometheus_datasource}'
      ) {
        gridPos: { h: 1.5 * defaults.blockHeight, w: 1.5 * defaults.blockWidth, x: 1.5 * defaults.blockWidth, y: 3 * defaults.blockHeight },
      }
      .addTargets([
        prometheus.target(
            'changes(ALERTS_FOR_STATE{instance=~"$instance:.+"}[$__range])',
            instant=true,
            legendFormat='',
            format='table'
        )
      ])
      .addTransformations([
        transformation.new('organize', options={
            excludeByName: {
              Value: true,
              instance: true
            },
            indexByName: {},
            renameByName: {}
          }),
      ])

  ],
  fieldConfigs:: {
    resourceDetails:: {
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
          {
            matcher: {
              id: 'byName',
              options: 'SWAP used',
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
    }
  },
}
