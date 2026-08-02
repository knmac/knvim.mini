--- Lightweight package installer (npm, github binary, luarocks).
--- Installs tools into stdpath("data")/packages/ and symlinks binaries to stdpath("data")/bin/.
local M = {}

local data_dir = vim.fn.stdpath("data")
M.bin_dir = data_dir .. "/bin"
local pkg_dir = data_dir .. "/deps"
local rocks_root = data_dir .. "/rocks"
local rocks_lib = rocks_root .. "/lib/luarocks/rocks-5.1"

--- Rock installs need luarocks >= 3.12.0. Older versions load the rocks server
--- manifest as a Lua chunk, and luarocks.org's manifest now exceeds LuaJIT's cap
--- of 65536 constants per function, so on a LuaJIT build every lookup fails with
--- "main function has more than 65536 constants" and then "No results matching
--- query". 3.12.0 added JSON manifest support, which sidesteps the limit.
--- See luarocks/luarocks#1797 and #1810; scripts/install-luarocks.sh upgrades.
local luarocks_min = { 3, 12, 0 }

--- Compare the running luarocks against luarocks_min.
--- @return boolean ok, string version
local function luarocks_supported()
    local out = vim.fn.system({ "luarocks", "--version" })
    local version = out:match("(%d+%.%d+%.%d+)") or out:match("(%d+%.%d+)") or "unknown"
    local major, minor, patch = version:match("(%d+)%.(%d+)%.?(%d*)")
    if not major then
        -- Unparseable version: assume it works rather than block startup.
        return true, version
    end
    local have = { tonumber(major), tonumber(minor), tonumber(patch) or 0 }
    for i = 1, 3 do
        if have[i] ~= luarocks_min[i] then
            return have[i] > luarocks_min[i], version
        end
    end
    return true, version
end

--- Run a command, reporting failure with the tool's own output.
--- Returns false and notifies on a non-zero exit so callers can clean up
--- rather than leaving a half-installed directory that blocks retries.
--- @param cmd string[]
--- @param what string
--- @return boolean
local function run(cmd, what)
    local out = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify(
            ("Failed to install %s (exit %d):\n%s"):format(what, vim.v.shell_error, vim.trim(out)),
            vim.log.levels.ERROR
        )
        return false
    end
    return true
end

--- Installer functions keyed by type.
--- Each returns true only if the package is usable afterwards.
--- @type table<string, fun(dir: string, pkg: string): boolean>
local installers = {
    --- Install an npm package and symlink its binaries.
    npm = function(dir, pkg)
        if not run({ "npm", "install", "--prefix", dir, pkg }, pkg) then
            return false
        end
        for name, _ in vim.fs.dir(dir .. "/node_modules/.bin") do
            vim.uv.fs_symlink(dir .. "/node_modules/.bin/" .. name, M.bin_dir .. "/" .. name)
        end
        return true
    end,
    --- Download a GitHub release tarball and symlink the binary.
    --- pkg format: "owner/repo@tag:binary_name"
    github = function(dir, pkg)
        local uname = vim.uv.os_uname()
        local os_name = uname.sysname == "Darwin" and "darwin" or "linux"
        local arch = uname.machine == "x86_64" and "x64" or "arm64"
        local owner_repo, tag, bin_name = pkg:match("^(.+)@(.+):(.+)$")
        -- Asset names include the version, e.g. lua-language-server-3.13.6-darwin-arm64.tar.gz
        local url = string.format(
            "https://github.com/%s/releases/download/%s/%s-%s-%s-%s.tar.gz",
            owner_repo, tag, bin_name, tag, os_name, arch
        )
        vim.fn.system({ "curl", "-fL", "-o", dir .. "/pkg.tar.gz", url })
        if vim.v.shell_error ~= 0 then
            vim.notify(("Failed to download %s from %s"):format(bin_name, url), vim.log.levels.ERROR)
            return false
        end
        if not run({ "tar", "xzf", dir .. "/pkg.tar.gz", "-C", dir }, bin_name) then
            return false
        end
        os.remove(dir .. "/pkg.tar.gz")
        if vim.fn.filereadable(dir .. "/bin/" .. bin_name) == 1 then
            -- Use an exec wrapper rather than a symlink: some servers (lua-language-server)
            -- resolve their runtime files relative to the executable's own path, which a
            -- symlink from bin/ would break.
            local wrapper = M.bin_dir .. "/" .. bin_name
            local f = io.open(wrapper, "w")
            if f then
                f:write(('#!/usr/bin/env bash\nexec "%s/bin/%s" "$@"\n'):format(dir, bin_name))
                f:close()
                vim.fn.setfperm(wrapper, "rwxr-xr-x")
            end
        end
        return true
    end,
    --- Install a luarock into the local rocks tree.
    luarocks = function(_, pkg)
        -- The tree-sitter parsers build through luarocks-build-treesitter-parser,
        -- which installs into --tree but is then require()d by luarocks itself.
        -- luarocks does not add its own --tree to package.path, so without this
        -- the build back-end is unloadable ("module 'luarocks.build.
        -- treesitter-parser' not found") even though the rock is installed.
        return run({
            "env",
            ("LUA_PATH=%s/share/lua/5.1/?.lua;%s/share/lua/5.1/?/init.lua;;"):format(rocks_root, rocks_root),
            ("LUA_CPATH=%s/lib/lua/5.1/?.so;;"):format(rocks_root),
            "luarocks",
            "--lua-version=5.1",
            "--tree=" .. rocks_root,
            "install",
            pkg,
        }, pkg)
    end,
}

--- Clear locks abandoned by a killed luarocks process.
--- luarocks locks a directory by hardlinking a temp file to lockfile.lfs and
--- removes both in unlock_access(); a lockfile left behind means the process was
--- killed before it could unlock, and every later run then fails ("requires
--- exclusive write access", or "File exists" for the download cache). No live
--- process holds them, so they are safe to drop. The download cache is shared
--- with any other luarocks invocation, so a lock stranded there blocks manifest
--- fetches for every rock.
local function clear_stale_locks()
    -- Mirror how luarocks itself resolves its download cache (core/cfg.lua:
    -- XDG_CACHE_HOME or ~/.cache, then "/luarocks"). Hardcoding ~/.cache would
    -- sweep a directory luarocks never uses whenever XDG_CACHE_HOME is set,
    -- leaving the real lock in place -- the exact failure this prevents.
    local cache_home = vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")
    local roots = { rocks_root, cache_home .. "/luarocks" }
    for _, root in ipairs(roots) do
        for _, name in ipairs({ "/lockfile.lfs", "/*/lockfile.lfs" }) do
            for _, f in ipairs(vim.fn.glob(root .. name, true, true)) do
                os.remove(f)
            end
        end
        -- Orphaned temp files accumulate one per failed attempt; they are inert
        -- but unbounded, so sweep them alongside the locks.
        for _, pat in ipairs({ "/.lock.tmp.*", "/*/.lock.tmp.*" }) do
            for _, f in ipairs(vim.fn.glob(root .. pat, true, true)) do
                os.remove(f)
            end
        end
    end
end

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
            -- The directory itself is the "installed" marker, so a failed install
            -- must not leave one behind or the package is never retried.
            if not installers[server.type](dir, server.pkg) then
                vim.fn.delete(dir, "rf")
            end
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
    clear_stale_locks()
    local missing = vim.tbl_filter(function(rock)
        return vim.fn.isdirectory(rocks_lib .. "/" .. rock) == 0
    end, rocks)
    if #missing > 0 then
        -- Checked only when there is work to do, so a healthy config never pays
        -- for it. Without this the failure surfaces as an unrelated-looking
        -- manifest parse error repeated for every rock.
        local ok, version = luarocks_supported()
        if not ok then
            vim.notify(
                ("luarocks %s cannot load the rocks manifest on LuaJIT; %d parser(s) not installed.\n")
                    :format(version, #missing)
                    .. "Upgrade to 3.12.0+: run scripts/install-luarocks.sh in this config.",
                vim.log.levels.ERROR
            )
            return
        end
    end
    for i, rock in ipairs(missing) do
        vim.notify(("Installing %s (%d/%d)..."):format(rock, i, #missing), vim.log.levels.INFO)
        if not installers.luarocks(nil, rock) then
            -- One failure means the toolchain is broken, not that this rock is
            -- special: installing the rest would repeat the same error N times
            -- and stall startup. Report once and move on.
            vim.notify(
                ("Rock install failed; skipping %d remaining parser(s)."):format(#missing - i),
                vim.log.levels.WARN
            )
            break
        end
    end
    -- Prepend installed rocks to runtimepath for treesitter parsers/queries
    for _, dir in ipairs(vim.fn.glob(rocks_lib .. "/tree-sitter-*/*/", true, true)) do
        vim.opt.runtimepath:prepend(dir)
    end
end

return M
