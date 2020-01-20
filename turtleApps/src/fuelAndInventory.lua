DEP_VERSION = "0.8"

--- Message and solution for fuel
-- 
problemWithFuel = {}
problemWithFuel.needMin= 0
problemWithFuel.getMessage= function()
  return string.format(
          "Fuel please. At very "..
          "minimum, %d units. But "..
          "as a general rule, 800."..
          " For instance a block of "..
          "coal would be nice.",
          problemWithFuel.needMin )
end

--- To be called if user puts fuel into
-- selected slot and indicates they
-- want to continue
problemWithFuel.callback = function()
  
  local slt= 1
  local isRefueled= false
  while slt<= 16 and not isRefueled do
    turtle.select(slt)
    isRefueled= turtle.refuel()
    slt= slt+ 1
  end

  -- assume OK here so caller rechecks
  return true

end

--- Message and solution for inventory
-- or other problems that have an empty
-- callback function
problemWithInventory = {}
problemWithInventory.message = ""

problemWithInventory.getMessage= 
    function()
  return problemWithInventory.message
end

problemWithInventory.callback=
    function()
  
  -- Assuming user took care of it
  return true
end
