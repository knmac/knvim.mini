require("core")

-- Set colorscheme
local colorschemes = { "unokai", "habamax", }
for _, colorscheme in ipairs(colorschemes) do
    if pcall(vim.cmd.colorscheme, colorscheme) then
        break
    end
end
