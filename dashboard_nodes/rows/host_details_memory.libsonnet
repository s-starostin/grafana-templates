//Defaults
local colors = import '../../.defaults/colors.libsonnet';
local defaults = import '../../.defaults/parameters.libsonnet';

//Templates
local graphTemplates = import '../templates/graph.libsonnet';

local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local stat = grafana.statPanel;

{
  panels:: [
    graphTemplates.overallGraph {
      title: 'Basic memory usage',
      decimals: 2,
      legend: {
        alignAsTable: false,
        sideWidth: 350,
        hideEmpty: true,
      },
      yaxes: [
        {
          format: 'decbytes',
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
        x: 0,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'node_memory_MemTotal_bytes{instance=~"$instance:.+",job="node_exporter"}',
        instant: false,
        legendFormat: 'RAM Total',
        intervalFactor: 4,
        format: 'time_series',
        step: 240
      },
      {
        expr: 'node_memory_MemTotal_bytes{instance=~"$instance:.+",job="node_exporter"} - node_memory_MemFree_bytes{instance=~"$instance:.+",job="node_exporter"} - (node_memory_Cached_bytes{instance=~"$instance:.+",job="node_exporter"} + node_memory_Buffers_bytes{instance=~"$instance:.+",job="node_exporter"})',
        legendFormat: 'RAM Used',
        intervalFactor: 4,
        format: 'time_series',
        step: 240
      },
      {
        expr: 'node_memory_Cached_bytes{instance=~"$instance:.+",job="node_exporter"} + node_memory_Buffers_bytes{instance=~"$instance:.+",job="node_exporter"}',
        legendFormat: 'RAM Cache + Buffer',
        intervalFactor: 4,
        format: 'time_series',
        step: 240
      },
      {
        expr: 'node_memory_MemFree_bytes{instance=~"$instance:.+",job="node_exporter"}',
        legendFormat: 'RAM Free',
        intervalFactor: 4,
        format: 'time_series',
        step: 240
      },
      {
        expr: '(node_memory_SwapTotal_bytes{instance=~"$instance:.+",job="node_exporter"} - node_memory_SwapFree_bytes{instance=~"$instance:.+",job="node_exporter"})',
        legendFormat: 'SWAP Used',
        intervalFactor: 4,
        format: 'time_series',
        step: 240
      },
    ]),

    graphTemplates.overallGraph {
      title: 'OOM Killer',
      decimals: 0,
      hiddenSeries: false,
      legend: {
        alignAsTable: true,
        avg: true,
        current: true,
        hideZero: true,
        show: true,
        min: true,
        max: true,
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
        expr: 'irate(node_vmstat_oom_kill{instance=~"$instance:.+",job=~"node_exporter"}[5m])',
        instant: false,
        legendFormat: 'OOM killer invocations',
        intervalFactor: 2,
        format: 'time_series',
        step: 4
      }
    ]),
  ],
}
