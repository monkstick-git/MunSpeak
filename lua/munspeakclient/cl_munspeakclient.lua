local playerChannel = "";
local Channels = {}
local open = true
local PanelX = 50
local PanelY = 50
local MouseX = 0
local MouseY = 0

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
	MunSpeakPanel:SetPos( PanelX, PanelY )
	MunSpeakPanel:SetSize( 450, 340 )
	MunSpeakPanel:SetTitle( "MunSpeak - Version 0.1" )
	MunSpeakPanel:SetVisible( true )
	MunSpeakPanel:SetDraggable( true )
	MunSpeakPanel:ShowCloseButton( true )
	MunSpeakPanel:MakePopup()
	function MunSpeakPanel:OnClose()
	open = !open
	PanelX, PanelY = MunSpeakPanel:GetBounds()
	MouseX, MouseY = input.GetCursorPos( )
	end
	
	MunSpeakJoin = vgui.Create("DButton", MunSpeakPanel)
	MunSpeakJoin:SetPos( 340, 35 )
	MunSpeakJoin:SetSize( 75, 30 )
	MunSpeakJoin:SetText("Join")
	function MunSpeakJoin.DoClick( self )
	local Pass = ""
	if(MunSpeakTextInput:GetValue() == "password...") then Pass = "" else Pass = MunSpeakTextInput:GetValue() end
	if( MunSpeakParent:GetSelectedItem( )) then
		net.Start("MunSpeakClientJoin")
		net.WriteTable({LocalPlayer(),MunSpeakParent:GetSelectedItem( ).Channel,Pass})
	else
	
	end
	net.SendToServer()
	MunSpeakPanel:Close()
	timer.Simple(0.001,function() MunSpeakOpenUI() end)
	end
	
	MunSpeakTextInput = vgui.Create( "DTextEntry", MunSpeakPanel )	-- create the form as a child of frame
	MunSpeakTextInput:SetPos( 340, 75 )
	MunSpeakTextInput:SetSize( 75, 30 )
	MunSpeakTextInput:SetText( "password..." )
	MunSpeakTextInput.OnEnter = function( self )
	local Pass = ""
	if(self:GetValue() == "password...") then Pass = "" else Pass = self:GetValue() end
	if( MunSpeakParent:GetSelectedItem( )) then
		net.Start("MunSpeakClientJoin")
		net.WriteTable({LocalPlayer(),MunSpeakParent:GetSelectedItem( ).Channel,Pass})
	else
	
	end
	net.SendToServer()
	MunSpeakPanel:Close()
	timer.Simple(0.001,function() MunSpeakOpenUI() end)
	--chat.AddText( self:GetValue() )	-- print the form's text as server text
	end
	
	MunSpeakParent = vgui.Create( "DTree", MunSpeakPanel )
	 
	MunSpeakParent:SetPos( 5, 30 )
	MunSpeakParent:SetPadding( 5 )
	MunSpeakParent:SetSize( 300, 300 )
	MunSpeakParent:SetExpanded(true)

	for k,v in pairs(Channels) do
		MunSpeakChild = MunSpeakParent:AddNode( k ,"icon16/folder_user.png")
		MunSpeakChild.Channel = k
		MunSpeakChild:SetExpanded(true)
	for key,value in pairs(v.Members) do
		local TempNick = "nil"
		if(value == NULL) then MsgN("Value not Valid!") else TempNick = value:Nick() end
		cnode = MunSpeakChild:AddNode(TempNick,"icon16/user.png")
		cnode.Player = value
--	print(key.."  "..value:Nick())
	end
	
	end
end

hook.Add("Initialize","MunSpeakInit",function() timer.Simple(2,ShowPanel) print("SHOWING THE PANEL") end)


concommand.Add("munspeak", function()
MunSpeakOpenUI()
end)

function MunSpeakOpenUI()
	open = !open
	if(open) then ShowPanel() gui.SetMousePos(MouseX, MouseY) else MouseX, MouseY = input.GetCursorPos( )	PanelX, PanelY = MunSpeakPanel:GetBounds() MunSpeakPanel:Close() end
end