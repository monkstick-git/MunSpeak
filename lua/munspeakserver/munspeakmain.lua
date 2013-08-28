function MunSpeak.CreateChannel(ply,msg) 
	local Message = string.Explode(" ",msg)

	if(Message[1]=="/channel") then
		ply:SetNWString("Channel",Message[2])
		return ""
	end
	
	if(Message[1]=="/leave") then
		ply:SetNWString("Channel","Default")
		return ""
	end
end

hook.Add("PlayerSay", "munspeakcreate", MunSpeak.CreateChannel)

function MunSpeak.PlayerHasConnected(ply)
	if(!ply.MunTalkSpawned) then
		ply:SetNWString("Channel","Default")
		ply.MunTalkSpawned = true
	end
end

hook.Add("PlayerSpawn","MunTalkPlayerHasConnected",MunSpeak.PlayerHasConnected)
