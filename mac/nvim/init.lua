-- ~/.config/nvim/init.lua
-- Neovim 2026 — Mac DevOps (Tokyo Night)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- BOOTSTRAP LAZY.NVIM
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- SETTINGS
-- ============================================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.cursorline = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.undofile = true
vim.opt.swapfile = false

vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.loader.enable()

-- ============================================================================
-- PLUGINS
-- ============================================================================

require("lazy").setup({

    -- ── Theme ──────────────────────────────────────────────────────────────
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            require("tokyonight").setup({ style = "night", transparent = false })
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- ── snacks.nvim — picker, explorer, lazygit, terminal, dashboard, indent,
    --                 notifier, statuscolumn, bigfile, quickfile, scope, words.
    --                 Replaces ~8 separate plugins.
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            picker     = { enabled = true },
            explorer   = { enabled = true, replace_netrw = true },
            lazygit    = { enabled = true, configure = true },
            terminal   = { enabled = true },
            notifier   = { enabled = true, timeout = 3000 },
            indent     = { enabled = true },
            statuscolumn = { enabled = true },
            bigfile    = { enabled = true },
            quickfile  = { enabled = true },
            scope      = { enabled = true },
            words      = { enabled = true },
            dashboard  = { enabled = true, preset = { header = "  Mac DevOps  " } },
        },
    },

    -- ── Treesitter (main branch — 2025 rewrite, new API) ────────────────
    -- Does not support lazy-loading; opt-in to highlight/indent via FileType autocmds.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local parsers = {
                "lua", "vim", "vimdoc", "query",
                "bash", "dockerfile", "terraform", "hcl",
                "yaml", "toml", "json", "jsonc",
                "python", "go", "gomod", "gosum", "gowork",
                "javascript", "typescript",
                "markdown", "markdown_inline",
                "gitcommit", "gitignore", "git_rebase", "gitattributes",
                "regex", "diff",
            }

            -- Install parsers only when tree-sitter CLI is available.
            -- Avoids ENOENT errors on fresh machines before brew install tree-sitter.
            if vim.fn.executable("tree-sitter") == 1 then
                require("nvim-treesitter").install(parsers)
            end

            vim.api.nvim_create_autocmd("FileType", {
                pattern = parsers,
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },

    -- ── Schema store for JSON/YAML LSPs ───────────────────────────────────
    { "b0o/SchemaStore.nvim", version = false, lazy = true },

    -- ── Mason v2 + LSP ────────────────────────────────────────────────────
    { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = {
                "yamlls", "terraformls", "helm_ls", "dockerls",
                "bashls", "basedpyright", "gopls", "marksman",
                "jsonls", "lua_ls",
            },
            automatic_enable = true,
        },
    },

    -- ── Mason tool installer (CLI binaries for conform + nvim-lint) ──────
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "hadolint", "tflint", "actionlint",
                "shellcheck", "yamllint", "ruff",
                "stylua", "shfmt", "prettier",
                "markdownlint-cli2", "yamlfmt", "goimports",
            },
            run_on_start = true,
        },
    },

    -- ── Completion: blink.cmp ─────────────────────────────────────────────
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        opts = {
            keymap = { preset = "default" },
            appearance = { nerd_font_variant = "mono" },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            signature = { enabled = true },
        },
    },

    -- ── File explorer companion: oil.nvim (buffer-as-directory) ──────────
    {
        "stevearc/oil.nvim",
        opts = {
            default_file_explorer = false,  -- snacks.explorer is the sidebar
            view_options = { show_hidden = true },
        },
    },

    -- ── Statusline ────────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = { theme = "tokyonight", globalstatus = true },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- ── Git ───────────────────────────────────────────────────────────────
    { "lewis6991/gitsigns.nvim", opts = {} },
    { "sindrets/diffview.nvim",  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" } },

    -- ── Discoverability / motion / diagnostics ────────────────────────────
    { "folke/which-key.nvim",     event = "VeryLazy", opts = {} },
    { "folke/flash.nvim",         event = "VeryLazy", opts = {} },
    { "folke/trouble.nvim",       cmd = "Trouble", opts = {} },
    { "folke/todo-comments.nvim", event = "VeryLazy", opts = {} },

    -- ── Editor utilities (mini.*) ─────────────────────────────────────────
    { "echasnovski/mini.surround", version = false, event = "VeryLazy", opts = {} },
    { "echasnovski/mini.pairs",    version = false, event = "VeryLazy", opts = {} },
    { "echasnovski/mini.ai",       version = false, event = "VeryLazy", opts = {} },
    { "echasnovski/mini.comment",  version = false, event = "VeryLazy", opts = {} },

    -- ── Markdown ──────────────────────────────────────────────────────────
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown" },
        opts = {},
    },

    -- ── Format-on-save ────────────────────────────────────────────────────
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                lua       = { "stylua" },
                python    = { "ruff_format" },
                go        = { "goimports", "gofmt" },
                terraform = { "terraform_fmt" },
                hcl       = { "terraform_fmt" },
                yaml      = { "yamlfmt" },
                json      = { "prettier" },
                markdown  = { "prettier" },
                sh        = { "shfmt" },
                bash      = { "shfmt" },
            },
            format_on_save = { lsp_fallback = true, timeout_ms = 1000 },
        },
    },

    -- ── Linting ───────────────────────────────────────────────────────────
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost", "InsertLeave" },
        config = function()
            require("lint").linters_by_ft = {
                dockerfile = { "hadolint" },
                terraform  = { "tflint" },
                yaml       = { "yamllint" },
                python     = { "ruff" },
                sh         = { "shellcheck" },
                bash       = { "shellcheck" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                callback = function() require("lint").try_lint() end,
            })
        end,
    },

}, {
    install = { colorscheme = { "tokyonight" } },
    checker = { enabled = false },
    change_detection = { enabled = false },
})

-- ============================================================================
-- LSP CONFIG (Neovim 0.11+ native vim.lsp.config API)
-- ============================================================================

-- Defer LSP config until lazy.nvim has loaded plugins (blink.cmp, SchemaStore).
local function setup_lsp()
    local caps = vim.lsp.protocol.make_client_capabilities()
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
        caps = vim.tbl_deep_extend("force", caps, blink.get_lsp_capabilities())
    end
    vim.lsp.config('*', { capabilities = caps })

    -- yamlls — Kubernetes + SchemaStore + CRD store
    local ok_schema, schemastore = pcall(require, "schemastore")
    local yaml_schemas = { kubernetes = { "k8s/**/*.yaml", "*.k8s.yaml", "manifests/**/*.yaml", "deploy/**/*.yaml" } }
    if ok_schema then
        yaml_schemas = vim.tbl_deep_extend("force", schemastore.yaml.schemas(), yaml_schemas)
    end
    vim.lsp.config('yamlls', {
        settings = {
            yaml = {
                schemas = yaml_schemas,
                schemaStore = { enable = false, url = "" },
                kubernetesCRDStore = { enable = true },
                validate = true,
                completion = true,
                hover = true,
            },
        },
    })

    if ok_schema then
        vim.lsp.config('jsonls', {
            settings = {
                json = {
                    schemas = schemastore.json.schemas(),
                    validate = { enable = true },
                },
            },
        })
    end

    vim.lsp.config('gopls', {
        settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
    })

    vim.lsp.config('lua_ls', {
        settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } }, telemetry = { enable = false } } },
    })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = setup_lsp,
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    severity_sort = true,
    float = { border = "rounded" },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "gd",          vim.lsp.buf.definition,     opts)
        vim.keymap.set("n", "gD",          vim.lsp.buf.declaration,    opts)
        vim.keymap.set("n", "gi",          vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr",          vim.lsp.buf.references,     opts)
        vim.keymap.set("n", "K",           vim.lsp.buf.hover,          opts)
        vim.keymap.set("n", "<leader>rn",  vim.lsp.buf.rename,         opts)
        vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action,    opts)
        vim.keymap.set("n", "<leader>f",   function() require("conform").format({ async = true, lsp_fallback = true }) end, opts)
        vim.keymap.set("n", "[d",          vim.diagnostic.goto_prev,   opts)
        vim.keymap.set("n", "]d",          vim.diagnostic.goto_next,   opts)
    end,
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local keymap = vim.keymap.set
local opts = { silent = true }

-- File explorer (snacks.explorer replaces nvim-tree)
keymap("n", "<C-n>",       function() Snacks.explorer() end,        opts)
keymap("n", "<leader>e",   function() Snacks.explorer.reveal() end, opts)

-- oil.nvim — open parent directory as a buffer
keymap("n", "-", "<cmd>Oil<cr>", { desc = "Open parent dir" })

-- Picker (snacks.picker replaces telescope)
keymap("n", "<leader>ff",  function() Snacks.picker.files() end,     opts)
keymap("n", "<leader>fg",  function() Snacks.picker.grep() end,      opts)
keymap("n", "<leader>fb",  function() Snacks.picker.buffers() end,   opts)
keymap("n", "<leader>fh",  function() Snacks.picker.help() end,      opts)
keymap("n", "<leader>fr",  function() Snacks.picker.recent() end,    opts)

-- Lazygit (snacks.lazygit replaces lazygit.nvim)
keymap("n", "<leader>gg",  function() Snacks.lazygit() end,          opts)
keymap("n", "<leader>gd",  "<cmd>DiffviewOpen<cr>",                  opts)

-- Claude Code in floating terminal
keymap("n", "<leader>cc",  function()
    Snacks.terminal.toggle("claude", { win = { position = "float", width = 0.9, height = 0.9 } })
end, { desc = "Toggle Claude Code" })

-- Terminal toggle (generic shell)
keymap("n", "<leader>tt",  function() Snacks.terminal() end, { desc = "Toggle terminal" })

-- Trouble
keymap("n", "<leader>xx",  "<cmd>Trouble diagnostics toggle<cr>",            opts)
keymap("n", "<leader>xX",  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", opts)

-- Flash
keymap({ "n", "x", "o" }, "s", function() require("flash").jump() end,        { desc = "Flash" })
keymap({ "n", "x", "o" }, "S", function() require("flash").treesitter() end,  { desc = "Flash treesitter" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Buffers
keymap("n", "<S-l>",       ":bnext<CR>",     opts)
keymap("n", "<S-h>",       ":bprevious<CR>", opts)
keymap("n", "<leader>bd",  ":bdelete<CR>",   opts)

-- Misc
keymap("n", "<Esc>",       ":nohlsearch<CR>", opts)
keymap("v", "p",           '"_dP',           opts)
keymap("v", "<",           "<gv",            opts)
keymap("v", ">",           ">gv",            opts)
keymap("v", "J",           ":move '>+1<CR>gv-gv", opts)
keymap("v", "K",           ":move '<-2<CR>gv-gv", opts)

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

local function set_indent(ft, size)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = ft,
        callback = function()
            vim.opt_local.tabstop = size
            vim.opt_local.shiftwidth = size
        end,
    })
end
set_indent({ "yaml", "json", "terraform", "hcl", "dockerfile", "helm" }, 2)
set_indent({ "markdown" }, 2)
