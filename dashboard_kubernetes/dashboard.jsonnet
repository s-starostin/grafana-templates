local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;

local dashboardLinks = import '../.snippets/dashboard_links.libsonnet';

dashboard.new(
  'Kubernetes',
  schemaVersion=26,
  editable=true,
  refresh=false,
  uid='dtcrt-kubernetes',
  time_from='now-24h',
)
+ dashboardLinks
