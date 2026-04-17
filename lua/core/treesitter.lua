-- local ts_parser_root = os.getenv("HOME") .. "/.local/share/knvim/site/parser/"
require("core.pkg").ensure_rocks({
    "tree-sitter-python",
    "tree-sitter-cpp",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})
