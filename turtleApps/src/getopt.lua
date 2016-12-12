--[[ CC Getopt 
Copyright (c) 2016 
Authors: Admicos, dalkire
Distributed under the MIT License
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
 
 original found at [pastebin](
 http://pastebin.com/aLcLbJsA )
 
 Referenced in [cc forum post](
 http://www.computercraft.info/
 forums2/index.php?/topic/
 27355-getopt-easy-option-parsing/ )
 ]]

getopt = {}

local g_name
local g_desc 
local g_options

--- displays help
getopt.help= function()
  
  local help= g_name.. ": ".. 
      g_desc.."\n".."USAGE: "..g_name.. 
      " [options] [arg(s)]\n"..
      "Options:\n"
      
  for key, val in pairs(g_options) do
    help = help .. "--" .. key .. 
        " (-" .. val[2] .. ")"

    if val[3] ~= nil then
      help = help .. 
          " [" .. val[3] .. "]"
    end
    
    help= help.. ": ".. val[1].. "\n"
  end

  if textutils then
    textutils.pagedPrint(help)
  else
    print(help)
  end
  
end

--- Initializes
-- @param name program name
-- @param desc program description 
-- @param options a table of options, 
--  **not** including --help or -h 
--  because getopt creates them for 
--  you.
-- @param args the arguments passed in
-- @return table or nil
getopt.init= function(name, desc,
    options, args)

  g_name = name
  g_desc = desc
  g_options = options
  
  local _resTbl = {}
  local _isArg = false
  local _optCnt = 1

  for indx, val in ipairs(args) do
  
    if val== "-h" or val=="--help" then
      _resTbl = {}

      getopt.help()

      return nil
    end

    if val:sub( 1, 1 ) == "-" then
    
      for nme, trio in pairs(options)do
      
        if val== "--".. nme or 
            val== "-".. trio[2] then
            
          if trio[3] ~= nil then
            _resTbl[nme]= args[indx+ 1]
            _isArg = true
          else
            _resTbl[nme] = true
          end
          
        end -- if arg
        
      end -- options loop
      
    elseif not _isArg then
      _resTbl["opt-" .. _optCnt] = val
      _optCnt = _optCnt + 1
    else
      _isArg = false
    end
    
  end -- args loop

  return _resTbl
end

return getopt
