//Defaults
local colors = import '../../.defaults/colors.libsonnet';
local defaults = import '../../.defaults/parameters.libsonnet';

//Templates
local graphTemplates = import '../templates/graph.libsonnet';

local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local graph = grafana.graphPanel;

{
  panels:: [
    graphTemplates.overallGraph {
      title: 'Context switches / Interrupts',
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
          show: true,
        },
        {
          format: 'short',
          show: true,
        },
      ],
      linewidth: 1,
      tooltip: {
        shared: true,
        sort: 2,
        value_type: 'cumulative',
      },
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_context_switches_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        legendFormat: 'Context switches',
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'irate(node_intr_total{instance=~"$instance:.+"}[5m])',
        legendFormat: 'Interrupts',
        format: 'time_series',
        step: 20,
      },
    ]),

    graphTemplates.overallGraph {
      title: 'System Load',
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
          show: true,
          min: "0",
        },
        {
          format: 'short',
          show: true,
        },
      ],
      linewidth: 1,
      tooltip: {
        shared: true,
        sort: 2,
        value_type: 'cumulative',
      },
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 1.5 * defaults.blockWidth,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'node_load1{instance=~"$instance:.+"}',
        instant: false,
        legendFormat: 'Load 1m',
        intervalFactor: 4,
        format: 'time_series',
        step: 480
      },
      {
        expr: 'node_load5{instance=~"$instance:.+"}',
        legendFormat: 'Load 5m',
        intervalFactor: 4,
        format: 'time_series',
        step: 480
      },
      {
        expr: 'node_load15{instance=~"$instance:.+"}',
        legendFormat: 'Load 15m',
        intervalFactor: 4,
        format: 'time_series',
        step: 480
      },
    ]),
  ]
}
