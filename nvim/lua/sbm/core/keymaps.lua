vim.g.mapleader = " "

local keymap = vim.keymap

-- Bind ESC to jk in Insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert model with jk" })

-- Move lines/blocks up and down
keymap.set("n", "<C-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap.set("n", "<C-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move block down" })
keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move block up" })

-- Clear search results
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal in size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current plit" })

-- Tabs management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Move to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Mover to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
