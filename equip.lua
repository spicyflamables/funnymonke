loadstring(game:HttpGet("https://raw.githubusercontent.com/spicyflamables/funnymonke/refs/heads/main/item.lua"))()

local rod = getgenv().inventorystuff["Fishing Pole"]

if rod and not rod.equipped then
	local slot = tonumber(rod.slot)

	print("Fishing Rod | " .. slot) -- fish tekanologia

	local vim = game:GetService("VirtualInputManager")

	local keys = {
		[1] = "One",
		[2] = "Two",
		[3] = "Three",
		[4] = "Four",
		[5] = "Five",
		[6] = "Six",
		[7] = "Seven",
		[8] = "Eight",
		[9] = "Nine",
		[0] = "Zero"
	}

	local key = keys[slot]

	if key then
		vim:SendKeyEvent(true, key, false, game)
		task.wait(0.05)
		vim:SendKeyEvent(false, key, false, game)
	end
else
	print("already equipped or rod exploded")
end
