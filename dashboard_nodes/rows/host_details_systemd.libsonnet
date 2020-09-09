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
      title: 'Systemd Units State',
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
          label: 'counter',
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
        expr: 'node_systemd_units{instance=~"$instance:.+",job=~"node_exporter",state=~"activating"}',
        instant: false,
        intervalFactor: 2,
        legendFormat: 'Activating',
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'node_systemd_units{instance=~"$instance:.+",job=~"node_exporter",state=~"active"}',
        instant: false,
        intervalFactor: 2,
        legendFormat: 'Active',
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'node_systemd_units{instance=~"$instance:.+",job=~"node_exporter",state=~"deactivating"}',
        instant: false,
        intervalFactor: 2,
        legendFormat: 'Deactivating',
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'node_systemd_units{instance=~"$instance:.+",job=~"node_exporter",state=~"failed"}',
        instant: false,
        intervalFactor: 2,
        legendFormat: 'Failed',
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'node_systemd_units{instance=~"$instance:.+",job=~"node_exporter",state=~"inactive"}',
        instant: false,
        intervalFactor: 2,
        legendFormat: 'Inactive',
        format: 'time_series',
        step: 240,
      },
    ]),
  ],
}
