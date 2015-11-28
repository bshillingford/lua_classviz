return function(arg, main)
  -- Page template:
  -- (based on 'sticky force layout': http://bl.ocks.org/mbostock/3750558)
  local function generate_html(nodes, links)
    return string.format([[<!DOCTYPE html>
    <head>
    <meta charset="utf-8">
    <style>
    * {
      font-family: roboto, verdana, arial, sans-serif;
      overflow: visible;
    }
    .link {
      stroke: #000;
      stroke-width: 1.5px;
    }
    .node rect {
      cursor: move;
      fill: #fff;
    }
    .node.fixed rect {
      fill: #faa;
    }
    .node text {
      text-anchor: middle;
      opacity: 0.6;
      fill: #000;
      font-size: 0.8em;
    }
    text.mouseover {
      opacity: 1.0;
      z-order: 1000;
      fill: blue;
      font-size: 1.3em;
    }
    </style>
    </head>
    <body>

    <script src="d3.v3.min.js"></script>
    <script>
    var width = 1024,
        height = 650;

    var force = d3.layout.force()
        .size([width, height])
        .charge(-500)
        .linkDistance(85)
        .on("tick", tick);

    var drag = force.drag()
        .on("dragstart", function(d) {
          d3.select(this).classed("fixed", d.fixed = true);
        });

    var svg = d3.select("body").append("svg")
        .attr("width", width)
        .attr("height", height);

    var link = svg.selectAll(".link"),
        node = svg.selectAll(".node");

    var graph = {
      "nodes":%s,
      "links":%s
    };

    force.nodes(graph.nodes)
         .links(graph.links)
         .start();

    var link = link.data(graph.links)
      .enter().append("line")
        .attr("class", "link")
        .attr("marker-end", "url(#arrowGray)");

    var defs = svg.append('defs');
    defs.append("marker")
        .attr("id", "arrowGray")
        .attr("viewBox", "0 0 10 10")
        .attr("refX", "10")
        .attr("refY", "5")
        .attr("markerUnits", "strokeWidth")
        .attr("markerWidth", "10")
        .attr("markerHeight", "5")
        .attr("orient", "auto")
        .append("path")
        .attr("d", "M 0 0 L 10 5 L 0 10 z")
        .attr("fill", "#000");

    var node = node.data(graph.nodes)
      .enter().append("svg")
        .on("dblclick", function(d) {
          d3.select(this).classed("fixed", d.fixed = false);
        })
        .attr("class", "node")
        .call(drag);
    var node_text = node.append('text')
        .attr("dy", ".35em")
        .text(function(d) { return d.text; })
        .on("mouseover", function() {
          d3.select(this).classed("mouseover", true);
        })
        .on("mouseout", function() {
          d3.select(this).classed("mouseover", false);
        });

    function tick() {
      link.attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; });
      node.attr("x", function(d) { return d.x; })
          .attr("y", function(d) { return d.y; });
    }
    </script>
    </body>
    </html>
  ]], nodes, links)
  end

  -- TODO: use a json library
  local nodes = {}
  local node_next_index = 0
  local node_index_map = {}
  local links = {}
  main(arg, function(node)
    node_index_map[node] = node_next_index
    node_next_index = node_next_index + 1
    table.insert(nodes, string.format('{"text": "%s"}', node))
  end, function(child, parent)
    table.insert(links, string.format('{"source": %d, "target": %d}', 
          node_index_map[child],
          node_index_map[parent]))
  end)
  io.write(generate_html(
    '[\n' .. table.concat(nodes, ',') .. ']',
    '[\n' .. table.concat(links, ',') .. ']'))
  io.flush()
end

