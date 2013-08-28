MunSpeakChannels = {}
MunSpeakChannels["Default"] = {Owner = "Server",Members = {},Password = ""}
util.AddNetworkString("MunSpeakChannels")
util.AddNetworkString("MunSpeakShowUi")

function MunSpeak.CreateChannel(ply,msg) 
	local Message = string.Explode(" ",msg)

	if(Message[1]=="/channel") then
		if(not Message[3]) then ChannelPass = "" else ChannelPass = Message[3] end
		
		if(not MunSpeakChannels[Message[2]]) then
			MunSpeakChannels[Message[2]] = {Owner = ply:SteamID(),Members = {},Password = ChannelPass} PrintMessage(HUD_PRINTTALK,ply:Nick().." Created channel "..Message[2])
		else 
			if(ChannelPass != MunSpeakChannels[Message[2]].Password) then ply:PrintMessage(HUD_PRINTTALK,"Password is incorrect!") return false else PrintMessage(HUD_PRINTTALK,ply:Nick().." Joined channel "..Message[2]) end
			
		end
		
		
		CheckChannels(ply)
		table.insert(MunSpeakChannels[Message[2]].Members,ply)
		ply:SetNWString("Channel",Message[2])
		
		MunTalkSendChannels()
		
		return ""
	end
	
	if(Message[1]=="/leave") then
		if(table.HasValue(MunSpeakChannels["Default"],ply)) then PrintMessage(HUD_PRINTTALK,"PLAYER IS ALREADY IN THAT TABLE") return end
		CheckChannels(ply)
		table.insert(MunSpeakChannels["Default"].Members,ply)
		ply:SetNWString("Channel","Default")
		MunTalkSendChannels()
		return ""
	end
	
	if(Message[1]=="/listchannels") then
		for k,v in pairs(MunSpeakChannels) do
		local TrueFalse = ""
		if string.len(MunSpeakChannels[k].Password)>0 then TrueFalse = ": *Passworded*" else TrueFalse = "" end
		local TempString = k.." "..TrueFalse
			MsgN(TempString)
			for key,value in pairs(MunSpeakChannels[k].Members) do
			MsgN(string.rep(" ",10)..value:Nick())
			end
		end
	end

	if(Message[1]=="/munspeak") then
		MunTalkShowUi(ply)
	end
end

hook.Add("PlayerSay", "munspeakcreate", MunSpeak.CreateChannel)

function MunSpeak.PlayerHasConnected(ply)
	if(!ply.MunTalkSpawned) then
	timer.Simple(1,function()
		if(table.HasValue(MunSpeakChannels["Default"].Members,ply)) then PrintMessage(HUD_PRINTTALK,"PLAYER IS ALREADY IN THAT TABLE") return end
		table.insert(MunSpeakChannels["Default"].Members,ply)
		ply:SetNWString("Channel","Default")
		MunTalkSendChannels()
		ply.MunTalkSpawned = true
	end)

	end
end

hook.Add("PlayerSpawn","MunTalkPlayerHasConnected",MunSpeak.PlayerHasConnected)
 
function CheckChannels(ply)
		for k,v in pairs(MunSpeakChannels) do
			for k2,v2 in pairs(v) do
				if(table.HasValue(MunSpeakChannels[k].Members,ply)) then 
					
					--table.remove(MunSpeakChannels[k].Members,k2)
					table.RemoveByValue(MunSpeakChannels[k].Members,ply) 
				end
			end
		end
end 

function MunTalkSendChannels()
		net.Start("MunSpeakChannels")
		net.WriteTable(MunSpeakChannels)
		net.Broadcast()
end


function MunTalkShowUi(ply)
		net.Start("MunSpeakShowUi")
		net.Send(ply)
end