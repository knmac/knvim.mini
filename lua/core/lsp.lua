require("core.deps").ensure({
    { name = "basedpyright", type = "npm", pkg = "basedpyright" },
    { name = "lua-language-server", type = "github", pkg = "LuaLS/lua-language-server@3.13.6:lua-language-server" },
})

vim.lsp.enable({ "lua_ls", "basedpyright" })

-- Suppress basedpyright jupyter notebook parse errors
local _notify = vim.notify
vim.notify = function(msg, ...)
    if msg and msg:match("failed to parse jupyter notebook") then return end
    _notify(msg, ...)
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method("textDocument/completion") then
            vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            vim.keymap.set("i", "<C-Space>", function()
                vim.lsp.completion.get()
            end, { buffer = ev.buf })
        end
    end,
})

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
        texthl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
    virtual_text = {
        source = true,
    },
    float = {
        source = true,
    },
})
