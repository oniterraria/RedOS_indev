local shell = require("shell")
local term = require("term")
local event = require("event")
local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")
local computer = require("computer")
local gpu = component.gpu

local canvas = require("canvas")
local fileList = require("fileList")
local specialShell = require("specialShell")

local work = true
local buffer = {}
local path = "/"
local files = {}
local tree = {}
local copied = {}
local AllPages = 0
local item
local index = 1
local target
local targetPage
local menu
local page = 1
local oldName
local copyPath = ""
local name
local success
local length = 1

local config = {}

local k = 1
local i = 1

local function initialization()
  local file = io.open("/RedOS/.config")
  local i
  for i = 1, 3 do
    if tonumber(file:read("*l")) == 1 then
      config[i] = true
    else
      config[i] = false
    end
  end
  if config[1] then
    local file_2 = io.open("/RedOS/.path")
    k = tonumber(file_2:read("*l"))
    for i = 1, k do
      tree[i] = file_2:read("*l")
    end
    path = tree[k]
    file_2:close()
    local file_3 = io.open("/RedOS/.item")
    local item = file_3:read("*l")
    if item ~= "" then
      if filesystem.exists(path .. item) then
        if (((string.sub(item, 1, 1) == ".") and config[2]) or (string.sub(item, 1, 1) ~= ".")) then
          index, page = specialShell.position(path, path .. item, config[2])
        else
          index = 1
          page = 1
        end
      else
        index = 1
        page = 1
      end
    else
      page = 1
      index = 1
    end
    file_3:close()  
  end
  file:close()
end

local function saveconfig(changes)
  local file = io.open("/RedOS/.config","w")
  local i
  for i = 1, 3 do
    if changes[i] then
      file:write("1", "\n")
    else
      file:write("0", "\n")
    end
  end
  file:close()
end

local function savepath()
  local file = io.open("/RedOS/.path","w")
  local i
  file:write(tostring(k), "\n")
  for i = 1, k - 1 do
    file:write(tree[i], "\n")
  end
  file:write(path, "\n")
  file:close()
end

local function saveitem()
  local file = io.open("/RedOS/.item","w")
  file:write(tostring(item), "\n")
  file:close()
end

initialization()

local function format()
  if gpu.maxDepth() == 8 then
    gpu.setResolution(160, 50)
  elseif gpu.maxDepth() == 4 then
    gpu.setResolution(80, 25)
  end
end

local function pageDraw(path)
  AllPages = fileList.pages(path)
  gpu.set(44, 16, "/ " .. tostring(AllPages))
end

local function position(page)
  local pose = tostring(page)
  gpu.fill(41, 16, 3, 1, " ")
  gpu.set(43 - #pose, 16, pose)
end

local function pathDraw(path)
  gpu.fill(1, 16, 37, 1, " ")
  local reduction = {}
  length = #path
  if length > 19 then
    reduction = filesystem.segments(path)
    path = "/../" .. reduction[#reduction] .. "/"
    length = #reduction[#reduction] + 5
  end
  gpu.set(1, 16, tostring(path))
end

local function itemDraw()
  gpu.fill(length + 1, 16, 37 - length, 1, " ")
  if (#item + length) > 33 then
    gpu.set(length + 1, 16, tostring(string.sub(item, 1, 35 - length)) .. "..")
  else
    gpu.set(length +1, 16, tostring(item))
  end
end

local function loadfiles(path, page, index)
  files = fileList.list(path, page, config[2])
  item = canvas.reset(files, index)
  return files, item
end

local function startUp()
  gpu.setResolution(50, 16)
  shell.execute("/RedOS/workspace.lua")
  files, item = loadfiles(path, page, index) 
  pathDraw(path)
  itemDraw()
  pageDraw(path)
  position(page)  
end

local function loadUp()
  files, item = loadfiles(path, page, index)
  pathDraw(path)
  itemDraw()
  pageDraw(path)
  position(page)
end

local function system()
  menu = canvas.menu(38, 2, 50, 10, 39, 3, 12, "/RedOS/system.lua", 4, 4, files, index)    
  if menu == 1 then
    menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, " Shutdown computer ", false, files, index, config[3])
    if menu then
      saveitem()
      computer.shutdown(false)    
    end  
  elseif menu == 2 then
    menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "  Reboot computer  ", false, files, index, config[3])
    if menu then
      saveitem()
      computer.shutdown(true)    
    end
  elseif menu == 3 then
    menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "  Return to shell  ", false, files, index, config[3])
    if menu then
      term.setCursor(1,1)
      term.clear()
      work = false
    end        
  end
end

local function editor()
  menu = canvas.menu(1, 2, 14, 10, 1, 3, 12, "/RedOS/editor.lua", 4, 1, files, index)
  if menu == 1 then
    local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "     Enter file name      ", 13, 7, "New_file", files, index)
    if string.find(name, "/") then
      name = string.sub(name, 1, string.find(name,"/") - 1)
    end
    if name == "" then
      canvas.show(15, 5, 36, 11, 16, 8, "     Empty field    ", "/RedOS/error.lua", 16, 10, 11, files, index)  
    elseif filesystem.exists(path .. name) then
      canvas.show(15, 5, 36, 11, 16, 8, "   Already exists   ", "/RedOS/error.lua", 16, 10, 11, files, index)
    elseif path == "/mnt/" then
      canvas.show(15, 5, 36, 11, 16, 8, " Directory of disks ", "/RedOS/error.lua", 16, 10, 11, files, index)
    else
      os.execute("edit " .. path .. name)
      if filesystem.exists(path .. name) then
        index, page = specialShell.position(path, path .. name, config[2])
      end 
      startUp()
    end  
  elseif menu == 2 then
    local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "    Enter folder name     ", 13, 7, "New_folder", files, index)
    if string.find(name, "/") then
      name = string.sub(name, 1, string.find(name,"/") - 1)
    end
    if name == nill then
      canvas.show(15, 5, 36, 11, 16, 8, "     Empty field    ", "/RedOS/error.lua", 16, 10, 11, files, index)
    elseif filesystem.exists(path .. name) then
      canvas.show(15, 5, 36, 11, 16, 8, "   Already exists   ", "/RedOS/error.lua", 16, 10, 11, files, index)
    elseif (path .. name == "/dev") or (path .. name == "/mnt") then
      canvas.show(15, 5, 36, 11, 16, 8, "   System reserved  ", "/RedOS/error.lua", 16, 10, 11, files, index)
    elseif path == "/mnt/" then
      canvas.show(15, 5, 36, 11, 16, 8, " Directory of disks ", "/RedOS/error.lua", 16, 10, 11, files, index)
    else
      filesystem.makeDirectory(path .. name)
      canvas.clear(index)
      index = 1
      page = 1
      tree[k] = path
      path = path .. name .. "/"
      loadUp()
      k = k + 1
      savepath()
    end
  elseif menu == 3 then
    local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "   Try to set cursor on   ", 13, 7, "", files, index)
    if (filesystem.exists(path .. name)) then
      if (((string.sub(name, 1, 1) == ".") and config[2]) or (string.sub(name, 1, 1) ~= ".")) then
        canvas.clear(index)
        if filesystem.isDirectory(path .. name .. "/") then
          if string.find(name, "/") then
            name = string.sub(name, 1, string.find(name,"/") - 1)
          end
          name = name .. "/"
        end
        index, page = specialShell.position(path, path .. name, config[2])
        loadUp()
      else
        canvas.show(15, 5, 36, 11, 16, 8, "   Protected file   ", "/RedOS/error.lua", 16, 10, 11, files, index)
      end
    else
      canvas.show(15, 5, 36, 11, 16, 8, "      Not found     ", "/RedOS/error.lua", 16, 10, 11, files, index)
    end  
  end
end

local function settings()
  menu = canvas.menu(25, 2, 38, 8, 26, 3, 12, "/RedOS/settings.lua", 3, 3, files, index)
  if menu == 1 then
    canvas.message(7, 2, 42, 14, "/RedOS/info.lua", 8, 13, 34, files, index)
  elseif menu == 2 then
    local changes = {}
    changes[1] = config[1]
    changes[2] = config[2]
    changes[3] = config[3] 
    menu = canvas.config(7, 3, 44, 13, 8, 4, 36, 34, 4, 10, "/RedOS/config.lua", 5, 3, 5, changes, files, index)
    if (menu == 4) and not ((changes[1] == config[1]) and (changes[2] == config[2]) and (changes[3] == config[3])) then
      config[1] = changes[1]
      config[2] = changes[2]
      config[3] = changes[3]
      saveconfig(changes)
      savepath()
      saveitem()
      menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "    Reboot now     ", false, files, index, config[3])
      if menu then
        computer.shutdown(true)
      end
    end
  end
end

local function copyBuffer()
  menu = canvas.menu(13, 2, 25, 10, 14, 3, 11, "/RedOS/buffer.lua", 4, 1, files, index)
  if menu == 1 then
    if copied[1] ~= nill then
      local result = specialShell.inserting(copyPath, path, copied, files, index, config[3])
      if result == 0 then
        canvas.clear(index)
        index, page = specialShell.position(path, path .. copied[1], config[2])
        loadUp()
        canvas.message(15, 6, 36, 10, "/RedOS/insert_0.lua", 16, 9, 19, files, index)      
      else
        canvas.message(15, 6, 36, 10, "/RedOS/insert_5.lua", 16, 9, 19, files, index)
      end
    else
      canvas.show(15, 5, 36, 11, 16, 8, "    Empty buffer    ", "/RedOS/error.lua", 16, 10, 11, files, index)
    end
  elseif menu == 2 then
    if copied[1] ~= nill then
      local name = copied[1]
      if #name > 20 then 
        name = string.sub(name, 1, 18) .. ".."
      end
      canvas.show(15, 5, 36, 11, 16, 8, name, "/RedOS/view.lua", 16, 10, 11, files, index)
    else
      canvas.show(15, 5, 36, 11, 16, 8, "    Empty buffer    ", "/RedOS/error.lua", 16, 10, 11, files, index)
    end
  elseif menu == 3 then
    if copied[1] ~= nill then
      menu = canvas.switch(15, 5, 35, 11, "RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "   Clean buffer    ", false, files, index, config[3])
      if menu then
        canvas.message(15, 6, 36, 10, "/RedOS/buffer_cleaned.lua", 16, 9, 19, files, index)  
        copied = {}
      end
    else
      canvas.show(15, 5, 36, 11, 16, 8, "    Empty buffer    ", "/RedOS/error.lua", 16, 10, 11, files, index)
    end
  end
end

local function file()
  menu = canvas.menu(19, 2, 31, 14, 20, 3, 10, "/RedOS/file.lua", 6, 1, files, index)    
  if menu == 1 then
    buffer = canvas.load(1, 1, 50, 16)
    term.clear()
    format()
    os.execute(path .. item)
    gpu.setResolution(50, 16)
    os.sleep(2)
    canvas.draw(1, 1, buffer)
    canvas.select(files, index)    
  elseif menu == 2 then
    buffer = canvas.load(1, 1, 50, 16)
    term.clear()
    format()
    os.execute("edit " .. path  .. item)
    gpu.setResolution(50, 16)
    canvas.draw(1, 1, buffer)
    canvas.select(files, index)
  elseif menu == 3 then
    copyPath = path
    copied = {}
    copied[1] = item
    local name = item
    if #item > 20 then 
      name = string.sub(item, 1, 18) .. ".."
    end
    canvas.show(15, 5, 36, 11, 16, 6, name, "/RedOS/copy.lua", 16, 10, 11, files, index)
  elseif menu == 4 then
    local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "   Enter new file name    ", 13, 7, tostring(item), files, index)
    if string.find(name, "/") then
      name = string.sub(name, 1, string.find(name,"/") - 1)
    end      
    if name == nill then
      canvas.show(15, 5, 36, 11, 16, 8, "     Empty field    ", "/RedOS/error.lua", 16, 10, 11, files, index)  
    elseif name == item then
      canvas.show(15, 5, 36, 11, 16, 8, "      Same name     ", "/RedOS/error.lua", 16, 10, 11, files, index)
    else
      canvas.clear(index)
      filesystem.rename(path .. item, path .. name)
      index, page = specialShell.position(path, path .. name, config[2])
      loadUp()
    end
  elseif menu == 5 then
    menu = canvas.switch(15, 5, 35, 11, "RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "    Delete file    ", false, files, index, config[3])
    if menu then
      canvas.clear(index)
      filesystem.remove(path .. item)
      if #files > 1 then
        if (index == #files) and (page == AllPages) then
          index = index - 1
        end
      elseif AllPages > 1 then
        page = page - 1
        index = 12      
      elseif (AllPages == 1) and (#files == 1) then
        index = 1
        page = 1
      end
      loadUp()   
    end  
  end
end

local function folder()
  menu = canvas.menu(19, 3, 31, 13, 20, 4, 10, "RedOS/folder.lua", 5, 1, files, index)     
  if menu == 1 then
    canvas.clear(index)
    tree[k] = path 
    path = path .. item
    page = 1
    index = 1
    loadUp()  
    k = k + 1
    savepath()
  elseif menu == 2 then
    copyPath = path
    copied = {}
    copied[1] = item
    local name = copied[1]
    specialShell.copying(path, copied[1], copied, #path)    
    if #item > 20 then 
      name = string.sub(item, 1, 18) .. ".."
    end
    canvas.show(15, 5, 36, 11, 16, 6, name, "/RedOS/copy.lua", 16, 10, 11, files, index)
  elseif menu == 3 then
    local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "  Enter new folder name   ", 13, 7, string.sub(item, 1, #item - 1), files, index)
    if string.find(name, "/") then
      name = string.sub(name, 1, string.find(name,"/") - 1)
    end   
    if name == nill then
      canvas.show(15, 5, 36, 11, 16, 8, "     Empty field    ", "/RedOS/error.lua", 16, 10, 11, files, index)
    elseif (path .. name == "/dev") or (path .. name == "/mnt") then
      canvas.show(15, 5, 36, 11, 16, 8, "   System reserved  ", "/RedOS/error.lua", 16, 10, 11, files, index)
    elseif name == string.sub(item, 1, #item - 1) then
      canvas.show(15, 5, 36, 11, 16, 8, "      Same name     ", "/RedOS/error.lua", 16, 10, 11, files, index)
    else
      canvas.clear(index)
      filesystem.rename(path .. item, path .. name)
      index, page = specialShell.position(path, path .. name .. "/", config[2])
      loadUp()
    end
  elseif menu == 4 then
    menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "   Delete folder   ", false, files, index, config[3])
    if menu then
      canvas.clear(index)
      filesystem.remove(path .. item)
      if #files > 1 then
        if (index == #files) and (page == AllPages) then
          index = index - 1
        end
      elseif AllPages > 1 then
        page = page - 1
        index = 12      
      elseif (AllPages == 1) and (#files == 1) then
        index = 1
        page = 1
      end      
      loadUp()   
    end  
  end
end

startUp()

while work do
  local name, _, mX, mY, button, _ = event.pull()
  if name == "touch" then
    if (mY == 1) and (button == 0) then
      if mX < 14 then
        editor()
      elseif (mX > 14) and (mX < 25) then
        copyBuffer()
      elseif (mX > 25) and (mX < 38) then
        settings()
      elseif mX > 38 then
        system()
      end
    elseif mY == (index + 2) then
      if (filesystem.isDirectory(path .. item)) and  (item ~= "") then
        if button == 0 then
          canvas.clear(index)
          tree[k] = path 
          path = path .. item
          page = 1
          index = 1
          loadUp()  
          k = k + 1
          savepath()
        elseif button == 1 then
          folder()
        end
      elseif item ~= "" then
        if button == 0 then
          term.clear()
          os.execute(path .. item)
          os.sleep(2)
          startUp()
        elseif button == 1 then
          file()
        end
      end
    elseif (mY > 2) and (mY - 3 < #files) then
      canvas.inverse(1, index + 2, 50, index + 2, "black")        
      index = mY - 2
      item = canvas.select(files, index)
      itemDraw()
    end  
  elseif name == "key_down" then
    local key = mY
    if key == 28 then      
      if (filesystem.isDirectory(path .. item)) and (item ~= "") then
        folder()
      elseif item ~= "" then 
        file()
      end
    elseif key == 2 then
      editor()
    elseif key == 3 then
      copyBuffer()
    elseif key == 4 then
      settings()
    elseif key == 5 then
      system()       
    elseif key == 200 then  
      if index > 1 then
        canvas.inverse(1, index + 2, 50, index + 2, "black")        
        index = index - 1
        item = canvas.select(files, index)
        itemDraw()
      elseif (page > 1) then
        canvas.clear(index)
        page = page - 1
        index = 12
        loadUp()
      end    
    elseif key == 208 then
      if #files > index then
        canvas.inverse(1, index + 2, 50, index + 2, "black")        
        index = index + 1
        item = canvas.select(files, index)
        itemDraw()        
      elseif (page < AllPages) then
        canvas.clear(index)
        page = page + 1
        index = 1
        loadUp()
      end
    elseif (key == 205) and (page < AllPages) then
      canvas.clear(index)
      page = page + 1
      index = 1
      loadUp()
    elseif (key == 203) and (page > 1) then
      canvas.clear(index)
      page = page - 1
      index = 1
      loadUp()
    elseif (key == 14) and (k > 1) then
      k = k - 1
      canvas.clear(index)
      if ((string.sub(path, #tree[k] + 1, #tree[k] + 1) == ".") and (config[2] == false)) then
        index = 1
        page = 1        
      else
        index, page = specialShell.position(tree[k], path, config[2])
      end
      path = tree[k]
      loadUp()
      savepath()
    end
  end
end

print("Log : RedOS has been closed, returning to shell")