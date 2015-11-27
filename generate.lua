require "torch"

if #arg < 1 then
  print("Expected at least one package to require.")
  print("Use -lclassic to monitor classic classes instead. (see github.com/deepmind/classic)")
  print("")
  print("Usage: th [-lclassic] generate.lua output_mode package1 [package2 [package3 ...]]")
  print("where output_mode is htmld3force, htmld3hier, graphviz, ...") -- TODO
  os.exit(1)
end

--[[
All nodes given via node_callback(nodename) first, then 
all edges given via edge_callback(childname, parentname).
]]
local function main(require_names, node_callback, edge_callback)
  local edges = {}
  -- Monkeypatch only needed for torch classes:
  if not classic then
    local TC = torch.class
    torch.class = function(...)
      table.insert(edges, {...})
      return TC(...)
    end
  end

  for i=1,#require_names do
    require(require_names[i])
  end

  if classic then
    -- Classic classes
    for _,cls in pairs(classic._registry) do
      local clsname = cls._name
      node_callback(clsname)
    end
    for _,cls in pairs(classic._registry) do
      local clsname = cls._name
      local parent = rawget(cls, '_parent')
      if parent then
        edge_callback(clsname, parent._name)
      end
    end
  else
    -- Torch classes (recorded from monkeypatch)
    for _,edge in pairs(edges) do
      local clsname, parent = unpack(edge)
      node_callback(clsname)
    end
    for _,edge in pairs(edges) do
      local clsname, parent = unpack(edge)
      if parent then
        edge_callback(clsname, parent)
      end
    end
  end
end

local mode = arg[1]
local arg_list = {}
for i=2,#arg do
	table.insert(arg_list, arg[i])
end

local func = require(mode)
func(arg_list, main)

