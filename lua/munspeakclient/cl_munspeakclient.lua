local playerChannel = "";
local Channels = {}

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
				if(IsValid(MunSpeakPanel)) then
					
				end
				
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

 
net.Receive("MunSpeakChannels",function()
Channels = net.ReadTable()
PrintTable(Channels)
end)

net.Receive("MunSpeakShowUi",function()
ShowPanel()
end)

function ShowPanel()

	MunSpeakPanel = vgui.Create( "DFrame" )
	MunSpeakPanel:SetPos( 50, 50 )
	MunSpeakPanel:SetSize( 310, 340 )
	MunSpeakPanel:SetTitle( "MunSpeak - Version 0.1" )
	MunSpeakPanel:SetVisible( true )
	MunSpeakPanel:SetDraggable( true )
	MunSpeakPanel:ShowCloseButton( true )
	MunSpeakPanel:MakePopup()
	 
	MunSpeakParent = vgui.Create( "DTree", MunSpeakPanel )
	 
	MunSpeakParent:SetPos( 5, 30 )
	MunSpeakParent:SetPadding( 5 )
	MunSpeakParent:SetSize( 300, 300 )


	for k,v in pairs(Channels) do
		local MunSpeakChild = MunSpeakParent:AddNode( k ,"icon16/folder_user.png")
	
	for key,value in pairs(v.Members) do
		local TempNick = "nil"
		if(value == NULL) then MsgN("VALUE NOT FUCKING VALID") else TempNick = value:Nick() end
		local cnode = MunSpeakChild:AddNode(TempNick,"icon16/user.png")
--	print(key.."  "..value:Nick())
	end
	
	end
end

hook.Add("Initialize","MunSpeakInit",function() timer.Simple(2,ShowPanel) print("SHOWING THE PANEL") end)

	-- for k,v in pairs(Channels) do
		-- local MunSpeakChild = MunSpeakParent:AddNode( k )
			-- for k1,v1 in pairs(v) do
				-- A=A+1
				-- local cnode = MunSpeakChild:AddNode(v1[A]:Nick())
			-- end
	-- end