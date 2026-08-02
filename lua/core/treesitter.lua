-- local ts_parser_root = os.getenv("HOME") .. "/.local/share/knvim/site/parser/"
-- Parsers installed as luarocks (parser .so + queries). Neovim 0.12 bundles queries
-- for c/lua/markdown/vim/vimdoc/query but ships no parsers, so they are still needed here.
require("core.deps").ensure_rocks({
    "tree-sitter-lua",
    "tree-sitter-python",
    "tree-sitter-cpp",
    "tree-sitter-c",
    "tree-sitter-json",
    "tree-sitter-yaml",
    "tree-sitter-markdown",
    "tree-sitter-markdown_inline",
    "tree-sitter-bash",
    "tree-sitter-toml",
    "tree-sitter-vim",
    "tree-sitter-vimdoc",
    "tree-sitter-query",
})

-- Map filetypes whose name differs from the parser name (nvim-treesitter used to
-- register these automatically; with bare rocks we do it ourselves).
vim.treesitter.language.register("bash", { "sh" })

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})
