return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#14101c',
				base01 = '#14101c',
				base02 = '#99909c',
				base03 = '#99909c',
				base04 = '#f8ecfc',
				base05 = '#fdf8ff',
				base06 = '#fdf8ff',
				base07 = '#fdf8ff',
				base08 = '#ff9fad',
				base09 = '#ff9fad',
				base0A = '#e9a8ff',
				base0B = '#a5ffbc',
				base0C = '#f3d1ff',
				base0D = '#e9a8ff',
				base0E = '#edb7ff',
				base0F = '#edb7ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#99909c',
				fg = '#fdf8ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#e9a8ff',
				fg = '#14101c',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#99909c' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#f3d1ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#edb7ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#e9a8ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#e9a8ff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#f3d1ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a5ffbc',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#f8ecfc' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#f8ecfc' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#99909c',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
