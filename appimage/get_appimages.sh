#!/usr/bin/env bash
set -euo pipefail

# Fallback version if latest detection fails
version="v0.12.2"

# Detect architecture
arch=$(uname -m)
case "$arch" in
x86_64) arch_suffix="x86_64" ;;
aarch64 | arm64) arch_suffix="arm64" ;;
*)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

# Try to get latest version from GitHub API
latest=$(curl -sf https://api.github.com/repos/neovim/neovim/releases/latest | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
version="${latest:-$version}"

echo "Downloading Neovim $version for $arch_suffix"

# Create directories
mkdir -p release unsupported

# Download release (latest stable)
echo "Downloading release..."
curl -fLo "release/nvim-linux-${arch_suffix}.appimage" \
    "https://github.com/neovim/neovim/releases/download/${version}/nvim-linux-${arch_suffix}.appimage"
chmod +x "release/nvim-linux-${arch_suffix}.appimage"

# Download unsupported (older glibc build, may not exist for all architectures)
echo "Downloading unsupported..."
if curl -fLo "unsupported/nvim-linux-${arch_suffix}.appimage" \
    "https://github.com/neovim/neovim-releases/releases/download/${version}/nvim-linux-${arch_suffix}.appimage"; then
    chmod +x "unsupported/nvim-linux-${arch_suffix}.appimage"
else
    echo "Unsupported build not available for ${arch_suffix}, skipping."
    rmdir --ignore-fail-on-non-empty unsupported 2>/dev/null || true
fi

echo "Done."
