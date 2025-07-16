require("core")

-- Install colorscheme (the only plugin)
local catppuccin_path = vim.fn.stdpath("config") .. "/pack/themes/start/catppuccin"
if not vim.uv.fs_stat(catppuccin_path) then
    print("Installing colorscheme (one time run)...")
    local catppuccin_repo = "https://github.com/catppuccin/nvim.git"
    local out = vim.fn.system({ "git", "clone", catppuccin_repo, catppuccin_path })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone catppuccin:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
    print("Restart neovim to load colorscheme")
end

-- Set colorscheme
local colorschemes = { "catppuccin-macchiato", "sorbet", "habamax", }
for _, colorscheme in ipairs(colorschemes) do
    if pcall(vim.cmd.colorscheme, colorscheme) then
        break
    end
end
