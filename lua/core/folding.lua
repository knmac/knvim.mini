-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Folding configuration
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- General fold settings
-- ────────────────────────────────────────────────────────────────────────────────────────────────
vim.opt.foldenable = true     -- enable folding
vim.opt.foldlevel = 99        -- set fold level
vim.opt.foldlevelstart = 99   -- open most folds by default
vim.opt.foldnestmax = 10      -- 10 nested fold max
vim.opt.foldmethod = "indent" -- set folding method by looking at indent
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Fold text
-- ────────────────────────────────────────────────────────────────────────────────────────────────
function _G.custom_fold_text()
    local line_start = vim.fn.getline(vim.v.foldstart)
    local line_end = vim.fn.getline(vim.v.foldend):gsub("^%s+", "")
    local num_lines = vim.v.foldend - vim.v.foldstart + 1
    return line_start .. " ... " .. line_end .. " [" .. num_lines .. " lines] "
end

vim.opt.foldtext = "v:lua.custom_fold_text()"


-- ────────────────────────────────────────────────────────────────────────────────────────────────
-- Fold column (via statuscolumn)
-- ────────────────────────────────────────────────────────────────────────────────────────────────
vim.o.foldcolumn = "0"
vim.opt.fillchars:append({
    fold = "─", -- filling 'foldtext'
    foldopen = "", -- mark the beginning of a fold
    foldclose = "", -- show a closed fold
    foldsep = " ", -- open fold middle marker
    -- eob = " ", -- empty lines at the end of a buffer
})

function _G.custom_foldcol()
    local lnum = vim.v.lnum
    local foldlevel = vim.fn.foldlevel(lnum)
    local foldclosed = vim.fn.foldclosed(lnum)
    if foldclosed == lnum then
        return vim.opt.fillchars:get().foldclose
    elseif foldlevel >= 1 and vim.fn.foldlevel(lnum - 1) < foldlevel then
        return vim.opt.fillchars:get().foldopen
    elseif foldlevel >= 1 then
        return vim.opt.fillchars:get().foldsep
    end
    return " "
end

vim.o.statuscolumn = "%s%=%{v:relnum?v:relnum:v:lnum} %{%v:lua.custom_foldcol()%} "
