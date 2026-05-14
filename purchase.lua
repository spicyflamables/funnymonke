local actor = game:GetService("Players").LocalPlayer.PlayerScripts.Actor

run_on_actor(actor, [[
	local rh = require(game.Players.LocalPlayer.PlayerScripts.Actor.CoreClient.RemoteHandler)

	local storeid = 
	local storename = ""
	local itemname = ""

	local success, err = pcall(function()
		rh.Event.new("ItemPurchase"):Fire(storeid, storename, itemname)
	end)

	if success then
		print("bought", itemname)
	else
		warn(err)
	end
]])
