local menuInsert = {}

local event = require("event")
local computer = require("computer")

local cursor = require("cursor")
local screenBuffer = require("screenBuffer")

function menuInsert.openInsert_2()

  local variants = 3

  local index = 3

  local x1 = 16
  local x2 = 35

  cursor.menuSelect(x1, x2, index + 2.5)

  while true do

    local name, _, _, key, _, _ = event.pull()
    if name == "key_down" then
  
      if key == 28 then
  
        break
               
      elseif key == 200 then
      
        if index > 1 then
          
          buffer = screenBuffer.load(x1, ((index + 2.5) * 2) + 1, x2, ((index + 2.5) * 2) + 1)
          screenBuffer.draw(x1, ((index + 2.5) * 2) + 1, buffer)
          index = index - 1
          cursor.menuSelect(x1, x2, index + 2.5)

        end
      
      elseif key == 208 then

        if variants > index then

          buffer = screenBuffer.load(x1, ((index + 2.5) * 2) + 1, x2, ((index + 2.5) * 2) + 1)
          screenBuffer.draw(x1, ((index + 2.5) * 2) + 1, buffer)
          index = index + 1 
          cursor.menuSelect(x1, x2, index + 2.5)
     
        end
      end
    end
  end

  return index

end

function menuInsert.openInsert_3()

  local variants = 4

  local index = 4

  local x1 = 16
  local x2 = 35

  cursor.menuSelect(x1, x2, index + 2)

  while true do

    local name, _, _, key, _, _ = event.pull()
    if name == "key_down" then
  
      if key == 28 then
  
        break
               
      elseif key == 200 then
      
        if index > 1 then
          
          buffer = screenBuffer.load(x1, ((index + 2) * 2) + 1, x2, ((index + 2) * 2) + 1)
          screenBuffer.draw(x1, ((index + 2) * 2) + 1, buffer)
          index = index - 1
          cursor.menuSelect(x1, x2, index + 2)

        end
      
      elseif key == 208 then

        if variants > index then

          buffer = screenBuffer.load(x1, ((index + 2) * 2) + 1, x2, ((index + 2) * 2) + 1)
          screenBuffer.draw(x1, ((index + 2) * 2) + 1, buffer)
          index = index + 1 
          cursor.menuSelect(x1, x2, index + 2)
     
        end
      end
    end
  end

  return index

end

function menuInsert.openInsert_4()

  local variants = 2

  local index = 2

  local x1 = 16
  local x2 = 35

  cursor.menuSelect(x1, x2, index + 3)

  while true do

    local name, _, _, key, _, _ = event.pull()
    if name == "key_down" then
  
      if key == 28 then
  
        break
               
      elseif key == 200 then
      
        if index > 1 then
          
          buffer = screenBuffer.load(x1, ((index + 3) * 2) + 1, x2, ((index + 3) * 2) + 1)
          screenBuffer.draw(x1, ((index + 3) * 2) + 1, buffer)
          index = index - 1
          cursor.menuSelect(x1, x2, index + 3)

        end
      
      elseif key == 208 then

        if variants > index then

          buffer = screenBuffer.load(x1, ((index + 3) * 2) + 1, x2, ((index + 3) * 2) + 1)
          screenBuffer.draw(x1, ((index + 3) * 2) + 1, buffer)
          index = index + 1 
          cursor.menuSelect(x1, x2, index + 3)
     
        end
      end
    end
  end

  return index

end

return menuInsert