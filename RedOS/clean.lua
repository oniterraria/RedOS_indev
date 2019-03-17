local component = require("component")
local gpu = component.gpu

gpu.set(15, 6, "╒═════════╧═════════╕")
gpu.set(15, 7, "│  Buffer cleaned   │")
gpu.set(15, 8, "├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤")
gpu.set(15, 9, "│        Ok         │")
gpu.set(15, 10, "└─────────┬─────────┘")

gpu.setBackground(0xffffff)
gpu.setForeground(0x000000)

gpu.set(16, 9, "        Ok         ")

gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)