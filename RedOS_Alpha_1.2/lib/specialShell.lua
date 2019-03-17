local specialShell = {}

local term = require("term")
local os = require("os")
local component = require("component")
local filesystem = require("filesystem")
local shell = require("shell")
local event = require("event")

local gpu = component.gpu

local menuSwitcher = require("menuSwitcher")
local menuInsert = require("menuInsert")
local screenBuffer = require("screenBuffer")
local cursor = require("cursor")

function specialShell.finderLite(path, name)

  local index = 1
  local page = 1  

  local allFiles = {}

  local e = 1
  local i = 0
  local j
      
    for j in filesystem.list(path) do
      allFiles[e] = j
      e = e + 1
    end

    i = 1

    table.sort(allFiles)      
      
    while i <= #allFiles do   
      if allFiles[i] == name then
        index = i          
        page = index / 12
        page = math.ceil(page)  
        index = index - ((page - 1) * 12)
        break 
      end
      i = i + 1  
    end

  return index, page

end

function specialShell.finder(path)

  local name = ""
  local success = true
  local index = 0
  local page = 0  

  local allFiles = {}

  local e = 1
  local i = 0
  local j

  term.setCursor(1, 1)
  print(">> Input the name of file or folder")
  print(">> You want to find")
  print("<<")
  term.setCursor(4, 3)
  term.read()

  while (gpu.get(4 + i, 3) ~= " ") and (i < 33) do

    name = name .. tostring(gpu.get(4 + i, 3))

    if i == 32 then  
      
      success = false
      print(">> Error : name is too long")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    if gpu.get(4 + i, 3)  == "#" or
       gpu.get(4 + i, 3)  == "%" or
       gpu.get(4 + i, 3)  == "{" or
       gpu.get(4 + i, 3)  == "}" or 
       gpu.get(4 + i, 3)  == "<" or 
       gpu.get(4 + i, 3)  == ">" or
       gpu.get(4 + i, 3)  == "*" or
       gpu.get(4 + i, 3)  == "?" or 
       gpu.get(4 + i, 3)  == "$" or
       gpu.get(4 + i, 3)  == "!" or
       gpu.get(4 + i, 3)  == "'" or 
       gpu.get(4 + i, 3)  == ":" or
       gpu.get(4 + i, 3)  == "@" or
       gpu.get(4 + i, 3)  == "+" or
       gpu.get(4 + i, 3)  == "`" or
       gpu.get(4 + i, 3)  == "|" or
       gpu.get(4 + i, 3)  == "=" then

      success = false
      print(">> Error : invalid character")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    i = i + 1
    
  end   

  if name == "" then

    success = false
    print(">> Error : empty field")
    os.sleep(1)
    print(">> Returning to worktable")
    os.sleep(1)
  
  elseif success then

    print(">> Searching")
    os.sleep(1)  
    success = false    

    if filesystem.exists(path .. name) then
    
      for j in filesystem.list(path) do
        allFiles[e] = j
        e = e + 1
      end

      i = 1

      table.sort(allFiles)      
      
      while i <= #allFiles do
        
        if allFiles[i] == name then
          index = i
          success = true          
          print(">> Success")
          os.sleep(1)

          page = index / 12
          page = math.ceil(page)  
          index = index - ((page - 1) * 12)

          break 
        end
      
        i = i + 1

      end   
    end

    if success == false then
      print(">> Failed")
      os.sleep(1)
    end
  end

  return index, page, success

end

function specialShell.input(type, path)

  local name = ""
  local success = true

  local i = 0

  term.setCursor(1, 1)
  print(">> Input name of the " .. type)
  print("<<")
  term.setCursor(4, 2)
  term.read()

  while (gpu.get(4 + i, 2) ~= " ") and (i < 33) do

    name = name .. tostring(gpu.get(4 + i, 2))

    if i == 32 then  
      
      success = false
      print(">> Error : name is too long")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    if gpu.get(4 + i, 2)  == "#" or
       gpu.get(4 + i, 2)  == "%" or
       gpu.get(4 + i, 2)  == "{" or
       gpu.get(4 + i, 2)  == "}" or 
       gpu.get(4 + i, 2)  == "<" or 
       gpu.get(4 + i, 2)  == ">" or
       gpu.get(4 + i, 2)  == "*" or
       gpu.get(4 + i, 2)  == "?" or 
       gpu.get(4 + i, 2)  == "/" or
       gpu.get(4 + i, 2)  == "$" or
       gpu.get(4 + i, 2)  == "!" or
       gpu.get(4 + i, 2)  == "'" or 
       gpu.get(4 + i, 2)  == ":" or
       gpu.get(4 + i, 2)  == "@" or
       gpu.get(4 + i, 2)  == "+" or
       gpu.get(4 + i, 2)  == "`" or
       gpu.get(4 + i, 2)  == "|" or
       gpu.get(4 + i, 2)  == "=" then
    
      success = false
      print(">> Error : invalid character")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    i = i + 1
    
  end   

  if name == "" then

    success = false
    print(">> Error : empty field")
    os.sleep(1)
    print(">> Returning to worktable")
    os.sleep(1)

  elseif filesystem.exists(path .. name) == true then

    success = false
    print(">> Error : already exists")
    os.sleep(1)
    print(">> Returning to worktable")
    os.sleep(1)
  
  elseif success then

    print(">> Success")
    os.sleep(1)  
    print(">> Go to " .. type)
    os.sleep(1)

  end

  return name, success

end

function specialShell.copying(path, item, copied, len)
  for i in filesystem.list(path .. item) do
    local full = path .. item .. i
    copied[#copied + 1] = string.sub(full ,len + 1, #full)
    if filesystem.isDirectory(path .. item .. i) then
      specialShell.copying(path .. item, i, copied, len)
    end 
  end
end

function specialShell.inserting(copyPath, path, copied, files, index)
  
  local result = 0
  local i = 1
  local Selected = {}
  Selected[1] = false
  Selected[2] = false
  Selected[3] = false
  Selected[4] = false

  local d = 0

  local bufferBack = screenBuffer.load(15, 6, 35, 10)
 
  for i = 1, #copied do
    
    shell.execute("/RedOS/insert_1.lua")    
    
    gpu.set(16, 9, "                   ")
    if #copied[i] > 19 then gpu.set(16, 9, string.sub(copied[i], 1, 17) .. "..")
      else
        gpu.set(16, 9, copied[i])
      end

    if filesystem.exists(copyPath .. copied[i]) == false then
      if Selected[1] then
      else
        screenBuffer.draw(15, 6, bufferBack)
        local buffer = screenBuffer.load(15, 4, 36, 12)
        shell.execute("/RedOS/insert_4.lua")
        if #copied[i] > 20 then gpu.set(16, 5, string.sub(copied[i], 1, 18) .. "..")
        else
          gpu.set(16, 5, copied[i])
        end
        menu = menuInsert.openInsert_4()
        screenBuffer.draw(15, 4, buffer)
        if #files > 0 then
          cursor.fileSelect(files, index)
        end 
        if menu == 1 then
          buffer = screenBuffer.load(15, 5, 35, 11)
          menu = menuSwitcher.ApplyToAll("       Skip        ")
          if menu then
            Selected[1] = true
          else
          end 
          screenBuffer.draw(15, 5, buffer)
          if #files > 0 then
            cursor.fileSelect(files, index)
          end   
        else
          result = 1
          break
        end
      end
    elseif (path == copyPath) and (filesystem.isDirectory(copyPath .. copied[i]) == false) then
      if Selected[2] then
      else
        screenBuffer.draw(15, 6, bufferBack)
        local buffer = screenBuffer.load(15, 3, 36, 13)
        shell.execute("/RedOS/insert_2.lua")
        if #copied[i] > 20 then gpu.set(16, 4, string.sub(copied[i], 1, 18) .. "..")
        else
          gpu.set(16, 4, copied[i])
        end
        menu = menuInsert.openInsert_2()
        screenBuffer.draw(15, 3, buffer)
        if #files > 0 then
          cursor.fileSelect(files, index)
        end 
        if menu == 1 then
          buffer = screenBuffer.load(1, 1, 50, 16)
          term.clear()
          local name, success = specialShell.input("file", path)
          screenBuffer.draw(1, 1, buffer)
          if #files > 0 then
            cursor.fileSelect(files, index)
          end
          if success then
            d = d + 1
            local full = path .. copied[i]
            local k = #full
            while k > 0 do
              k = k - 1
              if string.sub(full, k, k) == "/" then
                break
              end
            end
            if k == 0 then
              full = name
            else
              full = string.sub(full, 1, k)
              full = full .. name
            end
            filesystem.copy(copyPath .. copied[i], full)  
          else
            result = 1
            break
          end 
        elseif menu == 2 then
          buffer = screenBuffer.load(15, 5, 35, 11)
          menu = menuSwitcher.ApplyToAll("       Skip        ")
          if menu then
            Selected[2] = true
          else
          end 
          screenBuffer.draw(15, 5, buffer)
          if #files > 0 then
            cursor.fileSelect(files, index)
          end
        else
          result = 1
          break
        end
      end
    elseif (filesystem.exists(path .. copied[i])) and (filesystem.isDirectory(copyPath .. copied[i]) == false) then
      if Selected[3] then
        filesystem.copy(copyPath .. copied[i], path .. copied[i])
        d = d + 1
      elseif Selected[4] then
      else
        screenBuffer.draw(15, 6, bufferBack)
        local buffer = screenBuffer.load(15, 2, 36, 14)
        shell.execute("/RedOS/insert_3.lua")
        if #copied[i] > 20 then gpu.set(16, 3, string.sub(copied[i], 1, 18) .. "..")
        else
          gpu.set(16, 3, copied[i])
        end
        menu = menuInsert.openInsert_3()
        screenBuffer.draw(15, 2, buffer)
        if #files > 0 then
          cursor.fileSelect(files, index)
        end 
        if menu == 1 then
          buffer = screenBuffer.load(1, 1, 50, 16)
          term.clear()
          local name, success = specialShell.input("file", path)
          screenBuffer.draw(1, 1, buffer)
          if #files > 0 then
            cursor.fileSelect(files, index)
          end
          if success then
            d = d + 1
            local full = path .. copied[i]
            local k = #full
            while k > 0 do
              k = k - 1
              if string.sub(full, k, k) == "/" then
                break
              end
            end
            if k == 0 then
              full = name
            else
              full = string.sub(full, 1, k)
              full = full .. name
            end
            filesystem.copy(copyPath .. copied[i], full)  
          else
            result = 1
            break
          end 
        elseif menu == 2 then
          buffer = screenBuffer.load(15, 5, 35, 11)
          menu = menuSwitcher.ApplyToAll("      Replace      ")
          if menu then
            Selected[3] = true
          else
            filesystem.copy(copyPath .. copied[i], path .. copied[i])
            d = d + 1
          end 
          screenBuffer.draw(15, 5, buffer)
          if #files > 0 then
            cursor.fileSelect(files, index)
          end   
        elseif menu == 3 then
          buffer = screenBuffer.load(15, 5, 35, 11)
          menu = menuSwitcher.ApplyToAll("       Skip        ")
          if menu then
            Selected[4] = true
          else
          end 
          screenBuffer.draw(15, 5, buffer)
          if #files > 0 then
            cursor.fileSelect(files, index)
          end 
        else
          result = 1
          break
        end
      end
    else
      if (filesystem.isDirectory(copyPath .. copied[i])) and not (filesystem.exists(path .. copied[i])) then
        filesystem.makeDirectory(path .. copied[i])
      else 
        filesystem.copy(copyPath .. copied[i], path .. copied[i])
      end
      d = d + 1
    end
  end 

  if (result == 1) and (i > 1) then
    local k
    for k = 1, i - 1 do

    end
  end

  if d == 0 then
    result = 1
  end

  if result == 0 then
    screenBuffer.draw(15, 6, bufferBack)
    if #files > 0 then
      cursor.fileSelect(files, index)
    end
  end

  return result
end

return specialShell