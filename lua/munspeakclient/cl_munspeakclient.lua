local playerChannel = "";

function MunSpeakMute(ply)
local PlayerEnt = ply
	if(PlayerEnt:IsMuted( ) == false) then
		PlayerEnt:SetMuted(true)
		print("Muting "..PlayerEnt:Nick())
	end
end

function MunSpeakUnMute(ply)
local PlayerEnt = ply
	if(PlayerEnt:IsMuted( )) then
		PlayerEnt:SetMuted(false)
		print("Un Muting "..PlayerEnt:Nick())
	end
end

function MunSpeakLoop()
	local channel = LocalPlayer():GetNWString("channel")
	if(playerChannel != channel) then
		
		
		chat.AddText(Color(0,0,200), "[MunTalk] You joined the channel " .. channel)
		chat.AddText(Color(0,0,200), "[MunTalk] You left the channel " .. playerChannel)

		playerChannel = channel;

	end
	
		for k,v in pairs(player.GetAll()) do

			if(v == LocalPlayer()) then continue end

			local targetChannel = v:GetNWString("channel")

			if(not v.lastChannel or v.lastChannel != targetChannel) then
				
				if(v.lastChannel == playerChannel) then
					
					chat.AddText(Color(0,0,200), "[MunTalk] " .. v:Nick() .. " left your channel.")

				elseif(targetChannel == playerChannel) then
					
					chat.AddText(Color(0,0,200), "[MunTalk] " .. v:Nick() .. " joined your channel.")

				end

				v.lastChannel = targetChannel

			end

			
			if(targetChannel != playerChannel) then
				MunSpeakMute(v)
			else
				MunSpeakUnMute(v)
			end
		end
end

timer.Create("MunSpeakLoop",1,0,MunSpeakLoop)