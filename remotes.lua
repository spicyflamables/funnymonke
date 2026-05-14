local actor = game:GetService("Players").LocalPlayer.PlayerScripts.Actor

run_on_actor(actor, [[
	local remotehandler = require(
		game:GetService("Players")
		.LocalPlayer.PlayerScripts.Actor.CoreClient.RemoteHandler
	)

	local keyboard = getrenv().print

	for i = 1, 50 do
		local ok, up = pcall(debug.getupvalue, remotehandler.Event.new, i)

		if not ok then
			break
		end

		if type(up) == "table" then
			for k,v in pairs(up) do
				if typeof(v) == "Instance" then
					keyboard(k)
				end
			end
		end
	end

	for i = 1, 50 do
		local ok, up = pcall(debug.getupvalue, remotehandler.Func.new, i)

		if not ok then
			break
		end

		if type(up) == "table" then
			for k,v in pairs(up) do
				if typeof(v) == "Instance" then
					keyboard(k)
				end
			end
		end
	end
]])
