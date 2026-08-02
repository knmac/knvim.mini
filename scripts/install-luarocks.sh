#!/usr/bin/env bash
# Install luarocks new enough to fetch tree-sitter parsers on a LuaJIT host.
#
# Why: luarocks below 3.12.0 loads a rocks server manifest by compiling it as a
# Lua chunk. luarocks.org's manifest has outgrown LuaJIT's limit of 65536
# constants per function, so on a LuaJIT build every lookup dies with
#   Error loading file: ... main function has more than 65536 constants
# and then reports "No results matching query were found for Lua 5.1", which
# looks like the rock is missing rather than like a parser failure.
# 3.12.0 added JSON manifest support and sidesteps the limit.
# Refs: luarocks/luarocks#1797, luarocks/luarocks#1810
#
# Installs to ~/.local by default, which needs no root. Pass a prefix to
# override, e.g. `install-luarocks.sh /usr/local` (then run it under sudo).

set -euo pipefail

VERSION="${LUAROCKS_VERSION:-3.13.0}"
# Keep in sync with luarocks_min in lua/core/deps.lua: below this, manifest
# lookups fail on LuaJIT. VERSION is what we install; MINIMUM is what we accept.
MINIMUM="3.12.0"
PREFIX="${1:-$HOME/.local}"
FORCE="${FORCE:-}"

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# Needed by the version check below, so required even when nothing is built.
for tool in grep head; do
    command -v "$tool" >/dev/null || die "$tool is required but not on PATH"
done

# Version of the luarocks at $1, or empty if it is not runnable.
luarocks_version() {
    [ -x "$1" ] || return 0
    "$1" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}

# True when $1 >= $2, comparing numerically field by field. Missing fields count
# as 0 so a bare "3.12" compares equal to "3.12.0".
version_ge() {
    local a b x y i
    IFS=. read -r -a a <<<"$1"
    IFS=. read -r -a b <<<"$2"
    for i in 0 1 2; do
        x="${a[i]:-0}"; y="${b[i]:-0}"
        (( x > y )) && return 0
        (( x < y )) && return 1
    done
    return 0
}

# Nothing below needs building if a usable luarocks is already reachable. This
# runs before the toolchain checks on purpose: those exist only to gate a build,
# so a machine with no compiler but a good luarocks should succeed, not die.
# PATH is what matters -- deps.lua shells out to bare `luarocks` -- so check it
# first, then $PREFIX in case it is installed but not yet on PATH.
if [ -z "$FORCE" ]; then
    for cand in "$(command -v luarocks || true)" "$PREFIX/bin/luarocks"; do
        [ -n "$cand" ] || continue
        have="$(luarocks_version "$cand")"
        [ -n "$have" ] || continue
        if version_ge "$have" "$MINIMUM"; then
            log "luarocks $have at $cand already satisfies >= $MINIMUM; nothing to do"
            log "Re-run with FORCE=1 to install $VERSION into $PREFIX anyway."
            exit 0
        fi
        log "luarocks $have at $cand is older than $MINIMUM"
    done
fi

for tool in curl tar make gcc unzip; do
    command -v "$tool" >/dev/null || die "$tool is required but not on PATH"
done

INTERP="$(command -v luajit || true)"
[ -n "$INTERP" ] || die "luajit not found on PATH"

# LuaJIT ships its 5.1 headers in their own directory; the ones directly in
# <prefix>/include often belong to a newer standalone Lua, and configure needs
# the ones matching the interpreter it will run under. Derive the location from
# the interpreter rather than assuming /usr, so a Homebrew or otherwise
# non-system luajit resolves to its own headers.
if [ -z "${LUA_INCDIR:-}" ]; then
    luajit_prefix="$(cd "$(dirname "$INTERP")/.." && pwd)"
    for cand in "$luajit_prefix"/include/luajit-2.*; do
        [ -f "$cand/lua.h" ] && INCDIR="$cand" && break
    done
    : "${INCDIR:=$luajit_prefix/include}"
else
    INCDIR="$LUA_INCDIR"
fi
[ -f "$INCDIR/lua.h" ] || die "no lua.h under $INCDIR (override with LUA_INCDIR=...)"

workdir="$(mktemp -d)"
# Discard the tree once it has served its purpose, but keep it when a step fails
# so configure/make output can be inspected.
cleanup() {
    local code=$?
    if [ "$code" -eq 0 ]; then
        rm -rf "$workdir"
    else
        printf 'Build tree kept for inspection: %s\n' "$workdir" >&2
    fi
}
trap cleanup EXIT

log "Downloading luarocks $VERSION"
curl -fsSL -o "$workdir/luarocks.tar.gz" \
    "https://luarocks.org/releases/luarocks-$VERSION.tar.gz"

log "Extracting"
tar xzf "$workdir/luarocks.tar.gz" -C "$workdir"

cd "$workdir/luarocks-$VERSION"

log "Configuring (prefix=$PREFIX, interpreter=$INTERP, include=$INCDIR)"
./configure \
    --prefix="$PREFIX" \
    --lua-version=5.1 \
    --with-lua-interpreter=luajit \
    --with-lua-include="$INCDIR" >/dev/null

log "Building"
make >/dev/null

log "Installing to $PREFIX"
make install >/dev/null

installed="$(luarocks_version "$PREFIX/bin/luarocks")"
log "Installed: luarocks $installed"
# Guards against LUAROCKS_VERSION being set to something deps.lua will reject.
version_ge "$installed" "$MINIMUM" \
    || die "installed luarocks $installed is older than the required $MINIMUM"

# A stale luarocks earlier on PATH would keep shadowing the new one, and the
# symptom (unchanged version, same manifest error) is easy to misread.
found="$(command -v luarocks || true)"
if [ "$found" != "$PREFIX/bin/luarocks" ]; then
    printf '\033[1;33mWarning:\033[0m PATH still resolves luarocks to %s\n' "${found:-<none>}"
    printf '         Put %s/bin ahead of it, or remove the older install.\n' "$PREFIX"
fi

cat <<'EOF'

Next: open nvim and let the tree-sitter parsers install. They land in
stdpath("data")/rocks and only install once; later launches stay quiet.
EOF
