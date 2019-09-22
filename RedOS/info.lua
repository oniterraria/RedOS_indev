local component = require("component")
local computer = require("computer")
local gpu = component.gpu

gpu.set(7, 2, "╤═════╧═══════════╧════════════╧═══╤")
gpu.set(7, 3, "│    RedOS v1.2 from LexaDriver    │")
gpu.set(7, 4, "├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤")
gpu.set(7, 5, "│      Build 18.06.19 [Beta]       │")
gpu.set(7, 6, "├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤")
gpu.set(7, 7, "│   Standart OpenOS Architecture   │")
gpu.set(7, 8, "├──────────────────────────────────┤")
gpu.set(7, 9, "│     GPU/Screen tier :            │")
if gpu.maxDepth() == 8 then
  gpu.set(31, 9, "III tier")
elseif gpu.maxDepth() == 4 then
  gpu.set(31, 9, "II tier")
else
  gpu.set(32, 9, "I tier")
end
gpu.set(7, 10, "├──────────────────────────────────┤")
gpu.set(7, 11, "│ RAM All/Free :         /         │")
gpu.set(24, 11, tostring(math.ceil(computer.totalMemory() / 1024)) .. " Kb")
gpu.set(34, 11, tostring(math.ceil(computer.freeMemory() / 1024)) .. " Kb")  
gpu.set(7, 12, "├──────────────────────────────────┤")
gpu.set(7, 13, "│               Exit               │")
gpu.set(7, 14, "└─────────────────┬────────────┬───┘")
 