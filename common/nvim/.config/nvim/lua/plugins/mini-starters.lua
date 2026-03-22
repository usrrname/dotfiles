return {
	"nvim-mini/mini.starter",
	opts = function()
		local starter = require("mini.starter")
		local logo = table.concat({
			"  _____                  __      ___           ",
			" / ____|                 \\ \\    / (_)          ",
			"| |     _ __ __ _ _____   \\ \\  / / _ _ __ ___  ",
			"| |    | '__/ _` |_  / | | \\ \\/ / | | '_ ` _ \\ ",
			"| |____| | | (_| |/ /| |_| |\\  /  | | | | | | |",
			" \\_____|_|  \\__,_/___|\\__, | \\/   |_|_| |_| |_| |",
			"                       __/ |                    ",
			"                      |___/                     ",
		}, "\n")

		local pad = string.rep(" ", 22)
		local function item(name, action, section)
			return { name = name, action = action, section = pad .. section }
		end

		return {
			header = logo,
			items = {
				item("Find file", function() require("telescope.builtin").find_files() end, "Telescope"),
				item("New file", "ene | startinsert", "Built-in"),
				item("Recent files", function() require("telescope.builtin").oldfiles() end, "Telescope"),
				item("Find text", function() require("telescope.builtin").live_grep() end, "Telescope"),
				item("Restore session", function() require("persistence").load() end, "Session"),
				item("Lazy", "Lazy", "Config"),
				item("Quit", "qa", "Built-in"),
			},
			content_hooks = {
				starter.gen_hook.adding_bullet(pad .. "░ ", false),
				starter.gen_hook.aligning("center", "center"),
			},
		}
	end,
}
