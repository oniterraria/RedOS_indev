canvas = {}
local shell = require("shell")
local event = require("event")  
local component = require("component")
local unicode = require("unicode")
local gpu = component.gpu

-- service canvas functions

function canvas.load(x1, y1, x2, y2)
  local i, j
  local k = 1
  local buffer = {}
  for i = y1, y2 do
    buffer[k] = ""
    for j = x1, x2 do
      buffer[k] = buffer[k] .. tostring(gpu.get(j, i))
    end
    k = k + 1
  end
  return buffer
end

function canvas.draw(x, y, buffer)
  local i
  for i = 1, #buffer do
    gpu.set(x, y + i - 1, tostring(buffer[i]))
  end
end

function canvas.inverse(x1, y1, x2, y2, color)
  local buffer = canvas.load(x1, y1, x2, y2)
  if color == "white" then
    gpu.setBackground(0xffffff)
    color = "black"
    gpu.setForeground(0x000000)
  else
    gpu.setBackground(0x000000)
    color = "white"
    gpu.setForeground(0xffffff)
  end
  canvas.draw(x1, y1, buffer)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xffffff)
  return color  
end

local function inMessage(x, y, l)
  canvas.inverse(x, y, x + l - 1, y, "white")
  while true do
    local name, _, mX, mY, _, _ = event.pull()
    if (name == "key_down") and (mY == 28) then
      break
    elseif (name == "touch") and (mY == y) and (mX >= x) and (mX < x + l) then
      break
    end
  end
end

local function inSwitch(x1, x2, l, y, item)
  if item then
    canvas.inverse(x1, y, x1 + l - 1, y, "white")
  else
    canvas.inverse(x2, y, x2 + l - 1, y, "white")
  end
  while true do
    local name, _, mX, mY, button, _ = event.pull()
    if name == "touch" then
      if (mY == y) and (button == 0) then
        if (mX >= x1) and (mX <= x1 + l - 1) then
          if item then
            break
          else
            --canvas.inverse(x1, y, x1 + l - 1, y, "white")
            item = true
            --canvas.inverse(x2, y, x2 + l - 1, y, "black")
            break
          end        
        elseif (mX >= x2) and (mX <= x2 + l - 1) then
          if item ~= true then
            break
          else
            --canvas.inverse(x1, y, x1 + l - 1, y, "black")
            item = false
            --canvas.inverse(x2, y, x2 + l - 1, y, "white")
            break
          end
        end
      end
    elseif name == "key_down" then
      local key = mY
      if (key == 203) and not(item) then
        canvas.inverse(x1, y, x1 + l - 1, y, "white")
        item = true
        canvas.inverse(x2, y, x2 + l - 1, y, "black")
      elseif (key == 205) and item then
        canvas.inverse(x1, y, x1 + l - 1, y, "black")
        item = false
        canvas.inverse(x2, y, x2 + l - 1, y, "white")
      elseif key == 28 then
        break
      end
    end
  end

  return item
end

local function inConfig(x1, y1, l1, x2, y2, l2, cases, item, options, changes)
  local i
  for i = 1, options do
    if changes[i] then
      gpu.set(x2 + 1, y2 + ((i - 1) * 2), "Enabled ")  
    else
      gpu.set(x2 + 1, y2 + ((i - 1) * 2), "Disabled")
    end
  end  
  canvas.inverse(x1, y1 + ((item - 1) * 2), x1 + l1 - 1, y1 + ((item - 1) * 2), "white")  
  while true do
    local name, _, mX, mY, button, _ = event.pull()
    if name == "touch" then
      if (mX > x1) and (mX < x1 + l1 - 1) and (button == 0) then
        local i
        local ins = false
        for i = options + 1, cases do
          if mY == y1 + ((i - 1) * 2) then
            if item ~= i then
              item = i
            end
            ins = true
          end
        end
        if ins then 
          break
        end
      end
      if (mX > x2) and (mX < x2 + l2 - 1) and (button == 0) then
        local i
        for i = 1, options do
          if mY == y2 + ((i - 1) * 2) then
            if item ~= i then
              if item > options then
                canvas.inverse(x1, y1 + ((item - 1) * 2), x1 + l1 - 1, y1 + ((item - 1) * 2), "black")
              else 
                canvas.inverse(x2, y2 + ((item - 1) * 2), x2 + l2 - 1, y2 + ((item - 1) * 2), "black")
              end
              item = i
              canvas.inverse(x2, y2 + ((item - 1) * 2), x2 + l2 - 1, y2 + ((item - 1) * 2), "white")
            end
            if changes[item] then
              gpu.setBackground(0xffffff)
              gpu.setForeground(0x000000)
              gpu.set(x2 + 1, y2 + ((item - 1) * 2), "Disabled")
              gpu.setBackground(0x000000)
              gpu.setForeground(0xffffff)
              changes[item] = false  
            else
              gpu.setBackground(0xffffff)
              gpu.setForeground(0x000000)
              gpu.set(x2 + 1, y2 + ((item - 1) * 2), "Enabled ")
              gpu.setBackground(0x000000)
              gpu.setForeground(0xffffff)
              changes[item] = true
            end
          end
        end
      end
    elseif name == "key_down" then
      local key = mY
      if (key == 200) and (item > 1) then
        if item > options then
          canvas.inverse(x1, y1 + ((item - 1) * 2), x1 + l1 - 1, y1 + ((item - 1) * 2), "black")
        else
          canvas.inverse(x2, y2 + ((item - 1) * 2), x2 + l2 - 1, y2 + ((item - 1) * 2), "black")
        end
        item = item - 1
        if item > options then
          canvas.inverse(x1, y1 + ((item - 1) * 2), x1 + l1 - 1, y1 + ((item - 1) * 2), "white")
        else
          canvas.inverse(x2, y2 + ((item - 1) * 2), x2 + l2 - 1, y2 + ((item - 1) * 2), "white")
        end
      elseif (key == 208) and (item < cases) then
        if item > options then
          canvas.inverse(x1, y1 + ((item - 1) * 2), x1 + l1 - 1, y1 + ((item - 1) * 2), "black")
        else
          canvas.inverse(x2, y2 + ((item - 1) * 2), x2 + l2 - 1, y2 + ((item - 1) * 2), "black")
        end
        item = item + 1
        if item > options then
          canvas.inverse(x1, y1 + ((item - 1) * 2), x1 + l1 - 1, y1 + ((item - 1) * 2), "white")
        else
          canvas.inverse(x2, y2 + ((item - 1) * 2), x2 + l2 - 1, y2 + ((item - 1) * 2), "white")
        end
      elseif key == 28 then
        if item > options then
          break
        else
          if changes[item] then
            gpu.setBackground(0xffffff)
            gpu.setForeground(0x000000)
            gpu.set(x2 + 1, y2 + ((item - 1) * 2), "Disabled")
            gpu.setBackground(0x000000)
            gpu.setForeground(0xffffff)
            changes[item] = false  
          else
            gpu.setBackground(0xffffff)
            gpu.setForeground(0x000000)
            gpu.set(x2 + 1, y2 + ((item - 1) * 2), "Enabled ")
            gpu.setBackground(0x000000)
            gpu.setForeground(0xffffff)
            changes[item] = true
          end
        end
      end
    end
  end

  return item
end

local function inMenu(x, y, l, cases, item)  
  canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "white")  
  while true do
    local name, _, mX, mY, button, _ = event.pull()
    if name == "touch" then
      if (mX > x) and (mX < x + l - 1) and (button == 0) then
        local i
        local ins = false
        for i = 1, cases do
          if mY == y + ((i - 1) * 2) then
            if item ~= i then
              item = i
            end
            ins = true
          end
        end
        if ins then 
          break
        end  
      end
    elseif name == "key_down" then
      local key = mY
      if (key == 200) and (item > 1) then
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "black")
        item = item - 1
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "white")
      elseif (key == 208) and (item < cases) then
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "black")
        item = item + 1
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "white")
      elseif key == 28 then
        break
      end
    end
  end

  return item
end

local function inCheck(x, y, l, cases, item)  
  canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "white")  
  while true do
    local name, _, mX, mY, button, _ = event.pull()
    if name == "touch" then
      if (mX > x) and (mX < x + l - 1) and (button == 0) then
        local i
        local ins = false
        for i = 1, cases do
          if mY == y + ((i - 1) * 2) then
            if item ~= i then
              item = i
            end
            ins = true
          end
        end
        if ins then 
          break
        end  
      end
    elseif name == "key_down" then
      local key = mY
      if (key == 200) and (item > 1) then
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "black")
        item = item - 1
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "white")
      elseif (key == 208) and (item < cases) then
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "black")
        item = item + 1
        canvas.inverse(x, y + ((item - 1) * 2), x + l - 1, y + ((item - 1) * 2), "white")
      elseif key == 28 then
        break
      end
    end
  end

  return item
end

local function inInput(x, y, l, s)

  local i
  local item

  if s == nill then
    i = 0
    item = ""
  else
    i = #s
    gpu.set(x, y, tostring(s))
    item = s
  end

  canvas.inverse(x + i, y, x + i, y, "white")

  while true do
    local name, _, key, _, _, _, _ = event.pull()
    if name == "key_down" then
      if key == 13 then
        break
      elseif ((key == 8) or (key == 127)) and (i > 0) then
        gpu.set(x + i - 1, y, " ")
        canvas.inverse(x + i, y, x + i, y, "black")
        i = i - 1
        canvas.inverse(x + i, y, x + i, y, "white")
        item = string.sub(item, 1, #item - 1)
      elseif (key > 32) and (key ~= 127) and (i < l) then
        gpu.set(x + i, y, unicode.char(key))
        canvas.inverse(x + i, y, x + i, y, "black")
        i = i + 1
        canvas.inverse(x + i, y, x + i, y, "white")
        item = item .. unicode.char(key)
      end
    end
  end 

  return item
end

function canvas.cursor(files, line)
  if #files > 0 then
    canvas.select(files, line)
  end 
end

-- common canvas functions

function canvas.message(x1, y1, x2, y2, file, x3, y3, l, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  inMessage(x3, y3, l);
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line) 
end

function canvas.show(x1, y1, x2, y2, x, y, s, file, x3, y3, l, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  gpu.set(x, y, tostring(s))
  inMessage(x3, y3, l);
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line) 
end

function canvas.switch(x1, y1, x2, y2, file, x3, x4, l, y3, x5, y4, caption, item, files, line, config)
  if config then
    item = true
  else
    local buffer = canvas.load(x1, y1, x2, y2)
    shell.execute(file)
    gpu.set(x5, y4, tostring(caption))
    item = inSwitch(x3, x4, l, y3, item)
    canvas.draw(x1, y1, buffer)
    canvas.cursor(files, line)
  end 
  return item
end

function canvas.menuShow(x1, y1, x2, y2, x, y, l, file, i, j, s, cases, item, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  gpu.set(i, j, tostring(s))
  item = inMenu(x, y, l, cases, item)
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line)
  return item
end

function canvas.config(x1, y1, x2, y2, x3, y3, l1, x4, y4, l2, file, cases, options, item, config, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  item, config = inConfig(x3, y3, l1, x4, y4, l2, cases, item, options, config)
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line)
  return item
end

function canvas.menu(x1, y1, x2, y2, x, y, l, file, cases, item, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  item = inMenu(x, y, l, cases, item)
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line)
  return item
end

function canvas.check(x1, y1, x2, y2, x, y, l, file, cases, item, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  item = inCheck(x, y, l, cases, item)
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line)
  return item
end

function canvas.input(x1, y1, x2, y2, x, y, l, file, s1, i, j, s2, files, line)
  local buffer = canvas.load(x1, y1, x2, y2)
  shell.execute(file)
  gpu.set(i, j, tostring(s1))
  local item = inInput(x, y, l, s2)
  canvas.draw(x1, y1, buffer)
  canvas.cursor(files, line)
  return item
end

-- file cursor function

function canvas.select(files, line)
  canvas.inverse(1, line + 2, 50, line + 2, "white")
  return files[line]
end

function canvas.reset(files, line)
  if #files > 0 then
    item = canvas.select(files, line)
  else
    item = ""
  end
  return item 
end

function canvas.clear(line)
  gpu.fill(1, 3, 24, 12, " ")
  gpu.set(25, 2 + line, "╎")
  gpu.fill(26, 3, 12, 12, " ")
  gpu.set(38, 2 + line, "╎")
  gpu.fill(39, 3, 12, 12, " ")
  gpu.fill(25, 6, 1, 5, "╎")
end

return canvas