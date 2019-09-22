local fileList = {}

local filesystem = require("filesystem")
local component = require("component")
local gpu = component.gpu

function fileList.list(path, page, config)

  local e = 1
  local k = 1
  local j = 1

  local i 
  local files = {}
  local allFiles = {}

  for i in filesystem.list(path) do
    if (string.sub(i, 1, 1) == ".") then
     if config then
        allFiles[e] = i
        e = e + 1
      end
    else
      allFiles[e] = i
      e = e + 1
    end
  end
  table.sort(allFiles)
  for i = 1, #allFiles do
    if (k > ((page - 1) * 12)) and (k <= (page * 12)) then 
      files[j] = allFiles[i]
      j = j + 1
    end
    k = k + 1
  end  

  for i = 1, 12 do
    if i > #files then break
    else  
      if #files[i] > 24 then
        gpu.set(1, 2 + i, string.sub(files[i], 1, 22) .. "..")
      else
        gpu.set(1, 2 + i, files[i])
      end
      if (path .. files[i] == "/mnt/") then
        gpu.set(27, 2 + i, "Disks")
      elseif path == "/mnt/" then
        gpu.set(27, 2 + i, "Disk")
      elseif filesystem.isDirectory(path .. files[i]) then
        if string.sub(files[i], 1, 1) == "." then
          gpu.set(27, 2 + i, "Protected")
        else
          gpu.set(27, 2 + i, "Folder")
        end
      elseif string.sub(files[i], #files[i] - 3, #files[i]) == ".lua" then
        gpu.set(27, 2 + i, "Program")
      elseif string.sub(files[i], #files[i] - 3, #files[i]) == ".txt" then
        gpu.set(27, 2 + i, "Text")
      elseif string.sub(files[i], 1, 1) == "." then
        gpu.set(27, 2 + i, "Protected")
      else
        gpu.set(27, 2 + i, "File")
      end
      gpu.set(40, 2 + i, size(path, files[i], config))
    end
  end
  
  return files  

end

function fileList.pages(path, config)
  local pages
  local i
  local k = 0

  for i in filesystem.list(path) do
    if string.sub(i, 1, 1) == "." then
      if config then
        k = k + 1
      end
    else   
      k = k + 1
    end
  end
  pages = k / 12
  pages = math.ceil(pages)  
  return pages  
end

local function scan(n, path, config)

  local i
  for i in filesystem.list(path) do    
    if (string.sub(i, 1, 1) == ".") then
     if config then
        n = n + 1
      end
    else
      n = n + 1
    end       
    if (filesystem.isDirectory(path .. i)) then
      n = scan(n, path .. i)
    end
  end

  return n
end

function size(path, item, config)
  local size = ""  
  if filesystem.isDirectory(path .. item) then
    local i
    local k = 0
    if (string.sub(path .. item, 1, 5) ~= "/dev/") and (string.sub(path .. item, 1, 5) ~= "/mnt/") then
      k = scan(k, path .. item, config)
    else
      for i in filesystem.list(path .. item) do
        k = k + 1
      end
      k = tostring(k .. "*")
    end
    if k == 0 then
      size = "Empty"
    else
      size = tostring(k) .. " Items"
    end  
  else
    local byte = filesystem.size(path .. item)
    if byte > 1024 then
      byte = math.ceil(byte / 1024)
      size = byte .. " KBytes"
    elseif (byte < 1024) and (byte > 0) then
      size = byte .. " Bytes"
    else
      size = "Empty"
    end
  end
  return size
end

return fileList