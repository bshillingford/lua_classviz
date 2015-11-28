return function(arg, main)
  -- based on htmld3force.lua and http://www.d3noob.org/2014/01/tree-diagrams-in-d3js_11.html
  local function generate_html(treejson)
    return string.format([[<!DOCTYPE html>
<head>
<meta charset="utf-8">
<style>
  * {
    font-family: roboto, verdana, arial, sans-serif;
    font-size: 0.95em;
    /*overflow: visible;*/
  }
  .node circle {
   fill: #fff;
   stroke: steelblue;
   stroke-width: 3px;
  }
  .node text { }
  .link {
   fill: none;
   stroke: #ccc;
   stroke-width: 2px;
  }
</style>
</head>
<body>
<script src="d3.v3.min.js"></script>
<script>
var root = %s;
</script>
<script>
var m = [20, 120, 20, 120],
    w = 1280 - m[1] - m[3],
    h = 800 - m[0] - m[2],
    i = 0;

var tree = d3.layout.tree()
    .size([h, w]);

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });

var svg = d3.select("body").append("svg:svg")
    .attr("width", w + m[1] + m[3])
    .attr("height", h + m[0] + m[2]);
var vis = svg.append("svg:g")
    .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

// root initialized above with the html
root.x0 = h / 2;
root.y0 = 0;

update(root);
    
function update(source) {
  var duration = d3.event && d3.event.altKey ? 5000 : 500;

  // compute the new height
  var levelWidth = [1];
  var childCount = function(level, n) {
    
    if(n.children && n.children.length > 0) {
      if(levelWidth.length <= level + 1) levelWidth.push(0);
      
      levelWidth[level+1] += n.children.length;
      n.children.forEach(function(d) {
        childCount(level + 1, d);
      });
    }
  };
  childCount(0, root);  
  var newHeight = d3.max(levelWidth) * 20; // 20 pixels per line  
  svg.attr("height", newHeight + m[0] + m[2]);
  tree = tree.size([newHeight, w]);
    
  // Compute the new tree layout.
  var nodes = tree.nodes(root).reverse();

  // Normalize for fixed-depth.
  nodes.forEach(function(d) { d.y = d.depth * 180; });

  // Update the nodes
  var node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter any new nodes at the parent's previous position.
  var nodeEnter = node.enter().append("svg:g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
      .on("click", function(d) { toggle(d); update(d); });

  nodeEnter.append("svg:circle")
      .attr("r", 1e-6)
      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

  nodeEnter.append("svg:text")
      .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
      .attr("dy", ".35em")
      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .text(function(d) { return d.name; })
      .style("fill-opacity", 1e-6);

  // Transition nodes to their new position.
  var nodeUpdate = node.transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeUpdate.select("circle")
      .attr("r", 4.5)
      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

  nodeUpdate.select("text")
      .style("fill-opacity", 1);

  // Transition exiting nodes to the parent's new position.
  var nodeExit = node.exit().transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
      .remove();

  nodeExit.select("circle")
      .attr("r", 1e-6);

  nodeExit.select("text")
      .style("fill-opacity", 1e-6);

  // Update the links…
  var link = vis.selectAll("path.link")
      .data(tree.links(nodes), function(d) { return d.target.id; });

  // Enter any new links at the parent's previous position.
  link.enter().insert("svg:path", "g")
      .attr("class", "link")
      .attr("d", function(d) {
        var o = {x: source.x0, y: source.y0};
        return diagonal({source: o, target: o});
      })
    .transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition links to their new position.
  link.transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition exiting nodes to the parent's new position.
  link.exit().transition()
      .duration(duration)
      .attr("d", function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal({source: o, target: o});
      })
      .remove();

  // Stash the old positions for transition.
  nodes.forEach(function(d) {
    d.x0 = d.x;
    d.y0 = d.y;
  });
}

// Toggle children.
function toggle(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
}
		</script>
    </body>
    </html>
  ]], treejson)
  end

  -- TODO: use a json library
  local function json_strescape(s)
    -- TODO: escape strings
    return string.format('"%s"', s)
  end
  local function json(o)
    local typ = type(o)
    if typ == 'table' then
      if #o > 0 then  -- array-style table
        local result = {}
        for i,o_i in ipairs(o) do
          result[i] = json(o_i)
        end
        return '[' .. table.concat(result, ',') .. ']'
      else -- object-style table
        local result = {}
        for k,v in pairs(o) do
          assert(type(k) == 'string', 'object keys must be strings')
          table.insert(result, json_strescape(k)..':'..json(v))
        end
				-- FIXME: heuristic: if it's empty, it's array-style still.
				if #result == 0 then
					return '[]'
        end
        return '{' .. table.concat(result, ',') .. '}'
      end
    elseif typ == 'number' then
      return tostring(o)
    elseif typ == 'string' then
      return json_strescape(o)
    else
      error('json generator: not implemented or invalid')
    end
  end

  local name_to_treenode = {
    root={
      name='<root>',
      parent='null',
      children={}
    }
  }
  main(arg, function(node)
      name_to_treenode[node] = {
        name=node,
        parent='root',  -- default, will be overriden
        children={}
      }
    end, function(child, parent)
      local parnode = name_to_treenode[parent or 'root']
      local childnode = name_to_treenode[child]
      assert(parnode and childnode)
      table.insert(parnode.children, childnode)
      assert(childnode.parent == 'root', 'same edge encountered twice')
      childnode.parent = parent
    end)
  -- Nodes in name_to_treenode that still have parent='root' need to be added to root:
  for nodename, node in pairs(name_to_treenode) do
    if node.parent == 'root' then
      table.insert(name_to_treenode.root.children, node)
    end
  end
  io.write(generate_html(json(name_to_treenode.root)))
  io.flush()
end

