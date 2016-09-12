--[[ CC Getopt Example Program
Copyright (c) 2016 
Author: Admicos
Distributed under the MIT License as
stated by original author in a forum 
post, then explicitly added here by 
dalkire.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
 
 Copied, reformatted and modified by 
 rdalkire
 
 original found at [pastebin](
 http://pastebin.com/aLcLbJsA )
 
 Referenced in [cc forum post](
 http://www.computercraft.info/
 forums2/index.php?/topic/
 27355-getopt-easy-option-parsing/ )
 ]]


-- os.loadAPI("getopt")
local getopt= require "getopt"

 local _optionsExample = {
  ["color"] = {
      "Should it be colored", 
      "c", nil},
               
  ["number"] = {
      "How many times should it print",
      "n", "num" },
 }

 local tbl = getopt.init( "mockPrint",
    "pretends to print text in color", 
    _optionsExample, {...} )

 if tbl ~= nil then
  if tbl["color"] then 
    -- term.setTextColor(colors.orange)
    print( "[pretend text is orange]" )
  end
  
  if tbl["number"] then
    local num = tbl["number"]
    for i = 1, 
        tonumber( tbl["number"] ) do
        
      print(tbl["opt-1"])
    end
  end
  
 end

--[[ Valid example arguments: 
     --number 5 -c "hello world"
]]