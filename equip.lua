loadstring(game:HttpGet("https://raw.githubusercontent.com/spicyflamables/funnymonke/refs/heads/main/items.lua"))()

local rod = getgenv().inventorystuff["Fishing Pole"]

local actor = game:GetService("Players").LocalPlayer.PlayerScripts.Actor

run_on_actor(actor, [[
	local players = game:GetService("Players")
	local player = players.LocalPlayer

	local id = ""

	local item = player.Backpack:FindFirstChild(id)

	if not item and player.Character then
		item = player.Character:FindFirstChild(id)
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
]])
