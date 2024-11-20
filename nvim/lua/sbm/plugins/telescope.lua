return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

    # Fuzzy Search
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs comments" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })
		keymap.set("n", "<leader>fy", "<cmd>Telescope registers<cr>", { desc = "Find in registers/yank history" })
		keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
		keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help documentation" })
		keymap.set("n", "<leader>fm", "<cmd>Telescope commands<cr>", { desc = "Search available commands" })

    # Coding
    keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Go to definitions" })
    keymap.set("n", "<leader>gs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "List document symbols" })
    keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Go to implementation" })
    keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<cr>", { desc = "Find references" })
    keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Go to type definition" })
    keymap.set("n", "<leader>gI", "<cmd>Telescope lsp_incoming_calls<cr>", { desc = "Show incoming calls" })
    keymap.set("n", "<leader>gO", "<cmd>Telescope lsp_outgoing_calls<cr>", { desc = "Show outgoing calls" })

}
