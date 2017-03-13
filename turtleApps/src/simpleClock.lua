-- One could also find this at:
-- http://pastebin.com/ZZD2Nr6R

local mon= peripheral.wrap("top")
mon.setTextScale(1.0)
term.redirect(mon)

while true do 
  local tme= os.time()
  local txt= textutils.formatTime(tme,
      true )
      
  term.clear()
  print(txt)
  os.sleep(0.8)
end
