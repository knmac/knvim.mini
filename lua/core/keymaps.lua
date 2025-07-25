-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Keymaps configuration file: keymaps of neovim and plugins.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local opts = { noremap = true, silent = true }


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Basic key bindings
-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Maintain visual mode after shifting
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("v", "<", "<gv", opts)

-- Go down/up soft-wrapped lines instead of "real" lines
-- vim.keymap.set("n", "j", "gj", default_opts)
-- vim.keymap.set("n", "k", "gk", default_opts)

-- Keep the cursor line in the middle of the screen
-- vim.keymap.set("n", "j", "jzz", default_opts)
-- vim.keymap.set("n", "k", "kzz", default_opts)

-- Window navigation
vim.keymap.set("n", "<A-h>", "<C-w>h", opts)
vim.keymap.set("n", "<A-j>", "<C-w>j", opts)
vim.keymap.set("n", "<A-k>", "<C-w>k", opts)
vim.keymap.set("n", "<A-l>", "<C-w>l", opts)

-- In insert mode, <Alt>+h,j,k,l becomes arrows
vim.keymap.set("i", "<A-h>", "<Left>", opts)
vim.keymap.set("i", "<A-j>", "<Down>", opts)
vim.keymap.set("i", "<A-k>", "<Up>", opts)
vim.keymap.set("i", "<A-l>", "<Right>", opts)

-- Window resize
vim.keymap.set("n", "<A-Up>", "<C-w>+", opts)
vim.keymap.set("n", "<A-Down>", "<C-w>-", opts)
vim.keymap.set("n", "<A-Left>", "<C-w><", opts)
vim.keymap.set("n", "<A-Right>", "<C-w>>", opts)

-- Window swapping
vim.keymap.set("n", "<A-S-h>", "<C-w>h<C-w>x", opts)
vim.keymap.set("n", "<A-S-j>", "<C-w>j<C-w>x", opts)
vim.keymap.set("n", "<A-S-k>", "<C-w>k<C-w>x", opts)
vim.keymap.set("n", "<A-S-l>", "<C-w>l<C-w>x", opts)

-- Navigation from terminal
vim.keymap.set("n", "<C-\\>", "<cmd>split | terminal<CR>a", opts)
vim.keymap.set("t", "<C-\\>", "<cmd>q<CR>", opts)
vim.keymap.set("t", "<C-esc>", [[<C-\><C-n>]], opts)
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], opts)
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]], opts)
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]], opts)
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]], opts)

-- Buffer navigation
vim.keymap.set("n", "<C-A-h>", "<cmd>bprevious<CR>", opts)
vim.keymap.set("n", "<C-A-l>", "<cmd>bnext<CR>", opts)
vim.keymap.set("n", "<C-A-j>", ":ls<CR>:b<Space>", opts)
vim.keymap.set("n", "<C-A-k>", "<cmd>bdelete<CR>", opts)

-- Open file in a new split
vim.keymap.set("n", "gF", "<C-w>vgf", opts)

-- Toggle conceal level between 0 and 2
-- vim.keymap.set("n", "<leader>cc",
--     function()
--         vim.opt_local.conceallevel = math.abs(vim.opt_local.conceallevel._value - 2)
--     end,
--     { desc = "Toggle conceal level in the current buffer", noremap = true, silent = true }
-- )


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Function key bindings
-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- <F1>: Show help
vim.keymap.set("n", "<F1>", "<cmd>help<CR>", opts)
-- <S-F1>: Show keymaps
vim.keymap.set("n", "<F13>", "<cmd>map<CR>", opts)

-- <F2>: Rename (check lspconfig)
vim.keymap.set("n", "<F2>", function() vim.lsp.buf.rename() end, opts)
-- <S-F2>: Show task list
-- vim.keymap.set("n", "<F14>", "<cmd>TodoTelescope<CR>", opts)

-- <F3>: Show file tree explorer
vim.keymap.set("n", "<F3>", "<cmd>Lexplore<CR>", opts)
-- <F3>: Show file tree at the current file
-- vim.keymap.set("n", "<F15>", "<cmd>Neotree reveal<CR>", opts)

-- <F4>: Show tags of current buffer
-- vim.keymap.set("n", "<F4>", "<cmd>Outline!<CR>", opts)
vim.keymap.set("n", "<F4>", "<cmd>InspectTree<CR>", opts)
-- <S-F4>: Show diagnostics
-- vim.keymap.set("n", "<F16>", "<cmd>Telescope diagnostics<CR>", opts)

-- <F5>: Show and switch buffer
vim.keymap.set("n", "<F5>", "<cmd>ls<CR>", opts)
-- <S-F5>: Show and switch tab
vim.keymap.set("n", "<F17>", "<cmd>tabs<CR>", opts)

-- <F6>: Prev buffer
vim.keymap.set("n", "<F6>", "<cmd>BufferPrevious<CR>", opts)
-- <S-F6>: Prev tab
vim.keymap.set("n", "<F18>", "<cmd>tabprevious<CR>", opts)

-- <F7>: Next buffer
vim.keymap.set("n", "<F7>", "<cmd>BufferNext<CR>", opts)
-- <S-F7>: Next tab
vim.keymap.set("n", "<F19>", "<cmd>tabnext<CR>", opts)

-- <F8>: Close current buffer and switch to previous buffer
vim.keymap.set("n", "<F8>", "<cmd>BufferClose<CR>", opts)
-- <S-F8>: Close current tab
vim.keymap.set("n", "<F20>", "<cmd>tabclose<CR>", opts)

-- <F9>: Remove trailing spaces
vim.keymap.set("n", "<F9>", [[<cmd>%s/\s\+$//e<CR>]], opts)
-- <S-F9>: Format smart single ‘’ and double “” quotes
vim.keymap.set("n", "<F21>", function() NormalizeQuotes() end, opts)

-- <F10>: Run make file
vim.keymap.set("n", "<F10>", "<cmd>make<CR>", opts)
-- <S-F10>: Run make clean
vim.keymap.set("n", "<F22>", "<cmd>make clean<CR>", opts)

-- <F11>: Toggle zoom the current window (from custom functions)
-- vim.keymap.set("n", "<F11>", "<cmd>ToggleZoom<CR>", opts)
-- <S-F11>: Toggle colorizer
-- vim.keymap.set("n", "<F23>", "<cmd>ColorizerToggle<CR>", opts)

-- <F12>: Toggle relative number
vim.keymap.set("n", "<F12>", "<cmd>set nu rnu!<CR>", opts)
-- <S-F11>: Toggle welcome screen
vim.keymap.set("n", "<F24>", "<cmd>intro<CR>", opts)
