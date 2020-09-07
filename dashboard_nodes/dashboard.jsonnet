//Defaults
local colors = import '../.defaults/colors.libsonnet';
local defaults = import '../.defaults/parameters.libsonnet';

//---
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;
local prometheus = grafana.prometheus;
local graph = grafana.graphPanel;

local dashboardLinks = import '../.snippets/dashboard_links.libsonnet';

local row = grafana.row.new(
  collapse=false,
);

local resourceOverview = import 'snippets/resource_overview.libsonnet';
local resourceDetails = import 'snippets/resource_details.libsonnet';
local diskSpaceUsed = import 'snippets/disk_space_used.libsonnet';

local overallGraph = graph.new(
  'template',
  datasource='${prometheus_datasource}',
  decimals=1,
  fill=0,
  linewidth=1,
) + {
  dashLength: 5,
  spaceLength: 5,
};

local stackGraph = overallGraph {
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
    'instance',
    '$prometheus_datasource',
    'label_values(node_uname_info,instance)',
    label='Instance',
    refresh=1,
    multi=true,
    includeAll=true,
    sort=1
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
.addTemplate(
  template.new(
    'node',
    '$prometheus_datasource',
    'label_values(node_uname_info{nodename=~"$instance"},instance)',
    label='Instance',
    refresh='load',
    multi=true,
    hide=2,
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
    title: 'Resource Details ($instance)',
    repeat: 'instance',
    collapse: true,
    collapsed: true,
    gridPos: {
      h: 1,
      w: 3 * defaults.blockDefaultWidth,
      x: 0,
      y: 2 * defaults.blockDefaultHeight + 1,
    },
    titleSize: 'h1',
  }.addPanels([
    resourceDetails.new {
      gridPos: { h: 0.5 * defaults.blockDefaultHeight, w: 1.5 * defaults.blockDefaultWidth, x: 0, y: 0 },
    },

    diskSpaceUsed.new {
      gridPos: { h: 0.5 * defaults.blockDefaultHeight, w: 1.5 * defaults.blockDefaultWidth, x: 1.5 * defaults.blockDefaultWidth, y: 0 },
    },

    overallGraph {
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
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 0,
        y: 0.5 * defaults.blockDefaultHeight,
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
        expr: 'avg(irate(node_cpu_seconds_total{instance=~"$instance",mode="system"}[5m])) by (instance) *100',
        instant: false,
        legendFormat: 'System',
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'avg(irate(node_cpu_seconds_total{instance=~"$instance",mode="user"}[5m])) by (instance) *100',
        instant: false,
        legendFormat: 'User',
        format: 'time_series',
        step: 240,
      },
      {
        expr: 'avg(irate(node_cpu_seconds_total{instance=~"$instance",mode="iowait"}[5m])) by (instance) *100',
        instant: false,
        legendFormat: 'IOWait',
        format: 'time_series',
        step: 240,
      },
      {
        expr: '(1 - avg(irate(node_cpu_seconds_total{instance=~"$instance",mode="idle"}[5m])) by (instance))*100',
        instant: false,
        legendFormat: 'Total',
        format: 'time_series',
        step: 240,
      },
    ]),

    overallGraph {
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
          format: 'bytes',
          label: null,
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
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 1.5 * defaults.blockDefaultWidth,
        y: 0.5 * defaults.blockDefaultHeight,
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
        expr: 'node_memory_MemTotal_bytes{instance=~"$instance"}',
        instant: false,
        legendFormat: 'Total',
        format: 'time_series',
        step: 4,
      },
      {
        expr: 'with (cf={instance=~"$instance"}) (node_memory_MemTotal_bytes{cf} - node_memory_MemAvailable_bytes{cf})',
        legendFormat: 'Used',
        format: 'time_series',
        step: 4,
      },
      {
        expr: 'node_memory_MemAvailable_bytes{instance=~"$instance"}',
        legendFormat: 'Avaliable',
        format: 'time_series',
        step: 4,
      },
      {
        expr: 'with (cf={instance=~"$instance"}) (1 - (node_memory_MemAvailable_bytes{cf} / (node_memory_MemTotal_bytes{cf})))* 100',
        instant: false,
        legendFormat: 'Used%',
        format: 'time_series',
        intervalFactor: 10,
        step: 4,
      },
    ]),

    overallGraph {
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
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 0,
        y: 2 * defaults.blockDefaultHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: '/.*CPU cores/',
        color: '#C4162A',
        dashes: true,
        fill: 0,
        fillGradient: 0,
        lines: true,
        linewidth: 1,
      },
    )
    .addTargets([
      {
        expr: 'node_load1{instance=~"$instance"}',
        instant: false,
        legendFormat: '1m',
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'node_load5{instance=~"$instance"}',
        legendFormat: '5m',
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'node_load15{instance=~"$instance"}',
        legendFormat: '15m',
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'sum(count(node_cpu_seconds_total{instance=~"$instance", mode="system"}) by (cpu,instance)) by(instance)',
        instant: false,
        legendFormat: 'CPU cores',
        format: 'time_series',
        intervalFactor: 1,
        step: 20,
      },
    ]),

    overallGraph {
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
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 1.5 * defaults.blockDefaultWidth,
        y: 2 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_context_switches_total{instance=~"$instance"}[5m])',
        instant: false,
        legendFormat: 'Context switches',
        format: 'time_series',
        step: 20,
      },
      {
        expr: 'irate(node_intr_total{instance=~"$instance"}[5m])',
        legendFormat: 'Interrupts',
        format: 'time_series',
        step: 20,
      },
    ]),

    overallGraph {
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
        h: 1 * defaults.blockDefaultHeight,
        w: 1 * defaults.blockDefaultWidth,
        x: 0,
        y: 3.5 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'with (cf={instance=~"$instance",fstype=~"ext.*|xfs",mountpoint !~".*pod.*"}) (node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}) *100/(node_filesystem_avail_bytes {cf}+(node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}))',
        instant: false,
        legendFormat: '{{mountpoint}}',
        format: 'time_series',
      },
    ]),

    overallGraph {
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
        h: 1 * defaults.blockDefaultHeight,
        w: 1 * defaults.blockDefaultWidth,
        x: 1 * defaults.blockDefaultWidth,
        y: 4.5 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_read_bytes_total{instance=~"$instance"}[5m])',
        instant: false,
        legendFormat: '{{device}} bytes read',
        format: 'time_series',
      },
      {
        expr: 'irate(node_disk_written_bytes_total{instance=~"$instance"}[5m])',
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

    overallGraph {
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
        h: 1 * defaults.blockDefaultHeight,
        w: 1 * defaults.blockDefaultWidth,
        x: 2 * defaults.blockDefaultWidth,
        y: 4.5 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_reads_completed_total{instance=~"$instance"}[5m])',
        instant: false,
        legendFormat: '{{device}} reads completed',
        format: 'time_series',
      },
      {
        expr: 'irate(node_disk_writes_completed_total{instance=~"$instance"}[5m])',
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

    overallGraph {
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
        h: 1 * defaults.blockDefaultHeight,
        w: 1 * defaults.blockDefaultWidth,
        x: 0,
        y: 4.5 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_reads_completed_total{instance=~"$instance"}[5m])',
        instant: false,
        legendFormat: '{{device}} reads completed',
        format: 'time_series',
      },
    ])
    .addTargets([
      {
        expr: 'irate(node_disk_writes_completed_total{instance=~"$instance"}[5m])',
        instant: false,
        legendFormat: '{{device}} writes completed',
        format: 'time_series',
      },
    ]),

    overallGraph {
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
        h: 1 * defaults.blockDefaultHeight,
        w: 1 * defaults.blockDefaultWidth,
        x: 1 * defaults.blockDefaultWidth,
        y: 4.5 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'irate(node_disk_io_time_seconds_total{instance=~"$instance"}[5m])',
        instant: false,
        legendFormat: '{{device}} IO time',
        format: 'time_series',
      },
    ]),

    overallGraph {
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
        h: 1 * defaults.blockDefaultHeight,
        w: 1 * defaults.blockDefaultWidth,
        x: 2 * defaults.blockDefaultWidth,
        y: 4.5 * defaults.blockDefaultHeight,
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
        expr: 'node_filefd_allocated{instance=~"$instance"}',
        instant: false,
        legendFormat: 'used FDs',
        format: 'time_series',
      },
    ]),

    overallGraph {
      title: 'Network Traffic Drop',
      decimals: 2,
      legend: {
        alignAsTable: true,
        avg: true,
        current: true,
        max: true,
        min: true,
        rightSide: false,
        show: true,
        sideWidth: 300,
        sort: 'current',
        sortDesc: true,
        total: false,
        values: true,
      },
      yaxes: [
        {
          decimals: null,
          format: 'pps',
          label: 'packets out (-) / in (+)',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          show: false,
        },
      ],
      linewidth: 2,
      gridPos: {
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 0,
        y: 5.5 * defaults.blockDefaultHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: '/.*TX.*/',
        transform: 'negative-Y',
      },
    )
    .addTargets([
      {
        expr: 'irate(node_network_receive_drop_total{instance=~"$instance",device=~"$device"}[5m])',
        instant: false,
        legendFormat: '{{device}} RX drops',
        format: 'time_series',
      },
    ])
    .addTargets([
      {
        expr: 'irate(node_network_transmit_drop_total{instance=~"$instance",device=~"$device"}[5m])',
        instant: false,
        legendFormat: '{{device}} TX drops',
        format: 'time_series',
      },
    ]),

    overallGraph {
      title: 'Network Traffic Errors',
      decimals: 2,
      legend: {
        alignAsTable: true,
        avg: true,
        current: true,
        max: true,
        min: true,
        rightSide: false,
        show: true,
        sideWidth: 300,
        sort: 'current',
        sortDesc: true,
        total: false,
        values: true,
      },
      yaxes: [
        {
          format: 'pps',
          label: 'packets out (-) / in (+)',
          logBase: 1,
          show: true,
        },
        {
          format: 'short',
          show: false,
        },
      ],
      linewidth: 2,
      gridPos: {
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 1.5 * defaults.blockDefaultWidth,
        y: 5.5 * defaults.blockDefaultHeight,
      },
    }
    .addSeriesOverride(
      {
        alias: '/.*TX.*/',
        transform: 'negative-Y',
      },
    )
    .addTargets([
      {
        expr: 'irate(node_network_receive_errs_total{instance=~"$instance",device=~"$device"}[5m])',
        instant: false,
        legendFormat: '{{device}} RX errors',
        format: 'time_series',
      },
    ])
    .addTargets([
      {
        expr: 'irate(node_network_transmit_errs_total{instance=~"$instance",device=~"$device"}[5m])',
        instant: false,
        legendFormat: '{{device}} TX errors',
        format: 'time_series',
      },
    ]),

    stackGraph {
      title: 'Internet traffic per hour ($device)',
      gridPos: {
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 0,
        y: 6 * defaults.blockDefaultHeight + 2,
      },
    }
    .addTargets([
      {
        expr: 'increase(node_network_receive_bytes_total{instance=~"$instance",device=~"$device"}[60m])',
        format: 'time_series',
        interval: '60m',
        intervalFactor: 1,
        legendFormat: '{{device}} RX',
        step: 600,
      },
      {
        expr: 'increase(node_network_transmit_bytes_total{instance=~"$instance",device=~"$device"}[60m])',
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
    .addYaxis(format='bytes', label='transmit(-)/receive(+)')
    .addYaxis(format='short', show=false),

    stackGraph {
      title: 'Network bandwidth usage per second ($device)',
      gridPos: {
        h: 1.5 * defaults.blockDefaultHeight,
        w: 1.5 * defaults.blockDefaultWidth,
        x: 1.5 * defaults.blockDefaultWidth,
        y: 6 * defaults.blockDefaultHeight,
      },
    }
    .addTargets([
      {
        expr: 'label_replace(irate(node_network_receive_bytes_total{instance=~"$instance",device=~"$device"}[5m])*8, "instance", "$1", "hostname", "(.*):.*")',
        format: 'time_series',
        interval: '',
        intervalFactor: 1,
        legendFormat: '{{device}} RX',
        step: 4,
      },
      {
        expr: 'label_replace(irate(node_network_transmit_bytes_total{instance=~"$instance",device=~"$device"}[5m])*8, "instance", "$1", "hostname", "(.*):.*")',
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


  ]),
])
+ dashboardLinks
