return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- Navigation
			map("n", "]h", gs.next_hunk, "Git Next Hunk")
			map("n", "[h", gs.prev_hunk, "Git Prev Hunk")

			-- Actions
			map("n", "<leader>hs", gs.stage_hunk, "Git Stage hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Git Reset hunk")
			map("v", "<leader>hs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Git Stage hunk")
			map("v", "<leader>hr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Git Reset hunk")

			map("n", "<leader>hS", gs.stage_buffer, "Git Stage buffer")
			map("n", "<leader>hR", gs.reset_buffer, "Git Reset buffer")

			map("n", "<leader>hu", gs.undo_stage_hunk, "Git Undo stage hunk")

			map("n", "<leader>hp", gs.preview_hunk, "Git Preview hunk")

			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Git Blame line")
			map("n", "<leader>hB", gs.toggle_current_line_blame, "Git Toggle line blame")

			map("n", "<leader>hd", gs.diffthis, "Git Diff this")
			map("n", "<leader>hD", function()
				gs.diffthis("~")
			end, "Git Diff this ~")

			-- Text object
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Git Select hunk")
		end,
	},
}
