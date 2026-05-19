.PHONY: all install deps plugins mason

all: install

install: deps plugins mason
	@echo "✓ All done. Restart nvim."

deps:
	@echo "→ Installing system dependencies..."
	sudo apt-get install -y \
		cmake make gcc g++ ninja-build gettext unzip curl git \
		ripgrep fzf python3 python3-pip pipx

	@echo "→ Installing poetry..."
	pipx install poetry || true

	@echo "→ Installing lazygit..."
	LAZYGIT_VERSION=$$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') && \
	curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v$${LAZYGIT_VERSION}/lazygit_$${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
	tar -xf /tmp/lazygit.tar.gz -C /tmp && \
	sudo install /tmp/lazygit /usr/local/bin

	@echo "→ Installing lazydocker..."
	LAZYDOCKER_VERSION=$$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') && \
	curl -Lo /tmp/lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v$${LAZYDOCKER_VERSION}/lazydocker_$${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz" && \
	tar -xf /tmp/lazydocker.tar.gz -C /tmp && \
	sudo install /tmp/lazydocker /usr/local/bin

	@echo "→ Installing debugpy..."
	pip3 install debugpy --break-system-packages || pip3 install debugpy

plugins:
	@echo "→ Installing Neovim plugins..."
	nvim --headless "+Lazy! sync" +qa

mason:
	@echo "→ Installing Mason packages..."
	nvim --headless \
		+"MasonInstall basedpyright ruff python-lsp-server lua-language-server stylua django-language-server debugpy" \
		+qa
