local table = import '../../.grafonnet-lib-custom/table_panel.libsonnet';
local transformation = import '../../.grafonnet-lib-custom/transformation.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

local diskSpaceUsedFieldConfig = {
  fieldConfig: {
    defaults: {
      custom: {
        align: null,
      },
      mappings: [
        {
          from: '',
          id: 0,
          text: '',
          to: '',
          type: 1,
          value: '',
        },
      ],
      thresholds: {
        mode: 'absolute',
        steps: [
          {
            color: 'green',
            value: null,
          },
          {
            color: 'red',
            value: 80,
          },
        ],
      },
    },
    overrides: [
      {
        matcher: {
          id: 'byName',
          options: 'Value #C',
        },
        properties: [
          {
            id: 'unit',
            value: 'decbytes',
          },
          {
            id: 'displayName',
            value: 'Total space',
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'Value #A',
        },
        properties: [
          {
            id: 'unit',
            value: 'decbytes',
          },
          {
            id: 'displayName',
            value: 'Available',
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'Value #B',
        },
        properties: [
          {
            id: 'unit',
            value: 'percent',
          },
          {
            id: 'displayName',
            value: 'Used',
          },
          {
            id: 'custom.displayMode',
            value: 'gradient-gauge',
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'mountpoint',
        },
        properties: [
          {
            id: 'custom.width',
            value: 147,
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'Total space',
        },
        properties: [
          {
            id: 'custom.width',
            value: 104,
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'Available',
        },
        properties: [
          {
            id: 'custom.width',
            value: 125,
          },
        ],
      },
      {
        matcher: {
          id: 'byName',
          options: 'Used',
        },
        properties: [
          {
            id: 'custom.width',
            value: 153,
          },
        ],
      },
    ],
  },
};

{
  new::
    (
      table.new(
        'Disk Space Used Basic(EXT?/XFS)',
        datasource='${prometheus_datasource}'
      )
      .addTargets([
        prometheus.target(
          'node_filesystem_avail_bytes {instance=~"$instance",fstype=~"ext.*|xfs",mountpoint !~".*pod.*"}-0',
          instant=true,
          legendFormat='free',
          format='table'
        ),
        prometheus.target(
          'with (cf={instance=~"$instance",fstype=~"ext.*|xfs",mountpoint !~".*pod.*"})(node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}) *100/(node_filesystem_avail_bytes {cf}+(node_filesystem_size_bytes{cf}-node_filesystem_free_bytes{cf}))',
          instant=true,
          legendFormat='used',
          format='table'
        ),
        prometheus.target(
          'node_filesystem_size_bytes{instance=~"$instance",fstype=~"ext.*|xfs",mountpoint !~".*pod.*"}-0',
          instant=true,
          legendFormat='max',
          format='table'
        ),
      ])
      .addTransformations([
        transformation.new('seriesToColumns', options={
          byField: 'mountpoint',
        }),
        transformation.new('filterFieldsByName', options={
          include: {
            names: [
              'Value #C',
              'Value #A',
              'Value #B',
              'mountpoint',
            ],
          },
        }),
      ])
      + diskSpaceUsedFieldConfig
    ),
}
