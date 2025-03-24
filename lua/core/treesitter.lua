local ts_parser_root = os.getenv("HOME") .. "/.local/share/knvim/lazy/nvim-treesitter/parser/"

local language_map = {
    python = { fname = "python.so", ft = { "py" } },
    cpp = { fname = "cpp.so", ft = { "cpp" } }
}

if io.open(ts_parser_root) ~= nil then
    for lang, value in pairs(language_map) do
        vim.treesitter.language.add(lang, { path = ts_parser_root .. value["fname"] })
        vim.treesitter.language.register(lang, value["ft"])
    end

    -- vim.treesitter.language.add("python", { path = ts_parser_root .. "python.so" })
    -- vim.treesitter.language.add("cpp", { path = ts_parser_root .. "cpp.so" })
    --
    -- vim.treesitter.language.register("python", { "py" })
    -- vim.treesitter.language.register("cpp", { "cpp" })

    -- Starts treesitter highlighting for a buffer
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "py",
        callback = function(args)
            vim.treesitter.start(args.buf, "python")
            vim.bo[args.buf].syntax = "on" -- only if additional legacy syntax is needed
        end
    })
end
