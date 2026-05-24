-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline (no plugins)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Mode map
-- ────────────────────────────────────────────────────────────────────────────────────────────────
local mode_map = {
    ["n"]    = "NORMAL",
    ["no"]   = "O-PENDING",
    ["nov"]  = "O-PENDING",
    ["noV"]  = "O-PENDING",
    ["no\22"] = "O-PENDING",
    ["niI"]  = "NORMAL",
    ["niR"]  = "NORMAL",
    ["niV"]  = "NORMAL",
    ["nt"]   = "NORMAL",
    ["v"]    = "VISUAL",
    ["vs"]   = "VISUAL",
    ["V"]    = "V-LINE",
    ["Vs"]   = "V-LINE",
    ["\22"]  = "V-BLOCK",
    ["\22s"] = "V-BLOCK",
    ["s"]    = "SELECT",
    ["S"]    = "S-LINE",
    ["\19"]  = "S-BLOCK",
    ["i"]    = "INSERT",
    ["ic"]   = "INSERT",
    ["ix"]   = "INSERT",
    ["R"]    = "REPLACE",
    ["Rc"]   = "REPLACE",
    ["Rx"]   = "REPLACE",
    ["Rv"]   = "V-REPLACE",
    ["Rvc"]  = "V-REPLACE",
    ["Rvx"]  = "V-REPLACE",
    ["c"]    = "COMMAND",
    ["cv"]   = "EX",
    ["ce"]   = "EX",
    ["r"]    = "REPLACE",
    ["rm"]   = "MORE",
    ["r?"]   = "CONFIRM",
    ["!"]    = "SHELL",
    ["t"]    = "TERMINAL",
}


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Highlight groups
-- ────────────────────────────────────────────────────────────────────────────────────────────────
local mode_hls = {
    NORMAL      = "StlModeNormal",
    INSERT      = "StlModeInsert",
    VISUAL      = "StlModeVisual",
    ["V-LINE"]  = "StlModeVisual",
    ["V-BLOCK"] = "StlModeVisual",
    SELECT      = "StlModeVisual",
    ["S-LINE"]  = "StlModeVisual",
    ["S-BLOCK"] = "StlModeVisual",
    REPLACE     = "StlModeReplace",
    ["V-REPLACE"] = "StlModeReplace",
    COMMAND     = "StlModeCommand",
    TERMINAL    = "StlModeTerminal",
}

local function get_hl_fg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl.fg
end

local function setup_highlights()
    local set = vim.api.nvim_set_hl
    local stl = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
    local stl_bg = stl.bg
    local stl_fg = stl.fg
    local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg

    set(0, "StlModeNormal",   { fg = normal_bg, bg = get_hl_fg("Function"),        bold = true })
    set(0, "StlModeInsert",   { fg = normal_bg, bg = get_hl_fg("String"),           bold = true })
    set(0, "StlModeVisual",   { fg = normal_bg, bg = get_hl_fg("Keyword"),          bold = true })
    set(0, "StlModeReplace",  { fg = normal_bg, bg = get_hl_fg("DiagnosticError"),  bold = true })
    set(0, "StlModeCommand",  { fg = normal_bg, bg = get_hl_fg("Constant"),         bold = true })
    set(0, "StlModeTerminal", { fg = normal_bg, bg = get_hl_fg("Special"),          bold = true })
    set(0, "StlGit",          { fg = get_hl_fg("Constant"),       bg = stl_bg, bold = true })
    set(0, "StlFile",         { fg = stl_fg,                      bg = stl_bg })
    set(0, "StlDiagError",    { fg = get_hl_fg("DiagnosticError"), bg = stl_bg })
    set(0, "StlDiagWarn",     { fg = get_hl_fg("DiagnosticWarn"),  bg = stl_bg })
    set(0, "StlLsp",          { fg = get_hl_fg("Function"),        bg = stl_bg })
    set(0, "StlPos",          { fg = stl_fg,                      bg = stl_bg, bold = true })
end

setup_highlights()

local stl_group = vim.api.nvim_create_augroup("statusline", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
    group = stl_group,
    callback = setup_highlights,
})


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Git branch (cached per buffer)
-- ────────────────────────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
    group = stl_group,
    callback = function()
        local dir = vim.fn.expand("%:p:h")
        if dir == "" then dir = vim.fn.getcwd() end
        local found = vim.fs.find(".git", { upward = true, path = dir })
        if #found == 0 then
            vim.b.stl_git_branch = ""
            return
        end
        local head_file = found[1] .. "/HEAD"
        local f = io.open(head_file)
        if not f then
            vim.b.stl_git_branch = ""
            return
        end
        local content = f:read("*l")
        f:close()
        vim.b.stl_git_branch = content and content:match("ref: refs/heads/(.+)") or content:sub(1, 8)
    end,
})


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Statusline components
-- ────────────────────────────────────────────────────────────────────────────────────────────────
function _G.stl_mode()
    local mode = vim.api.nvim_get_mode().mode
    local label = mode_map[mode] or mode
    local hl = mode_hls[label] or "StlModeNormal"
    return "%#" .. hl .. "# " .. label .. " %#StlFile#"
end

function _G.stl_git()
    local branch = vim.b.stl_git_branch
    if not branch or branch == "" then return "" end
    return "%#StlGit#  " .. branch .. " %#StlFile#"
end

function _G.stl_diagnostics()
    local buf = vim.api.nvim_get_current_buf()
    local counts = vim.diagnostic.count(buf)
    local parts = {}
    local e = counts[vim.diagnostic.severity.ERROR] or 0
    local w = counts[vim.diagnostic.severity.WARN] or 0
    if e > 0 then table.insert(parts, "%#StlDiagError# " .. e) end
    if w > 0 then table.insert(parts, "%#StlDiagWarn# " .. w) end
    if #parts == 0 then return "" end
    return " " .. table.concat(parts, " ") .. " %#StlFile#"
end

function _G.stl_lsp()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end
    local names = {}
    for _, c in ipairs(clients) do
        table.insert(names, c.name)
    end
    return "%#StlLsp# [" .. table.concat(names, ", ") .. "] %#StlFile#"
end

function _G.stl_position()
    return "%#StlPos# %l:%c %p%% "
end


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Render
-- ────────────────────────────────────────────────────────────────────────────────────────────────
local active_stl = table.concat({
    "%{%v:lua.stl_mode()%}",        -- mode label with highlight
    "%{%v:lua.stl_git()%}",         -- git branch name
    " %f%m%r",                      -- filepath, modified [+], readonly [RO]
    "%{%v:lua.stl_diagnostics()%}", -- error/warning counts
    "%=",                           -- right-align separator
    "%{%v:lua.stl_lsp()%}",         -- active LSP client names
    "%y ",                          -- filetype, e.g. [lua]
    "%{%v:lua.stl_position()%}",    -- line:col percentage
})

-- Render this statusline for active windows
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = stl_group,
    callback = function()
        vim.wo.statusline = active_stl
    end,
})

-- Fallback to the default or inactive windows
vim.api.nvim_create_autocmd({ "WinLeave" }, {
    group = stl_group,
    callback = function()
        vim.wo.statusline = ""
    end,
})
