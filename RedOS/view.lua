local component = require("component")
local gpu = component.gpu

gpu.set(15, 5, "╒═════════╧══════════╕")
gpu.set(15, 6, "│  Buffer contains   │")
gpu.set(15, 7, "├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤")
gpu.set(15, 8, "│                    │")
gpu.set(15, 9, "├────────────────────┤")
gpu.set(15, 10, "│          Ok        │")
gpu.set(15, 11, "└─────────┬──────────┘")

gpu.setBackground(0xffffff)
gpu.setForeground(0x000000)

gpu.set(16, 10, "         Ok         ")

gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)