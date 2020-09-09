local grafana = import 'grafonnet/grafana.libsonnet';
local graph = grafana.graphPanel;

{
    overallGraph::
        graph.new(
          'template',
          datasource='${prometheus_datasource}',
          decimals=1,
          fill=0,
          linewidth=1,
        ) + {
          dashLength: 5,
          spaceLength: 5,
        }
    ,
    stackGraph::
        self.overallGraph {
          steppedLine: true,
          linewidth: 1,
          fill: 1,
        }
}