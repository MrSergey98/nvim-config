.PHONY: all install nvim deps plugins mason

all: install

install: nvim deps plugins mason
	@echo "✓ All done. Restart nvim."

nvim:
	@echo "→ Installing Neovim..."
	@sudo apt-get remove -y neovim 2>/dev/null || true
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
	tar -xf nvim-linux-x86_64.tar.gz
	sudo cp -r nvim-linux-x86_64/* /usr/local/
	rm -rf nvim-linux-x86_64 nvim-linux-x86_64.tar.gz
	@echo "✓ Neovim $$(nvim --version | head -1) installed"

deps:
	@echo "→ Checking system dependencies..."
	@sudo apt-get install -y \
		cmake make gcc g++ ninja-build gettext unzip curl git \
		ripgrep fzf python3 python3-pip pipx
	@if which poetry > /dev/null 2>&1; then \
		echo "✓ poetry already installed"; \
	else \
		echo "→ Installing poetry..."; \
		pipx install poetry; \
	fi
	@if which lazygit > /dev/null 2>&1; then \
		echo "✓ lazygit already installed"; \
	else \
		echo "→ Installing lazygit..."; \
		LAZYGIT_VERSION=$$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') && \
		curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v$${LAZYGIT_VERSION}/lazygit_$${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
		tar -xf /tmp/lazygit.tar.gz -C /tmp && \
		sudo install /tmp/lazygit /usr/local/bin; \
		echo "✓ lazygit installed"; \
	fi
	@if which lazydocker > /dev/null 2>&1; then \
		echo "✓ lazydocker already installed"; \
	else \
		echo "→ Installing lazydocker..."; \
		LAZYDOCKER_VERSION=$$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') && \
		curl -Lo /tmp/lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v$${LAZYDOCKER_VERSION}/lazydocker_$${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz" && \
		tar -xf /tmp/lazydocker.tar.gz -C /tmp && \
		sudo install /tmp/lazydocker /usr/local/bin; \
		echo "✓ lazydocker installed"; \
	fi
	@if python3 -c "import debugpy" 2>/dev/null; then \
		echo "✓ debugpy already installed"; \
	else \
		echo "→ Installing debugpy..."; \
		pip3 install debugpy --break-system-packages || pip3 install debugpy; \
	fi

plugins:
	@echo "→ Installing Neovim plugins..."
	nvim --headless "+Lazy! sync" +qa || true

mason:
	@echo "→ Installing Mason packages..."
	nvim --headless \
		+"MasonInstall basedpyright ruff python-lsp-server lua-language-server stylua django-language-server debugpy" \
		+qa || true
