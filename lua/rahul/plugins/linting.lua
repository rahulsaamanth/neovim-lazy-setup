return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		
		-- Check if local eslint exists in project
		local function get_eslint_command()
			local local_eslint = vim.fn.findfile("node_modules/.bin/eslint", vim.fn.getcwd() .. ";")
			if local_eslint ~= "" then
				return local_eslint
			else
				-- Fallback to eslint_d
				return "eslint_d"
			end
		end
		
		-- Create a custom eslint linter that will use local eslint when available
		lint.linters.eslint_project = {
			cmd = get_eslint_command,
			args = {
				"--format", "json",
				"--stdin",
				"--stdin-filename", function() return vim.api.nvim_buf_get_name(0) end,
			},
			stdin = true,
			parse = require("lint.linters.eslint").parse,
			ignore_exitcode = true,
		}
		
		lint.linters_by_ft = {
			javascript = { "eslint_project" },
			typescript = { "eslint_project" },
			javascriptreact = { "eslint_project" },
			typescriptreact = { "eslint_project" },
			svelte = { "eslint_project" },
			python = { "pylint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
