local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("ruff", {
    capabilities = capabilities,
    init_options = {
        settings = {
            lineLength = 120,
			preview = true,
            lint = {
                select = {
                    "E",    -- pycodestyle ошибки
                    "W",    -- pycodestyle предупреждения
                    "F",    -- pyflakes (неиспользуемые импорты, переменные)
                    "I",    -- isort (порядок импортов)
                    "N",    -- pep8 naming conventions
                    "UP",   -- pyupgrade (устаревший синтаксис)
                    "B",    -- flake8-bugbear (частые баги)
                    "C4",   -- flake8-comprehensions (упрощение list/dict comprehensions)
                    "SIM",  -- flake8-simplify (упрощение кода)
                    "DJ",   -- flake8-django (django специфичные проверки)
                },
                ignore = {
                    "ANN001",  -- missing type annotation
                    "RUF012",
                    "RUF045",
                    "E501",    -- line too long (контролируется lineLength выше)
                    "SIM108",  -- ternary operator (спорное правило)
                },
            },
        },
    }
})
vim.lsp.enable("ruff")
