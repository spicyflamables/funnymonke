loadstring(game:HttpGet("https://raw.githubusercontent.com/spicyflamables/funnymonke/refs/heads/main/item.lua"))()

local rod = getgenv().inventorystuff["Fishing Pole"]

if typeof(rod) == "table" then
	local slot = tonumber(rod.slot)

	if slot then
		print("Fishing Pole | " .. slot)

		if not rod.equipped then
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

				print("equipped fishing pole") -- fish tekanologia
			end
		else
			print("already equipped")
		end
	end
else
	warn("fishing pole not found")
end
