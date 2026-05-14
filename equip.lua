loadstring(game:HttpGet("https://raw.githubusercontent.com/spicyflamables/funnymonke/refs/heads/main/items.lua"))()

if not getgenv().inventorystuff["Wallet"] then
	warn("wallet not found in inventory")
	return
end

local actor = game:GetService("Players").LocalPlayer.PlayerScripts.Actor

run_on_actor(actor, [[
	local players = game:GetService("Players")
	local player = players.LocalPlayer

	local item

	for _, v in ipairs(player.Backpack:GetChildren()) do
		if v.Name:lower():find("wallet") then
			item = v
			break
		end
	end

	if not item and player.Character then
		for _, v in ipairs(player.Character:GetChildren()) do
			if v.Name:lower():find("wallet") then
				item = v
				break
			end
		end
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
