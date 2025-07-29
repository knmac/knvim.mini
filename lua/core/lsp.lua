vim.lsp.enable({ "lua_ls", "pyright" })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method("textDocument/completion") then
            vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            vim.keymap.set("i", "<C-Space>", function()
                vim.lsp.completion.get()
            end)
        end
    end,
})

vim.diagnostic.config({
    -- LSP Diagnostic signs
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
        -- linehl = {},
    },
    -- Virtual text and float
    virtual_text = {
        source = true, -- Or 'if_many'  -> show source of diagnostics
        -- prefix = '■', -- Could be '●', '▎', 'x'
    },
    -- virtual_lines = { current_line = true },
    float = {
        source = true, -- Or 'if_many'  -> show source of diagnostics
        border = "rounded",
    },
})
