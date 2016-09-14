-- Tells you how much material you
-- need for ladders & torches for a 
-- hole X blocks deep.  Assumes you
-- want to have two ladders side by
-- side and a torch every 5 blocks.
-- Also assumes your hole doesn't go
-- below bedrock height: 5

function main( arghs )
  local argCnt = table.getn(arghs)
  if argCnt < 1 then
    print("usage: shaftManifest".. 
        " <Y>")
    print("  where <Y> is turtle's"..
        " Y-coord.")
    
  else
    local n = tonumber( arghs[1] )
    if n == nil then
      print("argument not a number")
    elseif n < 6 then
      print("arg should be 6 or more")
    else
      n = n - 5
      local ladderCnt = n * 2
      local torchCnt= math.ceil( n/5 )
      
      print("ladders: ".. ladderCnt)
      print("torches: ".. torchCnt)

      local coalCnt= math.ceil(
          torchCnt / 4 )
      print("coal & sticks for ".. 
          "torches: ".. coalCnt )

      local trchStckCnt= coalCnt
      local lddrStckCnt= math.ceil(
          ladderCnt * 7 / 3 )
      print("sticks for ladders: "..
          lddrStckCnt)

      local stickCnt= lddrStckCnt +
          trchStckCnt
      print( "total sticks needed: "..
          stickCnt )
      
      local plankCnt= math.ceil(
          stickCnt * 2 / 4 )
      print("planks for sticks: "..
          plankCnt )
      
      local logCnt = math.ceil(
          plankCnt / 4 )
      print("logs for planks: ".. 
          logCnt )
      
    end    
  end

end

local args = {...}
main( args )
