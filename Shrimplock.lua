-- <library>
local lib_ui = loadstring(dx9.Get("https://raw.githubusercontent.com/soupg/DXLibUI/main/main.lua"))()
local lib_esp = loadstring(dx9.Get("https://pastebin.com/raw/Pwn8GxMB"))()

local config = _G.config
	or {
		esp = true,
		disable_if_none = true,
		offset = 3,

		backpack = true,

		blacklist = { -- This will exclude any item from the "Held ESP" or "Backpack viewer"
			equipped_item = {}, -- Example: { "Fists", "M4A1" }
			backpack_item = {},
		},

		colors = {
			equipped_item = { 255, 0, 0 },
			backpack_item = { 0, 255, 255 },
		},
	}

local interface = lib_ui:CreateWindow({
	Title = "Shrimplock Hub",
	Size = { 500, 500 },
	Resizable = false,

	ToggleKey = "[F2]",

	FooterToggle = false,
	FooterRGB = false,
	FontColor = { 255, 255, 255 },
	MainColor = { 32, 26, 68 },
	BackgroundColor = { 26, 21, 55 },
	AccentColor = { 81, 37, 112 },
	OutlineColor = { 54, 47, 90 },
})

-- <tabs>
local tabs = {
	settings = interface:AddTab("Settings"),
	players = interface:AddTab("Players"),
}

-- <groupboxes>
local groupboxes = {
	settings = tabs.settings:AddMiddleGroupbox("< Settings >"),
	player_list = tabs.players:AddLeftGroupbox("Player List"),
	inventory_list = tabs.players:AddRightGroupbox("Inventory"),
}

-- >>settings tab
-- >settings
local settings = {
	groupboxes.settings:AddTitle("ESP"),
	esp = groupboxes.settings
		:AddToggle({
			Default = config.esp,
			Text = "Enabled",
		})
		:OnChanged(function(value)
			lib_ui:Notify(
				value and "[settings-esp] Enabled Held Item ESP" or "[settings-esp] Disabled Held Item ESP",
				1
			)
		end),
	esp_onh = groupboxes.settings
		:AddToggle({
			Default = config.esp,
			Text = "Disable on nothing held",
		})
		:OnChanged(function(value)
			lib_ui:Notify(value and "[settings-esp] Enabled ONH" or "[settings-esp] Disabled ONH", 1)
		end),

	esp_offset = groupboxes.settings:AddSlider({
		Default = config.offset,
		Text = "Offset (Y)",
		Min = 1,
		Max = 100,
		Rounding = 0,
	}).Value,

	esp_color = groupboxes.settings:AddColorPicker({
		Default = config.colors.equipped_item,
		Text = "Color",
	}).Value,

	groupboxes.settings:AddTitle("Backpack"),
	backpack = groupboxes.settings
		:AddToggle({
			Default = config.backpack,
			Text = "Enabled Checker",
		})
		:OnChanged(function(value)
			lib_ui:Notify(
				value and "[settings-backpack] Enabled Backpack Checker"
					or "[settings-backpack] Disabled Backpack Checker",
				1
			)
		end),

	backpack_color = groupboxes.settings:AddColorPicker({
		Default = config.colors.backpack_item,
		Text = "Color ",
	}).Value,
}

-- >>players tab
-- >players
local players = {
	player_list = groupboxes.player_list
		:AddDropdown({
			Text = "Players",
			Default = 1,
			Values = { "None" },
		})
		:OnChanged(function(value)
			lib_ui:Notify("[players] Checking inventory: " .. value, 1)
		end),
}

-- >constants
local datamodel = dx9.GetDatamodel()
local workspace = dx9.FindFirstChild(datamodel, "Workspace")
local local_player = dx9.get_localplayer()
local services = {
	players = dx9.FindFirstChild(datamodel, "Players"),
}

-- >variables
local listed_inventory = "None"
local inventories = {}
local player_list = {
	[1] = "None",
}

-- >functions
local function find(table, value)
	if not table or not value then
		return nil
	end

	for k, v in pairs(table) do
		if v == value then
			return k
		end
	end

	return nil
end

-- >>core
for _, player in pairs(dx9.get_players()) do
	local player_instance = dx9.FindFirstChild(services.players, player)

	if player_instance == 0 then
		return
	end

	if settings.esp.Value then
		if player ~= local_player.Info.Name then
			local character = dx9.GetCharacter(player_instance)
			local held_item = "None"

			if character ~= 0 and character ~= nil then
				local root = dx9.FindFirstChild(character, "HumanoidRootPart")

				if root ~= 0 or root ~= nil then
					local position = dx9.GetPosition(root)
					if position ~= nil then
						local tool = dx9.FindFirstChildOfClass(character, "Tool")
						local can_draw = true

						if tool ~= 0 then
							held_item = dx9.GetName(tool)

							if #config.blacklist.equipped_item ~= 0 then
								if find(config.blacklist.equipped_item, held_item) then
									can_draw = false
								end
							end
						else
							if settings.esp_onh.Value then
								can_draw = false
							end
						end

						if can_draw then
							local world_to_screen = dx9.WorldToScreen({ position.x, position.y, position.z })

							dx9.DrawString({
								world_to_screen.x - (dx9.CalcTextWidth(held_item) / 2),
								world_to_screen.y + settings.esp_offset,
							}, settings.esp_color, held_item)
						end
					end
				end
			end
		end
	end

	if settings.backpack.Value then
		local backpack = dx9.FindFirstChild(player_instance, "Backpack")
		local inventory = {}

		if backpack ~= 0 then
			for _, object in pairs(dx9.GetChildren(backpack)) do
				if dx9.GetType(object) == "Tool" then
					if #config.blacklist.backpack_item ~= 0 then
						if not find(config.blacklist.backpack_item, dx9.GetName(object)) then
							table.insert(inventory, dx9.GetName(object))
						end
					else
						table.insert(inventory, dx9.GetName(object))
					end
				end
			end
		end

		if players.player_list.Value == player then
			listed_inventory = table.concat(inventory, "\n")
		end

		table.insert(player_list, player)
	else
		players.player_list:SetValue("None")
	end
end

players.player_list:SetValues(player_list)
groupboxes.inventory_list:AddLabel(listed_inventory, settings.backpack_color)