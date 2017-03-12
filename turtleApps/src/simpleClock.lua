-- Have a wide monitor on top
-- Works well as "startup"

local m = peripheral.wrap("top")
m.setTextScale(0.5)
term.redirect(m)

while true do 
  term.clear()
  shell.run("time")
  print("TODOs:")
  print("- function to craft X number of ladders")
  print("- one to place them down the wall below")
  os.sleep(5)
end
