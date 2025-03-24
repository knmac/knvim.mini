if vim.o.columns < 90 then
    -- If the screen is small, occupy half
    vim.g.netrw_winsize = 50
else
    -- else take 20%
    vim.g.netrw_winsize = 20
end

-- Sync current directory with browsing directory
vim.g.netrw_keepdir = 0

-- Hide banner
vim.g.netrw_banner = 0

-- Hide dotfiles
-- vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]

-- A better copy command
vim.g.netrw_localcopydircmd = "cp -r"

-- vim.keymap.set("n", "<leader>dd", ":Lexplore %:p:h<CR>")
-- vim.keymap.set("n", "<leader>da", ":Lexplore<CR>")
vim.keymap.set("n", "<leader>e", ":Lexplore<CR>")

-- Better keymaps for Netrw
local netrw_mapping = function()
    local opts = { buffer = true, remap = true }

    -- Close Netrw window
    -- vim.keymap.set("n", "<leader>dd", ":Lexplore<CR>", opts)
    -- vim.keymap.set("n", "<leader>da", ":Lexplore<CR>", opts)
    vim.keymap.set("n", "<leader>e", ":Lexplore<CR>", opts)
    vim.keymap.set("n", "q", ":Lexplore<CR>", { buffer = true, nowait = true })

    -- Go to file and close Netrw window
    -- vim.keymap.set("n", "L", "<CR>:Lexplore<CR>", opts)

    -- Go back in history
    -- vim.keymap.set("n", "H", "u", opts)

    -- Go up a directory
    vim.keymap.set("n", "<BS>", "-^", opts)

    -- Go down a directory / open file
    -- vim.keymap.set("n", "l", "<CR>", opts)

    -- Toggle dotfiles
    vim.keymap.set("n", "H", "gh", opts)

    -- Toggle the mark on a file
    vim.keymap.set("n", "<TAB>", "mf", opts)

    -- Unmark all files in the buffer
    vim.keymap.set("n", "<S-TAB>", "mF", opts)

    -- Unmark all files
    -- vim.keymap.set("n", "<Leader><TAB>", "mu", opts)

    -- 'Bookmark' a directory
    -- vim.keymap.set("n", "bb", "mb", opts)

    -- Delete the most recent directory bookmark
    -- vim.keymap.set("n", "bd", "mB", opts)

    -- Got to a directory on the most recent bookmark
    -- vim.keymap.set("n", "bl", "gb", opts)

    -- Create a file
    vim.keymap.set("n", "a", "%", opts)

    -- Create a directory
    vim.keymap.set("n", "A", "d", opts)

    -- Rename a file
    vim.keymap.set("n", "r", "R", opts)

    -- Copy marked files
    vim.keymap.set("n", "y", "mc", opts)

    -- Move marked files
    vim.keymap.set("n", "x", "mm", opts)

    -- Execute a command on marked files
    -- vim.keymap.set("n", "f;", "mx", opts)

    -- Show the list of marked files
    -- vim.keymap.set("n", "fl", ':echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>', opts)

    -- Show the current target directory
    -- vim.keymap.set("n", "fq", [[:echo 'Target:' . netrw#Expose("netrwmftgt")<CR>]], opts)

    -- Set the directory under the cursor as the current target
    -- vim.keymap.set("n", "fg", "mtfq", opts)

    -- Close the preview window
    -- vim.keymap.set("n", "P", "<C-w>z", opts)
end

vim.api.nvim_create_autocmd("filetype", {
    pattern = "netrw",
    group = "user_cmds",
    desc = "Netrw keyvim.keymap.setings",
    callback = netrw_mapping
})
