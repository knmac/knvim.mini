require("core.deps").ensure({
    { name = "basedpyright", type = "npm", pkg = "basedpyright" },
    { name = "lua-language-server", type = "github", pkg = "LuaLS/lua-language-server@3.13.6:lua-language-server" },
})

vim.lsp.enable({ "lua_ls", "basedpyright" })

-- Suppress basedpyright jupyter notebook parse errors
local orig_show_message = vim.lsp.handlers["window/showMessage"]
vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
    if result and result.message and result.message:match("failed to parse jupyter notebook") then
        return
    end
    if orig_show_message then
        orig_show_message(err, result, ctx, config)
    else
        vim.notify(result.message, ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type])
    end
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
