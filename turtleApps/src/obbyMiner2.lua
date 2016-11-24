--[[ Obsidian Miner 2

Copyright (c) 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

local getopt= require "getopt"

local onlyOneLayer = false

local function initOptions( args )

  local someOptions = {
    ["one"] = { "(o)ne layer only", 
        "o", nil}
  }
  
  local tbl= getopt.init(
      "Obsidian Miner 2",
      "Mines obby from lava pit",
      someOptions, args )
      
  if tbl ~= nil then
    if tbl["one"] then
      onlyOneLayer= true
    end
  end

end

local function mineALayer()
  -- TODO design, implement mineALayer
  return false--TODO rtrn 4 mineALayer 
end

local function main( args )
  
  -- From args, learns: get it all
  -- or just one layer?
  initOptions(args)
  
  local keepGoing = true
  
  while keepGoing do
    keepGoing= mineALayer()
    if onlyOneLayer then
      keepGoing = false
    end
  end
  
end

main({...})
