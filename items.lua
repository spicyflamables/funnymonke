local inventory = game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Inventory
local items = require(game:GetService("ReplicatedStorage").Databases.Items)

getgenv().inventorystuff = {}

local color = Color3.fromRGB(55, 103, 159)

for _, v in ipairs(inventory:GetDescendants()) do
	if v:IsA("ImageButton") then
		local icon = v:FindFirstChild("IconLabel")
		local slot = v:FindFirstChild("SlotLabel")

		if icon and icon:IsA("ImageLabel") then
			local id = icon.Image
			local slottext = slot and slot:IsA("TextLabel") and slot.Text or "what"

			for _, data in pairs(items) do
				if typeof(data) == "table" and data.HotbarThumb == id then
					getgenv().inventorystuff[data.Name] = {
						slot = slottext,
						equipped = v.BackgroundColor3 == color
					}
				end
			end
		end
	end
end
