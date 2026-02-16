-- ~/.config/nvim/init.lua
-- Neovim Configuration for Mac DevOps - Tokyo Night Theme

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

	-- Tokyo Night colorscheme
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				transparent = false,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			require("nvim-tree").setup({
				view = { width = 35 },
				renderer = { group_empty = true, highlight_git = true },
				filters = { custom = { "^.git$" } },
			})
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "tokyonight", globalstatus = true },
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua", "vim", "vimdoc", "bash", "dockerfile", "terraform",
					"hcl", "yaml", "toml", "python", "go", "gomod", "javascript",
					"typescript", "json", "markdown", "markdown_inline",
					"gitcommit", "gitignore",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Mason (LSP installer)
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({ ui = { border = "rounded" } })
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls", "dockerls", "yamlls", "jsonls",
					"terraformls", "lua_ls", "pyright", "gopls",
				},
			})
		end,
	},

	-- LSP config
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf, silent = true }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				end,
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				severity_sort = true,
				float = { border = "rounded" },
			})

			local lspconfig = require("lspconfig")

			for _, server in ipairs({ "bashls", "dockerls", "jsonls", "terraformls", "pyright" }) do
				lspconfig[server].setup({ capabilities = capabilities })
			end

			lspconfig.yamlls.setup({
				capabilities = capabilities,
				settings = { yaml = { schemas = { kubernetes = "/*.yaml" }, schemaStore = { enable = true } } },
			})

			lspconfig.gopls.setup({
				capabilities = capabilities,
				settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
			})

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = { Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } },
			})
		end,
	},

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			local cmp = require("cmp")
			cmp.setup({
				snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
				window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" },
				}),
			})
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		config = function()
			require("telescope").setup({
				defaults = { prompt_prefix = " ", selection_caret = " ", path_display = { "smart" } },
			})
		end,
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},

	-- Which-key
	{ "folke/which-key.nvim", event = "VeryLazy", config = function() require("which-key").setup() end },

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
			require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
		end,
	},

	-- Comments (gcc / gc in visual)
	{ "numToStr/Comment.nvim", config = function() require("Comment").setup() end },

	-- Indent guides
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", config = function() require("ibl").setup() end },

	-- Lazygit integration
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = { "LazyGit" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
	},

	-- Tmux pane navigation
	{ "christoomey/vim-tmux-navigator", lazy = false },

}, {
	install = { colorscheme = { "tokyonight" } },
	checker = { enabled = false },
	change_detection = { enabled = false },
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<C-n>", ":NvimTreeToggle<CR>", opts)
keymap("n", "<leader>e", ":NvimTreeFindFile<CR>", opts)
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)
keymap("n", "<Esc>", ":nohlsearch<CR>", opts)
keymap("v", "p", '"_dP', opts)
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "J", ":move '>+1<CR>gv-gv", opts)
keymap("v", "K", ":move '<-2<CR>gv-gv", opts)

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local pos = vim.fn.getpos(".")
		pcall(function() vim.cmd([[%s/\s\+$//e]]) end)
		vim.fn.setpos(".", pos)
	end,
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
