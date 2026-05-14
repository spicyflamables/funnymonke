loadstring(game:HttpGet("https://raw.githubusercontent.com/spicyflamables/funnymonke/main/items.lua"))()

local itemname = getgenv().inventorystuff["Wallet"]

local player = game:GetService("Players").LocalPlayer
local actor = player.PlayerScripts.Actor

run_on_actor(actor, string.format([[
	local player = game:GetService("Players").LocalPlayer

	local item = player.Backpack:FindFirstChild("%s")

	if not item and player.Character then
		item = player.Character:FindFirstChild("%s")
	end

	if not item then
		warn("item not found")
		return
	end

	local tool = player.Character.ToolGrip.Tool

	if tool then
		print("found tool")
		tool:FireServer(item, true)
		print("fired remote")
	else
		warn("tool not found")
	end
]], itemname, itemname))
