local specialShell = {}

local shell = require("shell")
local filesystem = require("filesystem")
local canvas = require("canvas")
local component = require("component")

local gpu = component.gpu

function specialShell.position(path, item, config)

  local index
  local page

  local j
  local k = 1

  local allFiles = {}

  for j in filesystem.list(path) do
    if (string.sub(j, 1, 1) == ".") then
      if config then
        allFiles[k] = path .. j
        k = k + 1
      end
    else
      allFiles[k] = path .. j
      k = k + 1
    end
  end
  local i = 1
  table.sort(allFiles)
  for i = 1, #allFiles do      
    if allFiles[i] == item then
      index = i          
      page = math.ceil(index / 12)  
      index = index - ((page - 1) * 12)
      break
    end 
  end

  index = (index or 1)
  page = (page or 1)  

  return index, page   
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

function specialShell.inserting(copyPath, path, copied, files, index, config)
  
  local result = 0
  local i = 1
  local Selected = {}
  Selected[1] = false
  Selected[2] = false
  Selected[3] = false
  Selected[4] = false

  local d = 0

  local buffer = canvas.load(15, 6, 35, 10)
 
  for i = 1, #copied do
    
    shell.execute("/RedOS/insert_1.lua")    
    gpu.set(16, 9, "                   ")

    if #copied[i] > 19 then gpu.set(16, 9, ".." .. string.sub(copied[i], #copied[i] - 16, #copied[i]))
      else
        gpu.set(16, 9, copied[i])
      end

    if filesystem.exists(copyPath .. copied[i]) == false then
      if Selected[1] then
      else
        canvas.draw(15, 6, buffer)
        canvas.cursor(files, index)
        local name = copied[i] 
        if #name > 20 then
          name = ".." .. string.sub(name, #name - 17, #name)
        end
        menu = canvas.menuShow(15, 4, 36, 12, 16, 9, 20, "/RedOS/insert_4.lua", 16, 5, name, 2, 1, files, index) 
        if menu == 1 then
          if i ~= #copied then
            menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "   Apply to all    ", true, files, index, config)
            if menu then
              Selected[1] = true
            end
          end   
        else
          canvas.cursor(files, index)
          break
        end
      end
    elseif (path == copyPath) and (filesystem.isDirectory(copyPath .. copied[i]) == false) then
      if Selected[2] then
      else
        canvas.draw(15, 6, buffer)
        canvas.cursor(files, index)
        local name = copied[i]
        if #name > 20 then 
          name = ".." .. string.sub(name, #name - 17, #name)
        end
        menu = canvas.menuShow(15, 3, 36, 13, 16, 8, 20, "/RedOS/insert_2.lua", 16, 4, name, 3, 1, files, index)
        if menu == 1 then
          local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "   Enter new file name    ", 13, 7, filesystem.name(copied[i]), files, index)
          if string.find(name, "/") then
            name = string.sub(name, 1, string.find(name,"/") - 1)
          end
          if name == "" then
            canvas.show(15, 5, 36, 11, 16, 8, "     Empty field    ", "/RedOS/error.lua", 16, 10, 11, files, index)
            break
          elseif (name == string.sub(copied[i], #copied[i] - #name + 1, #copied[i])) or (filesystem.exists(path .. filesystem.path(copied[i]) .. name)) then
            canvas.show(15, 5, 36, 11, 16, 8, "   Already exists   ", "/RedOS/error.lua", 16, 10, 11, files, index)
            break
          else
            d = d + 1
            --copied[i] = filesystem.path(copied[i]) .. name
            filesystem.copy(copyPath .. copied[i], path .. filesystem.path(copied[i])  .. name)
            if filesystem.path(copied[i]) == "/" then
              copied[i] = name
            end
          end 
        elseif menu == 2 then
          if i ~= #copied then
            menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "   Apply to all    ", true, files, index, config)  
            if menu then
              Selected[2] = true
            end
          end 
        else
          canvas.cursor(files, index)
          break
        end
      end
    elseif (filesystem.exists(path .. copied[i])) and (filesystem.isDirectory(copyPath .. copied[i]) == false) then
      if Selected[3] then
        filesystem.copy(copyPath .. copied[i], path .. copied[i])
        d = d + 1
      elseif Selected[4] then
      else
        canvas.draw(15, 6, buffer)
        canvas.cursor(files, index)
        local name = copied[i]
        if #name > 20 then 
          name = ".." .. string.sub(name, #name - 17, name)
        end
        menu = canvas.menuShow(15, 2, 36, 14, 16, 7, 20, "/RedOS/insert_3.lua", 16, 3, name, 4, 1, files, index) 
        if menu == 1 then
          local name = canvas.input(12, 6, 39, 10, 13, 9, 25, "/RedOS/input.lua", "   Enter new file name    ", 13, 7, filesystem.name(copied[i]), files, index)
          if string.find(name, "/") then
            name = string.sub(name, 1, string.find(name,"/") - 1)
          end
          if name == "" then
            canvas.show(15, 5, 36, 11, 16, 8, "     Empty field    ", "/RedOS/error.lua", 16, 10, 11, files, index)
            break
          elseif (name == string.sub(copied[i], #copied[i] - #name + 1 , #copied[i])) or (filesystem.exists(path .. filesystem.path(copied[i]) .. name)) then
            canvas.show(15, 5, 36, 11, 16, 8, "   Already exists   ", "/RedOS/error.lua", 16, 10, 11, files, index)
            break
          else
            d = d + 1
            --copied[i] = filesystem.path(copied[i]) .. name 
            filesystem.copy(copyPath .. copied[i], path .. filesystem.path(copied[i]) .. name)
            if filesystem.path(copied[i]) == "/" then
              copied[i] = name
            end
          end 
        elseif menu == 2 then
          if i ~= #copied then
            menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "   Apply to all    ", true, files, index, config)
            if menu then
              Selected[3] = true
            end
          end
          filesystem.copy(copyPath .. copied[i], path .. copied[i])
          d = d + 1    
        elseif menu == 3 then
          if i ~= #copied then
            menu = canvas.switch(15, 5, 35, 11, "/RedOS/choice.lua", 16, 26, 9, 10, 16, 8, "   Apply to all    ", true, files, index, config)
            if menu then
              Selected[4] = true
            end
          end 
        else
          canvas.cursor(files, index)
          break
        end
      end
    else
      if (filesystem.isDirectory(copyPath .. copied[i])) and not (filesystem.exists(path .. copied[i])) then
        filesystem.makeDirectory(path .. copied[i])
        d = d + 1
      elseif not filesystem.isDirectory(copyPath .. copied[i]) then 
        filesystem.copy(copyPath .. copied[i], path .. copied[i])
        d = d + 1
      end
    end
  end 

  if d == 0 then
    result = 1
  end

  canvas.draw(15, 6, buffer)
  canvas.cursor(files, index)
  
  return result
end

return specialShell