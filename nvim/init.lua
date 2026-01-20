-- ~/.config/nvim/init.lua
-- Modern Neovim Configuration for DevOps
-- Optimized for simplicity, performance, and DevOps workflows

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Use vim.loop for backward compatibility with Neovim < 0.10
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

-- Line numbers and display
vim.opt.number = true -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.wrap = false -- Don't wrap lines
vim.opt.scrolloff = 8 -- Keep 8 lines visible when scrolling
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible when scrolling

-- Indentation and tabs
vim.opt.tabstop = 4 -- Tab width
vim.opt.shiftwidth = 4 -- Indent width
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.autoindent = true -- Auto-indent new lines
vim.opt.smartindent = true -- Smart auto-indenting

-- Search settings
vim.opt.incsearch = true -- Incremental search
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true -- Case-sensitive if uppercase present
vim.opt.hlsearch = true -- Highlight search results

-- Editor behavior
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.hidden = true -- Allow hidden buffers
vim.opt.updatetime = 250 -- Faster completion (default 4000ms)
vim.opt.timeoutlen = 300 -- Faster key sequence timeout
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below

-- File handling
vim.opt.undofile = true -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undodir")
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false -- Disable backup files

-- UI improvements
vim.opt.termguicolors = true -- True color support
vim.opt.background = "dark" -- Dark background
vim.opt.laststatus = 3 -- Global statusline
vim.opt.showmode = false -- Don't show mode (shown in statusline)
vim.opt.cursorline = true -- Highlight current line
vim.opt.completeopt = "menuone,noselect" -- Better completion experience

-- File type detection
vim.opt.filetype = "on"
vim.opt.syntax = "on"

-- ============================================================================
-- PLUGIN CONFIGURATION
-- ============================================================================

require("lazy").setup({
	-- ========================================================================
	-- CORE UI PLUGINS
	-- ========================================================================

	-- Modern colorscheme with excellent DevOps language support
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- mocha, macchiato, frappe, latte
				transparent_background = false,
				term_colors = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					telescope = true,
					treesitter = true,
					which_key = true,
					mason = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Enhanced file explorer with DevOps file type recognition
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Disable netrw for nvim-tree
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			require("nvim-tree").setup({
				disable_netrw = true,
				hijack_netrw = true,
				respect_buf_cwd = true,
				sync_root_with_cwd = true,
				update_focused_file = {
					enable = true,
					update_root = true,
				},
				diagnostics = {
					enable = true,
					show_on_dirs = true,
					icons = {
						hint = "",
						info = "",
						warning = "",
						error = "",
					},
				},
				actions = {
					open_file = {
						quit_on_open = true,
						resize_window = true,
					},
				},
				view = {
					width = 40,
					side = "left",
					preserve_window_proportions = true,
				},
				renderer = {
					group_empty = true,
					highlight_git = true,
					full_name = false,
					highlight_opened_files = "name",
					root_folder_label = ":~:s?$?/..?",
					indent_markers = {
						enable = true,
						inline_arrows = true,
						icons = {
							corner = "└",
							edge = "│",
							item = "│",
							bottom = "─",
							none = " ",
						},
					},
					icons = {
						webdev_colors = true,
						git_placement = "before",
						padding = " ",
						symlink_arrow = " ➛ ",
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
					},
				},
				git = {
					enable = true,
					ignore = false,
				},
				filters = {
					dotfiles = false,
					git_clean = false,
					no_buffer = false,
					custom = { "^.git$" },
				},
			})
		end,
	},

	-- Modern statusline with DevOps context
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = { "alpha", "dashboard", "NvimTree" },
						winbar = {},
					},
					globalstatus = true,
					refresh = {
						statusline = 1000,
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						{
							"diff",
							symbols = { added = "", modified = "", removed = "" },
						},
						{
							"diagnostics",
							sources = { "nvim_lsp" },
							symbols = { error = "", warn = "", info = "", hint = "" },
						},
					},
					lualine_c = {
						{
							"filename",
							file_status = true,
							newfile_status = false,
							path = 1, -- Relative path
						},
					},
					lualine_x = {
						{
							"filetype",
							colored = true,
							icon_only = false,
						},
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- ========================================================================
	-- SYNTAX HIGHLIGHTING & LANGUAGE SUPPORT
	-- ========================================================================

	-- Advanced syntax highlighting for DevOps languages
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects", -- Advanced text objects
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					-- Core languages
					"bash",
					"dockerfile",
					"json",
					"lua",
					"python",
					"yaml",
					"vim",
					"vimdoc",
					"markdown",
					"markdown_inline",
					-- DevOps specific
					"terraform",
					"hcl",
					"go",
					"javascript",
					"typescript",
					"toml",
					"ini",
					"gitignore",
					"gitcommit",
					"diff",
					-- Additional useful languages
					"regex",
					"sql",
					"html",
					"css",
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						node_incremental = "<CR>",
						scope_incremental = "<S-CR>",
						node_decremental = "<BS>",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
				},
			})
		end,
	},

	-- ========================================================================
	-- LSP & CODE INTELLIGENCE
	-- ========================================================================

	-- LSP package manager
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- Bridge between mason and lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					-- DevOps essentials
					"bashls", -- Bash
					"dockerls", -- Docker
					"docker_compose_language_service", -- Docker Compose
					"yamlls", -- YAML
					"jsonls", -- JSON
					"terraformls", -- Terraform
					"ansiblels", -- Ansible
					"helm_ls", -- Helm
					-- Programming languages
					"lua_ls", -- Lua
					"pyright", -- Python
					"gopls", -- Go
					-- Additional useful servers
					"marksman", -- Markdown
					"taplo", -- TOML
				},
				automatic_installation = true,
			})
		end,
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Enhanced capabilities for better completion
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- LSP servers configuration
			local servers = {
				bashls = {},
				dockerls = {},
				docker_compose_language_service = {},
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
							gofumpt = true,
						},
					},
				},
				jsonls = {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
									"${3rd}/luv/library",
								},
							},
							telemetry = { enable = false },
							hint = { enable = true },
						},
					},
				},
				marksman = {},
				pyright = {
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				},
				taplo = {},
				terraformls = {},
				ansiblels = {},
				helm_ls = {},
				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,
							format = {
								enable = true,
							},
							hover = true,
							completion = true,
							validate = true,
							schemas = {
								["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
								["https://json.schemastore.org/ansible-stable-2.9.json"] = "*/playbooks/*.yml",
								["https://json.schemastore.org/kustomization.json"] = "kustomization.yaml",
								["https://json.schemastore.org/chart.json"] = "Chart.yaml",
								["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.yml",
								["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.yaml",
								kubernetes = "*.yaml",
							},
						},
					},
				},
			}

			-- Setup all LSP servers
			for server, config in pairs(servers) do
				config.capabilities = capabilities
				lspconfig[server].setup(config)
			end

			-- Better diagnostics configuration
			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "●",
				},
				signs = {
					active = true,
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			-- Diagnostic signs
			local signs = {
				{ name = "DiagnosticSignError", text = "" },
				{ name = "DiagnosticSignWarn", text = "" },
				{ name = "DiagnosticSignHint", text = "" },
				{ name = "DiagnosticSignInfo", text = "" },
			}
			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end

			-- LSP keymaps and autocommands
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local opts = { buffer = args.buf, silent = true }

					-- Enable completion triggered by <c-x><c-o>
					if client.server_capabilities.completionProvider then
						vim.api.nvim_buf_set_option(args.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
					end

					-- Enable tag navigation
					if client.server_capabilities.definitionProvider then
						vim.api.nvim_buf_set_option(args.buf, "tagfunc", "v:lua.vim.lsp.tagfunc")
					end

					-- Navigation
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

					-- Documentation
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

					-- Diagnostics
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
					vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "<leader>lD", vim.diagnostic.setloclist, opts)

					-- Code actions
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

					-- Formatting (prefer conform but fallback to LSP)
					if client.server_capabilities.documentFormattingProvider then
						vim.keymap.set("n", "<leader>lf", function()
							local conform_ok, conform = pcall(require, "conform")
							if conform_ok then
								conform.format({ async = true, lsp_fallback = true })
							else
								vim.lsp.buf.format({ async = true })
							end
						end, opts)
					end

					-- Workspace folders
					vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)

					-- Highlight references under cursor
					if client.server_capabilities.documentHighlightProvider then
						local highlight_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = args.buf,
							group = highlight_group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd("CursorMoved", {
							buffer = args.buf,
							group = highlight_group,
							callback = vim.lsp.buf.clear_references,
						})
					end

					-- Register LSP-specific which-key mappings when LSP attaches
					local wk_ok, wk = pcall(require, "which-key")
					if wk_ok then
						wk.add({
							{ "<leader>l", group = "LSP", buffer = args.buf },
							{ "<leader>lr", desc = "References", buffer = args.buf },
							{ "<leader>lf", desc = "Format", buffer = args.buf },
							{ "<leader>ld", desc = "Line Diagnostics", buffer = args.buf },
							{ "<leader>lD", desc = "Workspace Diagnostics", buffer = args.buf },
							{ "<leader>w", group = "Workspace", buffer = args.buf },
							{ "<leader>wa", desc = "Add Workspace Folder", buffer = args.buf },
							{ "<leader>wr", desc = "Remove Workspace Folder", buffer = args.buf },
							{ "<leader>wl", desc = "List Workspace Folders", buffer = args.buf },
							{ "<leader>c", group = "Code", buffer = args.buf },
							{ "<leader>ca", desc = "Code Action", buffer = args.buf },
							{ "<leader>rn", desc = "Rename", buffer = args.buf },
							{ "gd", desc = "Go to Definition", buffer = args.buf },
							{ "gD", desc = "Go to Declaration", buffer = args.buf },
							{ "gi", desc = "Go to Implementation", buffer = args.buf },
							{ "gt", desc = "Go to Type Definition", buffer = args.buf },
							{ "K", desc = "Hover Documentation", buffer = args.buf },
							{ "[d", desc = "Previous Diagnostic", buffer = args.buf },
							{ "]d", desc = "Next Diagnostic", buffer = args.buf },
						})
					end
				end,
			})
		end,
	},

	-- JSON Schema support
	{
		"b0o/schemastore.nvim",
	},

	-- ========================================================================
	-- AUTOCOMPLETION
	-- ========================================================================

	-- Main completion engine
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completions
			"hrsh7th/cmp-buffer", -- Buffer completions
			"hrsh7th/cmp-path", -- Path completions
			"hrsh7th/cmp-cmdline", -- Command line completions
			"L3MON4D3/LuaSnip", -- Snippet engine
			"saadparwaiz1/cmp_luasnip", -- Snippet completions
			"rafamadriz/friendly-snippets", -- Snippet collection
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Load snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-e>"] = cmp.mapping.abort(), -- close suggestions
					["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm selection

					["<C-Up>"] = cmp.mapping.select_prev_item(), -- navigate up
					["<C-Down>"] = cmp.mapping.select_next_item(), -- navigate down

					-- Tab is *not* used for cmp; reserved for Codeium
					["<Tab>"] = function(fallback)
						fallback()
					end,
					["<S-Tab>"] = function(fallback)
						fallback()
					end,
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "buffer", priority = 500 },
					{ name = "path", priority = 250 },
				}),
				formatting = {
					format = function(entry, vim_item)
						-- Kind icons
						local kind_icons = {
							Text = "",
							Method = "󰆧",
							Function = "󰊕",
							Constructor = "",
							Field = "󰇽",
							Variable = "󰂡",
							Class = "󰠱",
							Interface = "",
							Module = "",
							Property = "󰜢",
							Unit = "",
							Value = "󰎠",
							Enum = "",
							Keyword = "󰌋",
							Snippet = "",
							Color = "󰏘",
							File = "󰈙",
							Reference = "",
							Folder = "󰉋",
							EnumMember = "",
							Constant = "󰏿",
							Struct = "",
							Event = "",
							Operator = "󰆕",
							TypeParameter = "󰅲",
						}

						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})

			-- Command line completions
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})
		end,
	},

	-- AI-powered code completion (optional but very helpful for DevOps)
	{
		"Exafunction/codeium.vim",
		event = "BufEnter",
		config = function()
			-- Accept suggestion with Tab when no completion menu is visible
			vim.keymap.set("i", "<Tab>", function()
				if vim.fn.pumvisible() == 0 then
					return vim.fn["codeium#Accept"]()
				else
					return "<Tab>"
				end
			end, { expr = true, silent = true })

			-- Cycle through suggestions
			vim.keymap.set("i", "<C-;>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true, silent = true })
			vim.keymap.set("i", "<C-,>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true, silent = true })

			-- Clear suggestion
			vim.keymap.set("i", "<C-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, silent = true })
		end,
	},

	-- ========================================================================
	-- GIT INTEGRATION
	-- ========================================================================

	-- Git signs in the gutter
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				current_line_blame = false,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 1000,
				},
				preview_config = {
					border = "rounded",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]h", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					map("n", "[h", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk)
					map("n", "<leader>hr", gs.reset_hunk)
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gs.stage_buffer)
					map("n", "<leader>hu", gs.undo_stage_hunk)
					map("n", "<leader>hR", gs.reset_buffer)
					map("n", "<leader>hp", gs.preview_hunk)
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gs.toggle_current_line_blame)
					map("n", "<leader>hd", gs.diffthis)
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end)
					map("n", "<leader>td", gs.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},

	-- Git interface
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gwrite", "Gread", "Gdiffsplit" },
	},

	-- Modern git interface
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("neogit").setup({
				integrations = {
					telescope = true,
					diffview = true,
				},
			})
		end,
	},

	-- Enhanced diff viewing
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = function()
			require("diffview").setup({})
		end,
	},

	-- ========================================================================
	-- TELESCOPE (FUZZY FINDER)
	-- ========================================================================

	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					path_display = { "smart" },
					file_ignore_patterns = {
						"%.git/",
						"node_modules/",
						"%.terraform/",
						"%.vscode/",
						"__pycache__/",
						"%.pyc",
						"%.pyo",
						"%.DS_Store",
						"target/",
						"build/",
						"dist/",
						"coverage/",
						"%.lock",
					},
					dynamic_preview_title = true,
					results_title = false,
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
							["<C-u>"] = false, -- Clear prompt
							["<C-d>"] = actions.delete_buffer,
						},
						n = {
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
							["dd"] = actions.delete_buffer,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!{.git,node_modules,dist,build,target}/*",
					},
				},
				pickers = {
					find_files = {
						find_command = { "rg", "--files", "--hidden", "--glob", "!{.git,node_modules,dist,build,target}/*" },
						prompt_title = "Find Files",
					},
					live_grep = {
						prompt_title = "Live Grep",
						additional_args = function()
							return { "--hidden", "--glob=!{.git,node_modules,dist,build,target}/*" }
						end,
					},
					buffers = {
						prompt_title = "Open Buffers",
						sort_lastused = true,
						sort_mru = true,
					},
					oldfiles = {
						prompt_title = "Recent Files",
					},
					git_files = {
						prompt_title = "Git Files",
						show_untracked = true,
					},
				},
			})

			-- Load extensions
			telescope.load_extension("fzf")
			telescope.load_extension("live_grep_args")
		end,
	},

	-- ========================================================================
	-- CODE FORMATTING & LINTING
	-- ========================================================================

	-- Modern formatting plugin
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					-- DevOps formats
					lua = { "stylua" },
					python = { "isort", "black" },
					go = { "goimports", "gofumpt" },
					terraform = { "terraform_fmt" },
					yaml = { "prettier" },
					json = { "prettier" },
					markdown = { "prettier" },
					bash = { "shfmt" },
					sh = { "shfmt" },
					dockerfile = { "hadolint" },
					toml = { "taplo" },
					-- Web formats
					javascript = { "prettier" },
					typescript = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
				},
				default_format_opts = {
					lsp_fallback = true,
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
				formatters = {
					shfmt = {
						prepend_args = { "-i", "2", "-ci" }, -- 2 space indent, indent case statements
					},
				},
			})
		end,
	},

	-- Linting support
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				-- DevOps linting
				python = { "flake8" },
				bash = { "shellcheck" },
				sh = { "shellcheck" },
				dockerfile = { "hadolint" },
				yaml = { "yamllint" },
				terraform = { "tflint" },
				json = { "jsonlint" },
				markdown = { "markdownlint" },
			}

			-- Auto-lint on save and text changes
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- ========================================================================
	-- DEVOPS SPECIFIC PLUGINS
	-- ========================================================================

	-- Kubernetes YAML support
	{
		"someone-stole-my-name/yaml-companion.nvim",
		ft = { "yaml" },
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").load_extension("yaml_schema")
		end,
	},

	-- Docker integration
	{
		"kkvh/vim-docker-tools",
		ft = { "dockerfile" },
		config = function()
			-- Docker tools configuration
			vim.g.dockertools_default_all = 0
		end,
	},

	-- Terraform integration
	{
		"hashivim/vim-terraform",
		ft = { "terraform", "hcl" },
		config = function()
			vim.g.terraform_fmt_on_save = 1
			vim.g.terraform_align = 1
		end,
	},

	-- Log file syntax highlighting and navigation
	{
		"MTDL9/vim-log-highlighting",
		ft = { "log" },
	},

	-- Better JSON experience with path display
	{
		"gennaro-tedesco/nvim-jqx",
		ft = { "json" },
		config = function()
			-- JSON query and formatting shortcuts
			vim.keymap.set("n", "<leader>jq", ":JqxQuery<CR>", { desc = "JSON Query" })
			vim.keymap.set("n", "<leader>jf", ":JqxFormat<CR>", { desc = "JSON Format" })
		end,
	},

	-- Enhanced CSV handling for DevOps data
	{
		"chrisbra/csv.vim",
		ft = { "csv" },
		config = function()
			-- CSV column highlighting and navigation
			vim.g.csv_highlight_column = "y"
			vim.g.csv_strict_columns = 1
		end,
	},

	-- REST client for API testing (DevOps essential)
	{
		"rest-nvim/rest.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "http" },
		config = function()
			require("rest-nvim").setup({
				result_split_in_place = false,
				result_split_horizontal = false,
				skip_ssl_verification = false,
				encode_url = true,
				highlight = {
					enabled = true,
					timeout = 150,
				},
				result = {
					show_url = true,
					show_curl_command = false,
					show_http_info = true,
					show_headers = true,
					formatters = {
						json = "jq",
						html = function(body)
							return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
						end,
					},
				},
			})

			-- REST shortcuts
			vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim", { desc = "Run Request" })
			vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview", { desc = "Preview Request" })
			vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast", { desc = "Repeat Last Request" })
		end,
	},

	-- ========================================================================
	-- UTILITY PLUGINS
	-- ========================================================================

	-- Better notifications
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")

			notify.setup({
				background_colour = "#000000",
				fps = 30,
				icons = {
					DEBUG = "",
					ERROR = "",
					INFO = "",
					TRACE = "✎",
					WARN = "",
				},
				level = 2,
				minimum_width = 50,
				render = "default",
				stages = "fade_in_slide_out",
				timeout = 3000,
				top_down = true,
				max_width = function()
					return math.floor(vim.o.columns * 0.75)
				end,
				max_height = function()
					return math.floor(vim.o.lines * 0.75)
				end,
			})

			-- Only set vim.notify if it hasn't been set already
			if vim.notify == vim.notify_once then
				vim.notify = notify
			end
		end,
	},

	-- Indentation guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = {
					enabled = true,
					show_start = true,
					show_end = false,
					injected_languages = false,
					highlight = { "Function", "Label" },
					priority = 500,
				},
				exclude = {
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"neo-tree",
						"Trouble",
						"trouble",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
						"lazyterm",
						"NvimTree",
					},
				},
			})
		end,
	},

	-- Enhanced commenting
	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gcc", mode = "n", desc = "Comment toggle current line" },
			{ "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
			{ "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
			{ "gbc", mode = "n", desc = "Comment toggle current block" },
			{ "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
			{ "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
		},
		config = function()
			require("Comment").setup()
		end,
	},

	-- Auto pairs for brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
			})

			-- Integration with cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Key mapping helper
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({
				preset = "modern",
				win = {
					border = "rounded",
					position = "bottom",
					margin = { 1, 0, 1, 0 },
					padding = { 2, 2, 2, 2 },
					winblend = 0,
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
					spacing = 3,
					align = "left",
				},
			})
			
			-- Register all group mappings upfront
			wk.add({
				{ "<leader>f", group = "Find/File" },
				{ "<leader>g", group = "Git" },
				{ "<leader>h", group = "Git Hunks" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>w", group = "Workspace" },
				{ "<leader>c", group = "Code" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>q", group = "Session" },
				{ "<leader>s", group = "Split" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>x", group = "Trouble/Diagnostics" },
			})
		end,
	},

	-- Diagnostics panel
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				position = "bottom",
				height = 10,
				width = 50,
				icons = true,
				mode = "workspace_diagnostics",
				fold_open = "",
				fold_closed = "",
				group = true,
				padding = true,
				action_keys = {
					close = "q",
					cancel = "<esc>",
					refresh = "r",
					jump = { "<cr>", "<tab>" },
					open_split = { "<c-x>" },
					open_vsplit = { "<c-v>" },
					open_tab = { "<c-t>" },
					jump_close = { "o" },
					toggle_mode = "m",
					toggle_preview = "P",
					hover = "K",
					preview = "p",
					close_folds = { "zM", "zm" },
					open_folds = { "zR", "zr" },
					toggle_fold = { "zA", "za" },
					previous = "k",
					next = "j",
				},
			})
		end,
	},

	-- TODO comments highlighting
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				signs = true,
				sign_priority = 8,
				keywords = {
					FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
					TODO = { icon = " ", color = "info" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
					TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				},
				gui_style = {
					fg = "NONE",
					bg = "BOLD",
				},
				merge_keywords = true,
				highlight = {
					multiline = true,
					multiline_pattern = "^.",
					multiline_context = 15,
					before = "",
					keyword = "wide",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\s*:]],
					comments_only = true,
					max_line_len = 400,
					exclude = {},
				},
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					default = { "Identifier", "#7C3AED" },
					test = { "Identifier", "#FF006E" },
				},
				search = {
					command = "rg",
					args = {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
					pattern = [[\b(KEYWORDS):]],
				},
			})
		end,
	},

	-- Surround text objects
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Session management
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		config = function()
			require("persistence").setup({
				dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
				options = { "buffers", "curdir", "tabpages", "winsize" },
				pre_save = nil,
			})
		end,
	},

	-- Modern terminal integration
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<C-\>]],
				hide_numbers = true,
				shade_filetypes = {},
				autochdir = false,
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				persist_size = true,
				persist_mode = true,
				direction = "float",
				close_on_exit = true,
				shell = vim.o.shell,
				auto_scroll = true,
				float_opts = {
					border = "curved",
					winblend = 0,
					highlights = {
						border = "Normal",
						background = "Normal",
					},
				},
			})

			-- Terminal key mappings inside terminal mode
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
				vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
			end

			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
		end,
	},

	-- Debug Adapter Protocol
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup({
				icons = { expanded = "", collapsed = "", current_frame = "" },
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 },
							"breakpoints",
							"stacks",
							"watches",
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							"repl",
							"console",
						},
						size = 0.25,
						position = "bottom",
					},
				},
			})

			require("nvim-dap-virtual-text").setup({})

			-- Auto-open/close DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
}, {
	-- Lazy.nvim options for better performance and error handling
	defaults = {
		lazy = false, -- should plugins be lazy-loaded?
		version = nil, -- always use the latest git commit
	},
	install = {
		missing = true, -- install missing plugins on startup
		colorscheme = { "catppuccin" }, -- try to load one of these colorschemes when starting an installation during startup
	},
	checker = {
		enabled = false, -- don't automatically check for plugin updates
		notify = false, -- don't notify about plugin updates
	},
	change_detection = {
		enabled = false, -- don't automatically check for config file changes
		notify = false, -- don't notify about config changes
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- ============================================================================
-- KEY MAPPINGS
-- ============================================================================

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Essential mappings
local keymap = vim.keymap.set
local opts = { silent = true }

-- ========================================================================
-- FILE NAVIGATION
-- ========================================================================

-- File tree
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", opts)
keymap("n", "<leader>e", ":NvimTreeFindFile<CR>", opts)

-- Telescope (fuzzy finder)
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>fr", ":Telescope oldfiles<CR>", opts)
keymap("n", "<leader>fc", ":Telescope commands<CR>", opts)
keymap("n", "<leader>fk", ":Telescope keymaps<CR>", opts)
keymap("n", "<leader>fs", ":Telescope grep_string<CR>", opts)

-- Recent files
keymap("n", "<leader><leader>", ":Telescope oldfiles<CR>", opts)

-- ========================================================================
-- WINDOW & BUFFER MANAGEMENT
-- ========================================================================

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)

-- Split windows
keymap("n", "<leader>sv", "<C-w>v", opts) -- split vertically
keymap("n", "<leader>sh", "<C-w>s", opts) -- split horizontally
keymap("n", "<leader>se", "<C-w>=", opts) -- make split windows equal width
keymap("n", "<leader>sx", ":close<CR>", opts) -- close current split window

-- ========================================================================
-- EDITING
-- ========================================================================

-- Clear search highlights
keymap("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Better paste (don't overwrite clipboard)
keymap("v", "p", '"_dP', opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "J", ":move '>+1<CR>gv-gv", opts)
keymap("v", "K", ":move '<-2<CR>gv-gv", opts)

-- Better line joining
keymap("n", "J", "mzJ`z", opts)

-- Keep cursor centered when scrolling
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Keep search terms in the center
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- ========================================================================
-- GIT
-- ========================================================================

-- Git status and operations
keymap("n", "<leader>gg", ":Neogit<CR>", opts)
keymap("n", "<leader>gs", ":Git<CR>", opts)
keymap("n", "<leader>gd", ":DiffviewOpen<CR>", opts)
keymap("n", "<leader>gc", ":DiffviewClose<CR>", opts)
keymap("n", "<leader>gh", ":DiffviewFileHistory<CR>", opts)

-- ========================================================================
-- UTILITY
-- ========================================================================

-- Trouble (diagnostics)
keymap("n", "<leader>xx", ":TroubleToggle<CR>", opts)
keymap("n", "<leader>xw", ":TroubleToggle workspace_diagnostics<CR>", opts)
keymap("n", "<leader>xd", ":TroubleToggle document_diagnostics<CR>", opts)
keymap("n", "<leader>xl", ":TroubleToggle loclist<CR>", opts)
keymap("n", "<leader>xq", ":TroubleToggle quickfix<CR>", opts)

-- Todo comments
keymap("n", "<leader>ft", ":TodoTelescope<CR>", opts)

-- Session management
keymap("n", "<leader>qs", function()
	require("persistence").load()
end, opts)
keymap("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, opts)
keymap("n", "<leader>qd", function()
	require("persistence").stop()
end, opts)

-- Terminal
keymap("n", "<leader>tf", ":ToggleTerm direction=float<CR>", opts)
keymap("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", opts)
keymap("n", "<leader>tv", ":ToggleTerm direction=vertical size=80<CR>", opts)

-- Debugging
keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", opts)
keymap("n", "<leader>dc", ":DapContinue<CR>", opts)
keymap("n", "<leader>di", ":DapStepInto<CR>", opts)
keymap("n", "<leader>do", ":DapStepOver<CR>", opts)
keymap("n", "<leader>dO", ":DapStepOut<CR>", opts)
keymap("n", "<leader>dr", ":DapToggleRepl<CR>", opts)
keymap("n", "<leader>dl", ":DapShowLog<CR>", opts)
keymap("n", "<leader>dt", ":DapTerminate<CR>", opts)
keymap("n", "<leader>du", ":lua require('dapui').toggle()<CR>", opts)

-- Format code using conform instead of LSP directly
keymap("n", "<leader>lf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, opts)

-- Add which-key mappings after lazy loads
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	callback = function(event)
		if event.data == "which-key.nvim" then
			local wk = require("which-key")
			wk.add({
				-- File mappings
				{ "<leader>f", group = "Find/File" },
				{ "<leader>ff", desc = "Find Files" },
				{ "<leader>fg", desc = "Live Grep" },
				{ "<leader>fb", desc = "Buffers" },
				{ "<leader>fh", desc = "Help Tags" },
				{ "<leader>fr", desc = "Recent Files" },
				{ "<leader>fc", desc = "Commands" },
				{ "<leader>fk", desc = "Keymaps" },
				{ "<leader>fs", desc = "Grep String" },
				{ "<leader>ft", desc = "Todo Comments" },

				-- Git mappings
				{ "<leader>g", group = "Git" },
				{ "<leader>gg", desc = "Neogit" },
				{ "<leader>gs", desc = "Git Status" },
				{ "<leader>gd", desc = "Diff View" },
				{ "<leader>gc", desc = "Close Diff" },
				{ "<leader>gh", desc = "File History" },

				-- LSP mappings
				{ "<leader>l", group = "LSP" },
				{ "<leader>ld", desc = "Diagnostics" },
				{ "<leader>lD", desc = "Float Diagnostics" },
				{ "<leader>li", desc = "LSP Info" },
				{ "<leader>lf", desc = "Format" },

				-- Trouble mappings
				{ "<leader>x", group = "Trouble/Diagnostics" },
				{ "<leader>xx", desc = "Toggle Trouble" },
				{ "<leader>xw", desc = "Workspace Diagnostics" },
				{ "<leader>xd", desc = "Document Diagnostics" },
				{ "<leader>xl", desc = "Location List" },
				{ "<leader>xq", desc = "Quickfix List" },

				-- Debug mappings
				{ "<leader>d", group = "Debug" },
				{ "<leader>db", desc = "Toggle Breakpoint" },
				{ "<leader>dc", desc = "Continue" },
				{ "<leader>di", desc = "Step Into" },
				{ "<leader>do", desc = "Step Over" },
				{ "<leader>dO", desc = "Step Out" },
				{ "<leader>dr", desc = "Toggle REPL" },
				{ "<leader>dl", desc = "Show Log" },
				{ "<leader>dt", desc = "Terminate" },
				{ "<leader>du", desc = "Toggle UI" },

				-- Session mappings
				{ "<leader>q", group = "Session" },
				{ "<leader>qs", desc = "Load Session" },
				{ "<leader>ql", desc = "Load Last Session" },
				{ "<leader>qd", desc = "Stop Session" },

				-- Terminal mappings
				{ "<leader>t", group = "Terminal/Toggle" },
				{ "<leader>tf", desc = "Float Terminal" },
				{ "<leader>th", desc = "Horizontal Terminal" },
				{ "<leader>tv", desc = "Vertical Terminal" },

				-- Buffer mappings
				{ "<leader>b", group = "Buffer" },
				{ "<leader>bd", desc = "Delete Buffer" },

				-- Split mappings
				{ "<leader>s", group = "Split" },
				{ "<leader>sv", desc = "Split Vertical" },
				{ "<leader>sh", desc = "Split Horizontal" },
				{ "<leader>se", desc = "Equal Splits" },
				{ "<leader>sx", desc = "Close Split" },

				-- DevOps specific mappings
				{ "<leader>j", group = "JSON/Data" },
				{ "<leader>jq", desc = "JSON Query" },
				{ "<leader>jf", desc = "JSON Format" },

				-- REST client mappings
				{ "<leader>r", group = "REST/Request" },
				{ "<leader>rr", desc = "Run Request" },
				{ "<leader>rp", desc = "Preview Request" },
				{ "<leader>rl", desc = "Repeat Last Request" },

				-- Other mappings
				{ "<leader>e", desc = "Find File in Tree" },
				{ "<leader><leader>", desc = "Recent Files" },
			})
		end
	end,
})

-- DevOps-specific autocommands for better workflow
vim.api.nvim_create_augroup("devops-workflow", { clear = true })

-- Auto-format Kubernetes YAML files on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("k8s-yaml-format", { clear = true }),
	pattern = { "*.k8s.yml", "*.k8s.yaml", "**/k8s/**/*.yml", "**/k8s/**/*.yaml", "**/kubernetes/**/*.yml", "**/kubernetes/**/*.yaml" },
	callback = function()
		local conform_ok, conform = pcall(require, "conform")
		if conform_ok then
			conform.format({ async = false, lsp_fallback = true })
		end
	end,
})

-- Enhanced file detection for DevOps files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("devops-filetypes", { clear = true }),
	callback = function()
		local filename = vim.fn.expand("%:t")
		local filepath = vim.fn.expand("%:p")
		
		-- Dockerfile variants
		if filename:match("^Dockerfile") or filename:match("%.dockerfile$") then
			vim.bo.filetype = "dockerfile"
		-- Docker Compose variants
		elseif filename:match("docker%-compose") or filename:match("compose%.ya?ml") then
			vim.bo.filetype = "yaml.docker-compose"
		-- Kubernetes YAML files
		elseif filename:match("%.k8s%.ya?ml$") or filepath:match("/k8s/") or filepath:match("/kubernetes/") then
			vim.bo.filetype = "yaml.kubernetes"
		-- Helm templates
		elseif filepath:match("/templates/") and filename:match("%.ya?ml$") then
			vim.bo.filetype = "yaml.helm"
		-- Terraform files
		elseif filename:match("%.tf$") or filename:match("%.tfvars$") then
			vim.bo.filetype = "terraform"
		-- Ansible playbooks
		elseif filename:match("playbook") or filename:match("%.ya?ml$") and filepath:match("/ansible/") then
			vim.bo.filetype = "yaml.ansible"
		-- Log files
		elseif filename:match("%.log$") then
			vim.bo.filetype = "log"
		-- HTTP request files
		elseif filename:match("%.http$") or filename:match("%.rest$") then
			vim.bo.filetype = "http"
		end
	end,
})

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "Remove trailing whitespace",
	group = vim.api.nvim_create_augroup("remove-trailing-whitespace", { clear = true }),
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		pcall(function()
			vim.cmd([[%s/\s\+$//e]])
		end)
		vim.fn.setpos(".", save_cursor)
	end,
})

-- File type specific settings
local filetype_settings = vim.api.nvim_create_augroup("filetype-settings", { clear = true })

-- YAML files (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
	group = filetype_settings,
	pattern = { "yaml", "yml" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.softtabstop = 2
	end,
})

-- JSON files (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
	group = filetype_settings,
	pattern = { "json", "jsonc" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.softtabstop = 2
	end,
})

-- Docker files (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
	group = filetype_settings,
	pattern = { "dockerfile", "docker-compose" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.softtabstop = 2
	end,
})

-- Terraform files (2 spaces)
vim.api.nvim_create_autocmd("FileType", {
	group = filetype_settings,
	pattern = { "terraform", "hcl" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.softtabstop = 2
	end,
})

-- Markdown files (2 spaces, enable wrapping)
vim.api.nvim_create_autocmd("FileType", {
	group = filetype_settings,
	pattern = { "markdown", "md" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.softtabstop = 2
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

-- Close certain windows with 'q'
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close-with-q", { clear = true }),
	pattern = {
		"help",
		"startuptime",
		"qf",
		"lspinfo",
		"man",
		"checkhealth",
		"tsplayground",
		"notify",
		"trouble",
		"telescope",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Auto-create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("auto-create-dir", { clear = true }),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local uv = vim.uv or vim.loop
		local file = uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- ============================================================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================================================

-- Disable some built-in plugins for better performance
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getScript = 1
vim.g.loaded_getScriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1

-- Faster startup
vim.loader.enable()
