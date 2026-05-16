local dap = require("dap")
local dap_python = require("dap-python")
local dapui = require("dapui")

-- Путь к python в venv
dap_python.setup(vim.fn.exepath("python"))

-- UI
dapui.setup()

-- Открывать/закрывать UI автоматически
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

