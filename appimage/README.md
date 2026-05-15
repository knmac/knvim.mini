# Neovim AppImages

Download Neovim Linux AppImages for use on systems without a package manager.

## Usage

```bash
./get_appimages.sh
```

The script auto-detects architecture (`x86_64`/`arm64`) and fetches the latest release version from GitHub.

## Directories

- `release/`: latest stable release ([source](https://github.com/neovim/neovim/releases))
- `unsupported/`: build for older glibc ([source](https://github.com/neovim/neovim-releases/releases))
