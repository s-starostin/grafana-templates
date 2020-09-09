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
    graphTemplates.stackGraph {
      title: 'Internet traffic per hour ($device)',
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 0,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'increase(node_network_receive_bytes_total{instance=~"$instance:.+",device=~"$device"}[60m])',
        format: 'time_series',
        interval: '60m',
        intervalFactor: 1,
        legendFormat: '{{device}} RX',
        step: 600,
      },
      {
        expr: 'increase(node_network_transmit_bytes_total{instance=~"$instance:.+",device=~"$device"}[60m])',
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
      title: 'Network bandwidth usage per second ($device)',
      gridPos: {
        h: 1.5 * defaults.blockHeight,
        w: 1.5 * defaults.blockWidth,
        x: 1.5 * defaults.blockWidth,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'label_replace(irate(node_network_receive_bytes_total{instance=~"$instance:.+",device=~"$device"}[5m])*8, "instance", "$1", "hostname", "(.*):.*")',
        format: 'time_series',
        interval: '',
        intervalFactor: 1,
        legendFormat: '{{device}} RX',
        step: 4,
      },
      {
        expr: 'label_replace(irate(node_network_transmit_bytes_total{instance=~"$instance:.+",device=~"$device"}[5m])*8, "instance", "$1", "hostname", "(.*):.*")',
        format: 'time_series',
        interval: '',
        intervalFactor: 1,
        legendFormat: '{{device}} TX',
        step: 4,
      },
    ])
    .addSeriesOverride(
      {
        alias: '/.* TX$/',
        transform: 'negative-Y',
      },
    )
    .resetYaxes()
    .addYaxis(format='bps', label='transmit(-)/receive(+)')
    .addYaxis(format='short', show=false),
  ],
}
