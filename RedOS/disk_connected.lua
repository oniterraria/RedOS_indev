local component = require("component")
local gpu = component.gpu

gpu.set(7, 5, "╒═════════════════╧════════════╧═════╕")
gpu.set(7, 6, "│           Disk connected           │")
gpu.set(7, 7, "├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤")
gpu.set(7, 8, "│                                    │")
gpu.set(7, 9, "├────────────────────────────────────┤")
gpu.set(7, 10, "│                 Ok                 │")
gpu.set(7, 11, "└─────────────────┬────────────┬─────┘")

gpu.setBackground(0xffffff)
gpu.setForeground(0x000000)

gpu.set(8, 10, "                 Ok                 ")

gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)