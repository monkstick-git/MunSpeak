MunSpeak = {}
MunSpeakChannels = {}
MunSpeakAdmins = {}
util.AddNetworkString("MunSpeakChannels")
util.AddNetworkString("MunSpeakShowUi")
util.AddNetworkString("MunSpeakClientJoin")
util.AddNetworkString("MunSpeakCreateChannel")

function MunSpeak.ChatMessages(ply,msg) -- Chat Messages
	local Message = string.Explode(" ",msg)
	local Target = 0
	
	if(Message[1]=="/createchannel") then
		MunSpeak.CreateChannel(ply,Message[2],Message[3])
		return ""
	end
	
	if(Message[1]=="/joinchannel") then
		MunSpeak.JoinChannel(ply,Message[2],Message[3])
		return ""
	end
	
	if(Message[1]=="/leave") then
		MunSpeak.Leave(ply)
		return ""
	end

	if(Message[1]=="/munspeak") then
		MunSpeak.ShowUI(ply)
	end
	
	if(Message[1]=="/del") then
	MunSpeak.Delete(ply,Message[2])
	end
	
	if(Message[1]=="/json") then
		MunSpeak.WriteTable()
	end
	
	if(Message[1]=="/read") then
		MunSpeak.ReadTable()
	end
	
	if(Message[1]=="/move") then
		local PlayerData = MunSpeak.FindPlayer(Message[2])
		MunSpeak.MovePlayer(ply,PlayerData,Message[3])
	end
	
	if(Message[1]=="/createadmin") then
		 MunSpeak.CreateAdmin(ply,MunSpeak.FindPlayer(Message[2]))
	end
	
	if(Message[1]=="/isadmin") then
		PrintMessage(HUD_PRINTTALK,tostring(MunSpeak.IsAdmin(MunSpeak.FindPlayer(Message[2]))))
	end
end

function MunSpeak.PlayerHasConnected(ply) -- When a player first joins
	if(!ply.MunTalkSpawned) then
	
	timer.Simple(1,function()
		if(table.HasValue(MunSpeakChannels["Default"].Members,ply)) then PrintMessage(HUD_PRINTTALK,"PLAYER IS ALREADY IN THAT TABLE") return end
		table.insert(MunSpeakChannels["Default"].Members,ply)
		ply:SetNWString("Channel","Default")
		MunSpeak.SendChannels()
		ply.MunTalkSpawned = true
	end)

	end
end
 
function MunSpeak.CheckChannels(ply) -- Check the channels to make sure you are only in one channel
		for k,v in pairs(MunSpeakChannels) do
			for k2,v2 in pairs(v) do
				if(table.HasValue(MunSpeakChannels[k].Members,ply)) then 
					
					--table.remove(MunSpeakChannels[k].Members,k2)
					table.RemoveByValue(MunSpeakChannels[k].Members,ply) 
				end
			end
		end
end 

function MunSpeak.SendChannels() -- Send the Channels to the client
		net.Start("MunSpeakChannels")
		net.WriteTable(MunSpeakChannels)
		net.Broadcast()
end

function MunSpeak.ShowUI(ply) -- Tell the Client to open its UI
		net.Start("MunSpeakShowUi")
		net.Send(ply)
end

function MunSpeak.CreateChannel(ply,name,pass) -- Create channel.  PlayerData and Name of channel are REQUIRED.  pass is optional.
		local ChannelPass = ""
		name = string.Trim(name)
		if(name == "") then return end
		if(not pass) then ChannelPass = "" else ChannelPass = pass end
		
		if(not MunSpeakChannels[name]) then
			MunSpeakChannels[name] = {Owner = ply:SteamID(),Members = {},Password = ChannelPass} PrintMessage(HUD_PRINTTALK,ply:Nick().." Created channel "..name)			
		end
		
		MunSpeak.SendChannels()
		MunSpeak.WriteTable()
		
		return ""
end

function MunSpeak.JoinChannel(ply,name,password,adminrequest) -- Joining a channel
	local ChannelPass = ""
	if(not password) then ChannelPass = "" else ChannelPass = password end
	
	if(ChannelPass != MunSpeakChannels[name].Password and not adminrequest) then
		ply:PrintMessage(HUD_PRINTTALK,"Password is incorrect!") return false
	else
		PrintMessage(HUD_PRINTTALK,ply:Nick().." Joined channel "..name)
	end

	MunSpeak.CheckChannels(ply)
	table.insert(MunSpeakChannels[name].Members,ply)
	ply:SetNWString("Channel",name)
			
	MunSpeak.SendChannels()

end

function MunSpeak.Leave(ply) -- Leave a channel and go back to the Default channel.
	if(table.HasValue(MunSpeakChannels["Default"],ply)) then 
		PrintMessage(HUD_PRINTTALK,"PLAYER IS ALREADY IN THAT TABLE") return 
	end
	
	MunSpeak.CheckChannels(ply)
	table.insert(MunSpeakChannels["Default"].Members,ply)
	ply:SetNWString("Channel","Default")
	MunSpeak.SendChannels()
end

function MunSpeak.Delete(ply,Channel) -- Delete channel. Player must either Own the channel, ply:IsAdmin() or MunSpeak.IsAdmin(ply)
	for k,v in pairs(MunSpeakChannels) do
		if tostring(k) == tostring(Channel) then
			if((MunSpeakChannels[Channel].Owner == ply:SteamID()) or ply:IsAdmin() or MunSpeak.IsAdmin(ply)) then
				PrintMessage(HUD_PRINTTALK,ply:Nick().." Has deleted Channel: "..Channel) 
				MunSpeakChannels[Channel]=nil
				MunSpeak.SendChannels()
			else
				ply:PrintMessage(HUD_PRINTTALK,ply:Nick().."You do not have permission to delete that channel")
			end
		end 
	end
end

function MunSpeak.SmallTable() -- Creates a smaller version of the ChannelTable.  returns it.
	local Ctable = MunSpeakChannels
	local TempTable = {}
		for k,v in pairs(Ctable) do
			if table.Count(Ctable[k].Members) > 0 then
				TempTable[k] = v
			end
		end
		
		for k,v in pairs(TempTable)do
			MsgAll(k)
		end
	return TempTable
end

function MunSpeak.WriteTable() -- Writes the current MunSpeak channel layouts and passwords to a json string, which is located in data/MunSpeakTable.txt
	local Bench1 = SysTime()
	MsgAll("[MunSpeak] - Writing table to JSON...")
	local Ctable = MunSpeakChannels
	for k,v in pairs(Ctable) do
		Ctable[k].Members[v] = nil
	end

	
	local MunSpeakTempString = util.TableToJSON(Ctable)
	file.Write("MunSpeakTable.txt",MunSpeakTempString)
	MsgAll("[MunSpeak] - Finished Writing JSON table.  Took: "..(SysTime() - Bench1))
end

function MunSpeak.ReadTable()	-- Reads the JSON table from data/MunSpeakTable.txt else creates the default channel and creates the json file.
	if(file.Exists("MunSpeakTable.txt", "DATA")) then
		MunSpeakChannels = util.JSONToTable(file.Read( "MunSpeakTable.txt", "DATA" ))
	else
		MunSpeakChannels["Default"] = {Owner = "Server",Members = {},Password = ""}
		MunSpeak.WriteTable()
	end
	
	return MunSpeakChannels
	
end

function MunSpeak.WriteAdmins() -- Writes all MunSpeak admins to a json text file.
	local Bench1 = SysTime()
	MsgAll("[MunSpeak] - Writing Admins to JSON...")
	local Ctable = MunSpeakAdmins
	
	local MunSpeakTempString = util.TableToJSON(Ctable)
	file.Write("MunSpeakAdmins.txt",MunSpeakTempString)
	MsgAll("[MunSpeak] - Finished Writing JSON table ADMINS.  Took: "..(SysTime() - Bench1))
end

function MunSpeak.ReadAdmins() -- Reads the MunSpeakAdmins.txt JSON string to get all MunSpeak Admins
	if(file.Exists("MunSpeakAdmins.txt", "DATA")) then
		MunSpeakAdmins = util.JSONToTable(file.Read( "MunSpeakAdmins.txt", "DATA" ))
	else
		MunSpeakAdmins = {"Server"}
		MunSpeak.WriteAdmins()
	end
end

function MunSpeak.IsAdmin(ply)
	if(table.HasValue(MunSpeakAdmins,ply:SteamID()) == true) then
		return true
	else
		return false
	end
end

function MunSpeak.First()	-- What this addon will do when it initializes. 
	MunSpeak.ReadTable()
	MunSpeak.ReadAdmins()
end

function MunSpeak.FindPlayer(target) -- Very useful function for finding a player with just a small string.  eg:  mun would find Muneris (the playerdata) else throw a chat error with more information.
	local Target = 0
	local TargetPlayer
	local MunSpeakPlayerName = target
	
	for k,v in pairs(player.GetAll()) do
		if (string.find(string.lower(v:Name()), string.lower(MunSpeakPlayerName)))then 
			Target = Target + 1
			TargetPlayer = v
		end
	end
		
	if(Target == 0) then PrintMessage(HUD_PRINTTALK,"[MunSpeak] - No player found with that name") end
	if(Target > 1) then PrintMessage(HUD_PRINTTALK,"[MunSpeak] - Too many players found. Try refining the search criteria") end
		
	if(Target == 1) then
		return TargetPlayer
	end
	
end

function MunSpeak.MovePlayer(ply,target,channel) -- ply is the player trying to initiate the move function, target is the player to move, and channel is the channel to move the target into.
	if(ply:IsAdmin() or MunSpeak.IsAdmin(ply)) then
		if(MunSpeakChannels[channel]==nil) then ply:PrintMessage(HUD_PRINTTALK,"Channel does not exist")
			PrintMessage(HUD_PRINTTALK,channel)
		else
			MunSpeak.JoinChannel(target,channel,_,true) 
		end
	else
		ply:PrintMessage(HUD_PRINTTALK,"You do not have the sufficient permissions")
	end
end

function MunSpeak.CreateAdmin(ply,target)
	if(ply:IsAdmin() and table.HasValue(MunSpeakAdmins,ply:SteamID()) == false ) then
		target.MunSpeakAdmin = true
		table.insert(MunSpeakAdmins,target:SteamID())
		PrintMessage(HUD_PRINTTALK,"Made "..target:Nick().." into a MunSpeak Admin!")
		MunSpeak.WriteAdmins()
	else
		if(table.HasValue(MunSpeakAdmins,ply:SteamID()) == true) then 
			PrintMessage(HUD_PRINTTALK,"Player is already an admin") return
		end
			PrintMessage(HUD_PRINTTALK,"You do not have permission to do that action.")
	end
end

net.Receive("MunSpeakClientJoin",function() -- Handles the client trying to join a channel via the UI
local ClientTable = net.ReadTable()
local Player = ClientTable[1]
local Channel = ClientTable[2]
local Password = ClientTable[3]

MunSpeak.JoinChannel(Player,Channel,Password)
end)

net.Receive("MunSpeakCreateChannel",function() -- Handles the client creating a channel via UI
local ClientTable = net.ReadTable()
local Player = ClientTable[1]
local Channel = ClientTable[2]
local Password = ClientTable[3]

MunSpeak.CreateChannel(Player,Channel,Password)
end)

hook.Add("PlayerSay", "munspeakcreate", MunSpeak.ChatMessages) -- When / commands are ran, this hook handles it.
hook.Add("PlayerSpawn","MunTalkPlayerHasConnected",MunSpeak.PlayerHasConnected) -- When a player connects to the server
hook.Add( "Initialize", "MunSpeakInit", MunSpeak.First ) -- When the addon first starts up
