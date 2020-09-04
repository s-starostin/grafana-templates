//Defaults
local colors = import '../.defaults/colors.libsonnet';
local defaults = import '../.defaults/parameters.libsonnet';

//---
local grafana = import '../grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local prometheus = grafana.prometheus;
local graph = grafana.graphPanel;

local dashboardLinks = import '../.snippets/dashboard_links.libsonnet';

local row = grafana.row.new(
  collapse=false,
);

local resourceOverview = import 'snippets/resource_overview.libsonnet';

local overallGraph = graph.new(
  'template',
  datasource='${prometheus_datasource}',
  decimals=1,
  fill=0,
  linewidth=2,
) + {
  dashLength: 5,
  spaceLength: 5,
};

local stackGraph = overallGraph{
    steppedLine: true,
    linewidth: 1,
    fill: 1,
};

dashboard.new(
  'Nodes',
  schemaVersion=26,
  editable=true,
  refresh=false,
  uid='dtcrt-nodes',
  time_from='now-24h',
)
.addTemplate(
  grafana.template.datasource(
    'prometheus_datasource',
    'prometheus',
    'Prometheus',
    hide='label',
  )
)
.addTemplate(
  template.new(
    'hostname',
    '$prometheus_datasource',
    'label_values(node_uname_info, nodename)',
    label='Hostname',
    refresh=1,
	includeAll=true
  )
)
.addTemplate(
  template.new(
    'node',
    '$prometheus_datasource',
    'label_values(node_uname_info{nodename=~\"$hostname\"},instance)',
    label='Instance',
    refresh=1,
	multi=true,
	includeAll=true
  )
)
.addTemplate(
  template.new(
    'device',
    '$prometheus_datasource',
    "label_values(node_network_info{device!~'tap.*|veth.*|br.*|docker.*|virbr.*|lo.*|cni.*'},device)",
    label='NIC',
    refresh=1,
	multi=true,
	includeAll=true
  )
)
.addPanels([
  row {
    title: 'Resource Overview',
    gridPos: { h: 1, w: 3 * defaults.blockDefaultWidth, x: 0, y: 0 },
    titleSize: 'h1',
  },

  resourceOverview.new {
    gridPos: { h: defaults.blockDefaultHeight, w: 3 * defaults.blockDefaultWidth, x: 0, y: 1 },
  },

  overallGraph {
    title: 'Overall total 5m load & average CPU used%',
    gridPos: {
      h: defaults.blockDefaultHeight,
      w: defaults.blockDefaultWidth,
      x: 0,
      y: defaults.blockDefaultHeight + 1,
    },
  }
  .addTargets([
    {
      expr: 'count(node_cpu_seconds_total{job="node_exporter", mode="system"})',
      format: 'time_series',
      interval: '',
      intervalFactor: 1,
      legendFormat: 'CPU Cores',
      step: 240,
    },
    {
      expr: 'sum(node_load5{job="node_exporter"})',
      format: 'time_series',
      interval: '',
      intervalFactor: 1,
      legendFormat: 'Total 5m load',
      step: 240,
    },
    {
      expr: 'avg(1 - avg(irate(node_cpu_seconds_total{job="node_exporter",mode="idle"}[5m])) by (instance)) * 100',
      format: 'time_series',
      interval: '30m',
      intervalFactor: 1,
      legendFormat: 'Overall average used%',
      step: 240,
    },
  ])
  .addSeriesOverride(
    {
      alias: 'CPU Cores',
      color: colors.red,
      dashes: true,
      linewidth: 1,
    },
  )
  .addSeriesOverride(
    {
      alias: 'Total 5m load',
      color: colors.yellow,
    },
  )
  .addSeriesOverride(
    {
      alias: 'Overall average used%',
      color: colors.green,
      lines: true,
      linewidth: 1,
      fill: 1,
      yaxis: 2,
    }
  )
  .resetYaxes()
  .addYaxis(format='short', label='Total 5m load')
  .addYaxis(format='percent', label='Overall average used%'),

  overallGraph {
    title: 'Overall total memory & average memory used%',
    gridPos: {
      h: defaults.blockDefaultHeight,
      w: defaults.blockDefaultWidth,
      x: defaults.blockDefaultWidth,
      y: defaults.blockDefaultHeight + 1,
    },
  }
  .addTargets([
    {
      expr: 'sum(node_memory_MemTotal_bytes{job="node_exporter"})',
      format: 'time_series',
      interval: '',
      intervalFactor: 1,
      legendFormat: 'Total',
      step: 4,
    },
    {
      expr: 'sum(node_memory_MemTotal_bytes{job="node_exporter"} - node_memory_MemAvailable_bytes{job="node_exporter"})',
      format: 'time_series',
      interval: '',
      intervalFactor: 1,
      legendFormat: 'Total used',
      step: 4,
    },
    {
      expr: '(sum(node_memory_MemTotal_bytes{job="node_exporter"} - node_memory_MemAvailable_bytes{job="node_exporter"}) / sum(node_memory_MemTotal_bytes{job="node_exporter"}))*100',
      format: 'time_series',
      interval: '30m',
      intervalFactor: 1,
      legendFormat: 'Overall average used%',
    },
  ])
  .addSeriesOverride(
    {
      alias: 'Total',
      color: colors.red,
      dashes: true,
      linewidth: 1,
    },
  )
  .addSeriesOverride(
    {
      alias: 'Total used',
      color: colors.yellow,
    },
  )
  .addSeriesOverride(
    {
      alias: 'Overall average used%',
      color: colors.green,
      lines: true,
      linewidth: 1,
      fill: 1,
      yaxis: 2,
    }
  )
  .resetYaxes()
  .addYaxis(format='bytes', label='Total')
  .addYaxis(format='percent', label='Overall average used%'),

  overallGraph {
    title: 'Overall total disk & average disk used%',
    gridPos: {
      h: defaults.blockDefaultHeight,
      w: defaults.blockDefaultWidth,
      x: defaults.blockDefaultWidth * 2,
      y: defaults.blockDefaultHeight + 1,
    },
  }
  .addTargets([
    {
      expr: 'sum(avg(node_filesystem_size_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance))',
      format: 'time_series',
      interval: '',
      intervalFactor: 1,
      legendFormat: 'Total',
    },
    {
      expr: 'sum(avg(node_filesystem_size_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance)) - sum(avg(node_filesystem_free_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance))',
      format: 'time_series',
      interval: '',
      intervalFactor: 1,
      legendFormat: 'Total used',
    },
    {
      expr: '(sum(avg(node_filesystem_size_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance)) - sum(avg(node_filesystem_free_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance))) *100/(sum(avg(node_filesystem_avail_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance))+(sum(avg(node_filesystem_size_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance)) - sum(avg(node_filesystem_free_bytes{job="node_exporter",fstype=~"xfs|ext.*"})by(device,instance))))',
      format: 'time_series',
      interval: '30m',
      intervalFactor: 1,
      legendFormat: 'Overall average used%',
    },
  ])
  .addSeriesOverride(
    {
      alias: 'Total',
      color: colors.red,
      dashes: true,
      linewidth: 1,
    },
  )
  .addSeriesOverride(
    {
      alias: 'Total used',
      color: colors.yellow,
    },
  )
  .addSeriesOverride(
    {
      alias: 'Overall average used%',
      color: colors.green,
      lines: true,
      linewidth: 1,
      fill: 1,
      yaxis: 2,
    }
  )
  .resetYaxes()
  .addYaxis(format='bytes', label='Total')
  .addYaxis(format='percent', label='Overall average used%'),

  row {
    title: 'Resource Details ($node)',
    gridPos: {
      h: 1,
      w: 3 * defaults.blockDefaultWidth,
      x: 0,
      y: 2 * defaults.blockDefaultHeight + 1,
    },
    titleSize: 'h1',
  },

  stackGraph {
    title: 'Internet traffic per hour ($device)',
    gridPos: {
      h: 1.5 * defaults.blockDefaultHeight,
      w: 1.5 * defaults.blockDefaultWidth,
      x: 0,
      y: 2 * defaults.blockDefaultHeight + 2,
    },
  }
  .addTargets([
    {
      expr: 'increase(node_network_receive_bytes_total{instance=~"$node",device=~"$device"}[60m])',
      format: 'time_series',
      interval: "60m",
      intervalFactor: 1,
      legendFormat: '{{instance}} {{device}} RX',
      step: 600,
    },
    {
      expr: 'increase(node_network_transmit_bytes_total{instance=~"$node",device=~"$device"}[60m])',
      format: 'time_series',
      interval: "60m",
      intervalFactor: 1,
      legendFormat: '{{instance}} {{device}} TX',
      step: 600,
    },
  ])
  .addSeriesOverride(
    {
      alias: "/.* TX$/",
      transform: "negative-Y"
    },
  )
  .resetYaxes()
  .addYaxis(format='bytes', label='transmit(-)/receive(+)')
  .addYaxis(format='short',show=false),

  stackGraph {
    title: 'Network bandwidth usage per second ($device)',
    gridPos: {
      h: 1.5 * defaults.blockDefaultHeight,
      w: 1.5 * defaults.blockDefaultWidth,
      x: 1.5 * defaults.blockDefaultWidth,
      y: 2 * defaults.blockDefaultHeight + 2,
    },
  }
  .addTargets([
    {
      expr: 'irate(node_network_receive_bytes_total{instance=~"$node",device=~"$device"}[5m])*8',
      format: 'time_series',
      interval: "",
      intervalFactor: 1,
      legendFormat: '{{instance}} {{device}} RX',
      step: 4,
    },
    {
      expr: 'irate(node_network_transmit_bytes_total{instance=~"$node",device=~"$device"}[5m])*8',
      format: 'time_series',
      interval: "",
      intervalFactor: 1,
      legendFormat: '{{instance}} {{device}} TX',
      step: 4,
    },
  ])
  .addSeriesOverride(
    {
      alias: "/.* TX$/",
      transform: "negative-Y"
    },
  )
  .resetYaxes()
  .addYaxis(format='bps', label='transmit(-)/receive(+)')
  .addYaxis(format='short',show=false),
])
+ dashboardLinks
