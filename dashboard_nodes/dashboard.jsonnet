local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local template = grafana.template;

local dashboardLinks = import '../.snippets/dashboard_links.libsonnet';

local resourceOverview = import 'rows/resource_overview.libsonnet';
local resourceDetails = import 'rows/resource_details.libsonnet';
local hostDetailsCPU = import 'rows/host_details_cpu.libsonnet';
local hostDetailsMemory = import 'rows/host_details_memory.libsonnet';
local hostDetailsDisk = import 'rows/host_details_disk.libsonnet';
local hostDetailsNetwork = import 'rows/host_details_network.libsonnet';
local hostDetailsSystem = import 'rows/host_details_system.libsonnet';
local hostDetailsSystemd = import 'rows/host_details_systemd.libsonnet';

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
    regex='/(.*):/',
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
.addPanels(
  [
    row.new(
      title='Resource overview',
      collapse=false,
      titleSize='h1',
      //Для row с collapsed=false дочерние панели должны быть на одном уровне с row
    ),
  ] + resourceOverview.panels
)
.addPanels([
  row.new(
    title='Resource Details ($instance)',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    resourceDetails.panels
  ),
])
.addPanels([
  row.new(
    title='Host details ($instance) - CPU',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    hostDetailsCPU.panels
  ),
])
.addPanels([
  row.new(
    title='Host details ($instance) - Memory',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    hostDetailsMemory.panels
  ),
])
.addPanels([
  row.new(
    title='Host details ($instance) - Disk',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    hostDetailsDisk.panels
  ),
])
.addPanels([
  row.new(
    title='Host details ($instance) - Network',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    hostDetailsNetwork.panels
  ),
])
.addPanels([
  row.new(
    title='Host details ($instance) - System',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    hostDetailsSystem.panels
  ),
])
.addPanels([
  row.new(
    title='Host details ($instance) - Systemd',
    collapse=true,
    repeat='instance',
    titleSize='h1',
  ).addPanels(
    hostDetailsSystemd.panels
  ),
])
+ dashboardLinks
