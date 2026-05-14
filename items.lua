local inventory = game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Inventory
local items = require(game:GetService("ReplicatedStorage").Databases.Items)

getgenv().inventorystuff = {}

for _, v in ipairs(inventory:GetDescendants()) do
	if v:IsA("ImageButton") then
		local icon = v:FindFirstChild("IconLabel")

		if icon and icon:IsA("ImageLabel") then
			local id = icon.Image

			for _, data in pairs(items) do
				if typeof(data) == "table" and data.HotbarThumb == id then
					getgenv().inventorystuff[data.Name] = v.Name
				end
			end
		end
	end
end
