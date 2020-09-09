//Defaults
local colors = import '../../.defaults/colors.libsonnet';
local defaults = import '../../.defaults/parameters.libsonnet';

//Templates
local graphTemplates = import '../templates/graph.libsonnet';

local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local stat = grafana.statPanel;
local graph = grafana.graphPanel;

{
  panels:: [
    graphTemplates.overallGraph {
      title: 'Disk R/W Data',
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
          format: 'Bps',
          label: 'Bytes read (-) / write (+)',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          show: false,
        },
      ],
      linewidth: 1,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_read_bytes_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} bytes read',
        format: 'time_series',
      },
      {
        expr: 'irate(node_disk_written_bytes_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} bytes written',
        format: 'time_series',
      },
    ])
    .addSeriesOverride(
      {
        alias: '/.*bytes read$/',
        transform: 'negative-Y',
      },
    ),

    graphTemplates.overallGraph {
      title: 'Disk R/W Time (less than 100ms)',
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
          format: 's',
          label: 'Time read (-) / write (+)',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          show: false,
        },
      ],
      linewidth: 1,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 1.5 * defaults.blockWidth,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_reads_completed_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} reads completed',
        format: 'time_series',
      },
      {
        expr: 'irate(node_disk_writes_completed_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} writes completed',
        format: 'time_series',
      },
    ])
    .addSeriesOverride(
      {
        alias: '/.*reads completed$/',
        transform: 'negative-Y',
      },
    ),

    graphTemplates.overallGraph {
      title: 'Disk IOps Completed（IOPS）',
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
          format: 'iops',
          label: 'IO read (-) / write (+)',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
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
        expr: 'irate(node_disk_reads_completed_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} reads completed',
        format: 'time_series',
      },
      {
        expr: 'irate(node_disk_writes_completed_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} writes completed',
        format: 'time_series',
      },
    ]),

    graphTemplates.overallGraph {
      title: 'Time Spent Doing I/Os',
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
          format: 'percentunit',
          label: '',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          show: false,
        },
      ],
      linewidth: 1,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 3 * defaults.blockHeight,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_io_time_seconds_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: '{{device}} IO time',
        format: 'time_series',
      },
    ]),

    graphTemplates.overallGraph {
      title: 'Open file descriptors',
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
          format: 'short',
          label: 'used FDs',
          show: true,
        },
        {
          format: 'short',
          label: '',
          show: false,
        },
      ],
      linewidth: 1,
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 1.5 * defaults.blockWidth,
        y: 1.5 * defaults.blockHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: 'used FDs',
        color: colors.red,
      },
    )
    .addTargets([
      {
        expr: 'node_filefd_allocated{instance=~"$instance:.+"}',
        instant: false,
        legendFormat: 'used FDs',
        format: 'time_series',
      },
    ]),
  ],
}
