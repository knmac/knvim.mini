--- Lightweight package installer (npm, github binary, luarocks).
--- Installs tools into stdpath("data")/packages/ and symlinks binaries to stdpath("data")/bin/.
local M = {}

local data_dir = vim.fn.stdpath("data")
M.bin_dir = data_dir .. "/bin"
local pkg_dir = data_dir .. "/deps"
local rocks_root = data_dir .. "/rocks"
local rocks_lib = rocks_root .. "/lib/luarocks/rocks-5.1"

--- Installer functions keyed by type.
--- @type table<string, fun(dir: string, pkg: string)>
local installers = {
    --- Install an npm package and symlink its binaries.
    npm = function(dir, pkg)
        vim.fn.system({ "npm", "install", "--prefix", dir, pkg })
        for name, _ in vim.fs.dir(dir .. "/node_modules/.bin") do
            vim.uv.fs_symlink(dir .. "/node_modules/.bin/" .. name, M.bin_dir .. "/" .. name)
        end
    end,
    --- Download a GitHub release tarball and symlink the binary.
    --- pkg format: "owner/repo@tag:binary_name"
    github = function(dir, pkg)
        local uname = vim.uv.os_uname()
        local os_name = uname.sysname == "Darwin" and "darwin" or "linux"
        local arch = uname.machine == "x86_64" and "x64" or "arm64"
        local owner_repo, tag, bin_name = pkg:match("^(.+)@(.+):(.+)$")
        local url = string.format(
            "https://github.com/%s/releases/download/%s/%s-%s-%s.tar.gz",
            owner_repo, tag, bin_name, os_name, arch
        )
        vim.fn.system({ "curl", "-L", "-o", dir .. "/pkg.tar.gz", url })
        vim.fn.system({ "tar", "xzf", dir .. "/pkg.tar.gz", "-C", dir })
        os.remove(dir .. "/pkg.tar.gz")
        if vim.fn.filereadable(dir .. "/bin/" .. bin_name) == 1 then
            vim.uv.fs_symlink(dir .. "/bin/" .. bin_name, M.bin_dir .. "/" .. bin_name)
        end
    end,
    --- Install a luarock into the local rocks tree.
    luarocks = function(_, pkg)
        vim.fn.system({ "luarocks", "--lua-version=5.1", "--tree=" .. rocks_root, "install", pkg })
    end,
}

--- Ensure a list of packages are installed. Skips already-installed packages.
--- Installs into stdpath("data")/packages/<name>/ and symlinks binaries to bin/.
--- Prepends bin/ to PATH so installed tools are available to subsequent calls.
--- Each entry: { name = "...", type = "npm"|"github"|"luarocks", pkg = "..." }
--- @param servers { name: string, type: string, pkg: string }[]
function M.ensure(servers)
    vim.fn.mkdir(M.bin_dir, "p")
    for _, server in ipairs(servers) do
        local dir = pkg_dir .. "/" .. server.name
        if vim.fn.isdirectory(dir) == 0 then
            vim.notify("Installing " .. server.name .. "...", vim.log.levels.INFO)
            vim.fn.mkdir(dir, "p")
            installers[server.type](dir, server.pkg)
        end
    end
    vim.env.PATH = M.bin_dir .. ":" .. vim.env.PATH
end

--- Ensure a list of luarocks are installed into a local rocks tree.
--- Unlike ensure(), this manages Neovim's runtimepath instead of PATH,
--- so that installed tree-sitter parsers (.so) and query files (.scm) are discoverable.
--- Requires `luarocks` to be available on PATH.
--- @param rocks string[]
function M.ensure_rocks(rocks)
    if vim.fn.executable("luarocks") == 0 then
        vim.notify("luarocks not found, skipping rock install", vim.log.levels.WARN)
        return
    end
    for _, rock in ipairs(rocks) do
        if vim.fn.isdirectory(rocks_lib .. "/" .. rock) == 0 then
            vim.notify("Installing " .. rock .. "...", vim.log.levels.INFO)
            installers.luarocks(nil, rock)
        end
    end
    -- Prepend installed rocks to runtimepath for treesitter parsers/queries
    for _, dir in ipairs(vim.fn.glob(rocks_lib .. "/tree-sitter-*/*/", true, true)) do
        vim.opt.runtimepath:prepend(dir)
    end
end

return M
