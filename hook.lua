local actor = game:GetService("Players").LocalPlayer.PlayerScripts.Actor

run_on_actor(actor, [[
	local mt = getrawmetatable(game)
	local oldnamecall = mt.__namecall

	setreadonly(mt, false)

	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = { ... }

		if (method == "FireServer" or method == "InvokeServer")
			and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then

			local remotename = "unknown"

			pcall(function()
				local rh = require(game.Players.LocalPlayer.PlayerScripts.Actor.CoreClient.RemoteHandler)

				for i = 1, 80 do
					local success, upvalue = pcall(debug.getupvalue, rh.Event.new, i)

					if success and type(upvalue) == "table" then
						for k, v in pairs(upvalue) do
							if v == self then
								remotename = k
								break
							end
						end
					end
				end
			end)

			print("")
			print("[remote]", remotename)
			print("method:", method)

			for i, arg in ipairs(args) do
				print("arg", i, typeof(arg), tostring(arg))
			end

			print("---")
		end

		return oldnamecall(self, ...)
	end)

	setreadonly(mt, true)

	print("loaded remote spy")
]])
