return {
	"nvim-mini/mini.starter",
	opts = function()
		local starter = require("mini.starter")
		local pad = string.rep(" ", 20)
		local new_section = function(name, action, section)
			return { name = name, action = action, section = pad .. section }
		end
		return {
			items = {
				new_section("Find file", "Telescope find_files", "Telescope"),
				new_section("New file", "ene | startinsert", "Built-in"),
				new_section("Recent files", "Telescope oldfiles", "Telescope"),
				new_section("Find text", "Telescope live_grep", "Telescope"),
				new_section("Config", "Telescope config_files", "Config"),
				new_section("Restore session", "lua require('persistence').load()", "Session"),
				new_section("Lazy Extras", "LazyExtras", "Config"),
				new_section("Lazy", "Lazy", "Config"),
				new_section("Quit", "qa", "Built-in"),
			},
			content_hooks = {
				starter.gen_hook.adding_bullet(pad .. "░ ", false),
				starter.gen_hook.aligning("center", "center"),
			},
		}
	end,
}
