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
      title: 'CPU',
      fill: 4,
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
          logBase: 1,
          label: "percentage",
          max: "100",
          min: "0",
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
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"system",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        interval: "10s",
        intervalFactor: 2,
        legendFormat: "System - Processes executing in kernel mode",
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"user",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "User - Normal processes executing in user mode",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"nice",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "Nice - Niced processes executing in user mode",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"idle",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "Idle - Waiting for something to happen",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"iowait",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "IOWait - Waiting for I/O to complete",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"irq",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "IRQ - Servicing interrupts",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"softirq",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "Softirq - Servicing softirqs",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"steal",instance=~"$instance:.+"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "Steal - Time spent in other operating systems when running in a virtualized environment",
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'sum by (mode)(irate(node_cpu_seconds_total{mode=~"guest",instance=~"$node",job=~"$job"}[5m])) * 100',
        instant: false,
        intervalFactor: 2,
        legendFormat: "Guest - Time spent running a virtual CPU for a guest operating system",
        format: 'time_series',
        step: 240,
      },
    ]),

    graphTemplates.overallGraph {
      title: 'CPU time spent in user and system contexts',
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
          format: "s",
          label: "seconds",
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
        x: 1.5 * defaults.blockWidth,
        y: 0,
      },
    }
    .addTargets([
      {
        expr: 'irate(process_cpu_seconds_total{instance=~"$instance:.+"}[5m])',
        instant: false,
        intervalFactor: 2,
        legendFormat: "Time spent",
        format: 'time_series',
        step: 20,
      }
    ]),
  ],
}
