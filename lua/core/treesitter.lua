local ts_parser_root = os.getenv("HOME") .. "/.local/share/knvim/lazy/nvim-treesitter/parser/"

if io.open(ts_parser_root) ~= nil then
    vim.treesitter.language.add("python", { path = ts_parser_root .. "python.so" })
    vim.treesitter.language.add("cpp", { path = ts_parser_root .. "cpp.so" })

    vim.treesitter.language.register("python", { "py" })
    vim.treesitter.language.register("cpp", { "cpp" })

    -- Starts treesitter highlighting for a buffer
    vim.api.nvim_create_autocmd( "FileType", { pattern = "py",
    callback = function(args)
        vim.treesitter.start(args.buf, "python")
        vim.bo[args.buf].syntax = "on"  -- only if additional legacy syntax is needed
    end
})
end
