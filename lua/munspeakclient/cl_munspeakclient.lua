
function MunSpeakInit()
	surface.CreateFont( "ContextFont", {
		font = "Arial",
		size = 15,
		weight = 100,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false
	}
	)
	LP = LocalPlayer()
	LP["MS"]={}
	LP["Open"]=false
	LP["MS"]["X"]=0
	LP["MS"]["XX"]=0
	LP["MS"]["H"]=0
	LP["MS"]["HH"]=0
	LP["MS"]["TH"]=0
	LP["MS"]["THH"]=0
	LP["MS"]["SI"]=""
	LP["MS"]["BH"]=0
	LP["MS"]["BHH"]=0
	LP["MS"]["Expand"]=false
	local open=false
	surface.PlaySound("hl1/fvox/voice_on.wav")
end

function MunSpeakGetChannels()
	LP = LocalPlayer()
	LP["Channels"] = net.ReadTable()
	LP["Channel"] = (LP:GetNWString("Channel") or "Default")
end

function MunSpeakCheck()
	LP = LocalPlayer()
	if LP["Channel"]==nil then
		LP["Channel"] = (LP:GetNWString("Channel") or "Default")
	end
	if LP["Channels"]==nil then
		net.Start("MunSpeakRequestChannels")
		net.SendToServer()
		LP["Channel"] = (LP:GetNWString("Channel") or "Default")
	end
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) and (v:GetNWString("Channel")~=LP["Channel"] and v~=LocalPlayer()) and v:IsMuted()==false then
			v:SetMuted(true)
		end
		if IsValid(v) and (v:GetNWString("Channel")==LP["Channel"] or v==LocalPlayer()) and v:IsMuted()==true then
			v:SetMuted(false)
		end
	end
end

function MunContext()
	LP["CM"]=vgui.Create("DFrame")
	LP["CM"]:SetTitle("")
	LP["CM"]:SetPos(20,220)
	LP["CM"]:SetSize(58,78)
	LP["CM"]:SetVisible(true)
	LP["CM"]:ShowCloseButton(false)
	LP["CM"]:MakePopup()
	
	LP["CM"].Paint = function(self)
		draw.RoundedBox( 4, 0, 0, LP["CM"]:GetWide(),LP["CM"]:GetTall()-20, Color(255,255,255,150) )
		draw.RoundedBox( 4, 2, 2, LP["CM"]:GetWide()-4,LP["CM"]:GetTall()-24, Color(0,0,0,150) )
		surface.SetFont("ChatFont")
		draw.SimpleText("MunSpeak", "ContextFont", LP["CM"]:GetWide()/2,LP["CM"]:GetTall()-10, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	local BImg = vgui.Create("DImageButton",LP["CM"])
	BImg:SetPos(10,10)
	BImg:SetSize(38,38)
	BImg:SetImage("icon16/server_connect.png")
	BImg.DoClick = function(self)
		LocalPlayer():ConCommand("MunSpeak")
	end
end

function MunContextClose()
	if LP["CM"]~=nil then
		LP["CM"]:Close()
		LP["CM"]=nil
	end
end

function MunSpeakShowUi()
	LP = LocalPlayer()

	if LP["MS"]==nil then
		MunSpeakInit()
	end
	
	local MunSpeakUI = vgui.Create( "DFrame" )
	open = true
	MunSpeakUI:SetPos( -400,50 )
	MunSpeakUI:SetTitle( "MunSpeak 0.9" )
	MunSpeakUI:SetVisible( true )
	MunSpeakUI:SetDraggable( false )
	MunSpeakUI:ShowCloseButton( true )
	MunSpeakUI:MakePopup()
	MunSpeakUI.Paint = function(self)
		draw.RoundedBox( 4, 0, 0, MunSpeakUI:GetWide(),MunSpeakUI:GetTall(), Color(0,0,0,240) )
	end
	
	function MunSpeakUI:Think()
		if open==true then
			LP["MS"]["XX"]=10
		else
			LP["MS"]["XX"]=-400
		end
		LP["MS"]["X"] = LP["MS"]["X"] + (LP["MS"]["XX"]-LP["MS"]["X"])/20
		MunSpeakUI:SetPos(LP["MS"]["X"],10)
		if LP["MS"]["Expand"] then
			LP["MS"]["HH"]=ScrW()/2.5
		else
			LP["MS"]["HH"]=ScrW()/4
		end
		LP["MS"]["H"] = LP["MS"]["H"] + (LP["MS"]["HH"]-LP["MS"]["H"])/20
		MunSpeakUI:SetSize( LP["MS"]["H"], ScrH()/2 )
	end
	
	function MunSpeakUI:OnClose()
		open = false
		LP["MS"]["X"]=-400
		LP["MS"]["XX"]=-400
		LP["MS"]["SI"]=""
		LP["MS"]["Expand"]=false
		LP["Open"]=false
	end
	
	local MunTree = vgui.Create("DTree",MunSpeakUI)
	MunTree:SetPos(10,40)
	MunTree:SetSize(MunSpeakUI:GetWide()-20,MunSpeakUI:GetTall()-50)
	for k,v in pairs(LP["Channels"]) do
		if v["Password"]~=nil and string.len(v["Password"])>0 then
			local ChannelNode = MunTree:AddNode(k,"icon16/bullet_key.png")
			ChannelNode["Channel"]=k
			for kk,vv in pairs(LP["Channels"][k]["Members"]) do
				if IsValid(vv) then
				local PlayerNode = ChannelNode:AddNode(vv:GetName(),"icon16/user.png")
				PlayerNode["Channel"]="Player"
				PlayerNode["Ply"]=vv
				end
			end
		else
			if k~="Default" then
				ChannelNode = MunTree:AddNode(k,"icon16/bullet_go.png")
			else
				ChannelNode = MunTree:AddNode(k,"icon16/server.png")
			end
			ChannelNode["Channel"]=k
			for kk,vv in pairs(LP["Channels"][k]["Members"]) do
				if IsValid(vv) then
					local PlayerNode = ChannelNode:AddNode(vv:GetName(),"icon16/user.png")
					PlayerNode["Channel"]="Player"
					PlayerNode["Ply"]=vv
				end
			end
		end
	end
	
	MunTree.DoClick = function(self)
		LP["MS"]["SI"]=MunTree:GetSelectedItem()["Channel"]
		surface.PlaySound( "buttons/button14.wav" )
	end
	
	MunTree.DoRightClick = function(self)
		if MunTree:GetSelectedItem()~=nil and MunTree:GetSelectedItem()["Ply"]~=nil and IsValid(MunTree:GetSelectedItem()["Ply"]) then
			net.Start("MunSpeakMovePlayer")
			net.WriteTable({LocalPlayer(),MunTree:GetSelectedItem()["Ply"],"Default"})
			net.SendToServer()
		end
		
		if MunTree:GetSelectedItem()~=nil and MunTree:GetSelectedItem()["Channel"]~=nil then
			net.Start("MunSpeakDeleteChannel")
			net.WriteTable({LocalPlayer(),MunTree:GetSelectedItem()["Channel"]})
			net.SendToServer()
			MunSpeakUI:Close()
		end
		surface.PlaySound("buttons/button10.wav")
	end
	function MunTree:Think()
		if LP["MS"]["SI"]~="Player" and string.len(LP["MS"]["SI"])>0 and LP["MS"]["SI"]~=(LP:GetNWString("Channel") or "Default") then
			LP["MS"]["THH"]=MunSpeakUI:GetTall()-170
		else
			LP["MS"]["THH"]=MunSpeakUI:GetTall()-50
		end
		LP["MS"]["TH"] = LP["MS"]["TH"] + (LP["MS"]["THH"]-LP["MS"]["TH"])/20
			MunTree:SetSize(ScrW()/4-20,LP["MS"]["TH"])
	end
	
	local MunButtons = vgui.Create("DPanel",MunSpeakUI)
	function MunButtons:Think()
		MunButtons:SetPos(10,LP["MS"]["TH"]+60)
		MunButtons:SetSize(MunSpeakUI:GetWide()-20,100)
	end
	
	local MunPassword = vgui.Create("DTextEntry", MunButtons)
	MunPassword:SetPos(10,55)
	MunPassword:SetVisible(true)
	function MunPassword:Think()
		MunPassword:SetSize(MunSpeakUI:GetWide()-40,30)
	end
	
	local MunJoinButton = vgui.Create("DButton", MunButtons)
	MunJoinButton:SetPos(10,10)
	MunJoinButton:SetText("")
	MunJoinButton.Paint = function(self)
		draw.RoundedBox( 12, 0, 0, MunJoinButton:GetWide(),MunJoinButton:GetTall(), Color(150,150,150,255) )
		surface.SetFont("ChatFont")
		draw.SimpleText("Join", "ChatFont", MunJoinButton:GetWide()/2,MunJoinButton:GetTall()/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	MunJoinButton.DoClick = function(self)
		net.Start("MunSpeakClientJoin")
		if LocalPlayer():SteamID()==LP["Channels"][LP["MS"]["SI"]]["Owner"] or LocalPlayer():IsAdmin() then
			net.WriteTable({LocalPlayer(),LP["MS"]["SI"],LP["Channels"][LP["MS"]["SI"]]["Password"]})
		else
			net.WriteTable({LocalPlayer(),LP["MS"]["SI"],MunPassword:GetValue()})
		end
		net.SendToServer()
		MunSpeakUI:Close()
		surface.PlaySound("hl1/fvox/acquired.wav")
	end
	function MunJoinButton:Think()
		if LP["MS"]["SI"]~="" and LP["MS"]["SI"]~="Player" and string.len(LP["Channels"][LP["MS"]["SI"]]["Password"])>0 then
			LP["MS"]["BHH"]=40
			MunPassword:SetVisible(true)
		else
			LP["MS"]["BHH"]=80
			MunPassword:SetVisible(false)
		end
		LP["MS"]["BH"] = LP["MS"]["BH"] + (LP["MS"]["BHH"]-LP["MS"]["BH"])/10
		MunJoinButton:SetSize(MunSpeakUI:GetWide()-40,LP["MS"]["BH"])
	end
	
	local MunExpandButton = vgui.Create("DButton",MunSpeakUI)
	MunExpandButton:SetSize(10,60)
	MunExpandButton:SetText("")
	function MunExpandButton:Think()
		MunExpandButton:SetPos(MunSpeakUI:GetWide()-MunExpandButton:GetWide(),MunSpeakUI:GetTall()/2-MunExpandButton:GetTall()/2)
	end
	MunExpandButton.Paint = function(self)
		draw.RoundedBox( 4, 0, 0, MunExpandButton:GetWide(),MunExpandButton:GetTall(), Color(150,150,150,255) )
		surface.SetFont("ChatFont")
		if LP["MS"]["Expand"] then
		draw.SimpleText("<", "ChatFont", MunExpandButton:GetWide()/2,MunExpandButton:GetTall()/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
		draw.SimpleText(">", "ChatFont", MunExpandButton:GetWide()/2,MunExpandButton:GetTall()/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	MunExpandButton.DoClick = function(self)
		LP["MS"]["Expand"] = !LP["MS"]["Expand"]
		surface.PlaySound("buttons/combine_button1.wav")
	end
	
	local MunExtraPanel = vgui.Create("DPanel",MunSpeakUI)
	MunExtraPanel:SetPos(ScrW()/4,40)
	function MunExtraPanel:Think()
		MunExtraPanel:SetSize(ScrW()/4/2+35,160)
	end
	
	local prevar1="Channel Name"
	local prevar2="Channel Password (optional)"
	LP["correct1"]=false
	LP["correct2"]=false
	
	local MunChannelName = vgui.Create("DTextEntry",MunExtraPanel)
	MunChannelName:SetPos(10,10)
	MunChannelName:SetText(prevar1)
	function MunChannelName:Think()
		MunChannelName:SetSize(MunExtraPanel:GetWide()-50,30)
	end
	
	local MunChannelPass = vgui.Create("DTextEntry",MunExtraPanel)
	MunChannelPass:SetPos(10,50)
	MunChannelPass:SetText(prevar2)
	function MunChannelPass:Think()
		MunChannelPass:SetSize(MunExtraPanel:GetWide()-50,30)
	end
	
	local MunChannelMake = vgui.Create("DButton",MunExtraPanel)
	MunChannelMake:SetPos(10,90)
	MunChannelMake:SetText("Create Channel")
	function MunChannelMake:Think()
		MunChannelMake:SetSize(MunExtraPanel:GetWide()-20,60)
	end
	MunChannelMake.DoClick = function(self)
		if LP["correct1"] and LP["correct2"] then
			net.Start("MunSpeakCreateChannel")
			if MunChannelPass:GetValue()==prevar2 then
				net.WriteTable({LocalPlayer(),MunChannelName:GetValue(),""})
			else
				net.WriteTable({LocalPlayer(),MunChannelName:GetValue(),MunChannelPass:GetValue()})
			end
			net.SendToServer()
		end
		surface.PlaySound("buttons/button5.wav")
		MunSpeakUI:Close()
	end
	
	local MunStatus1 = vgui.Create("DImage",MunExtraPanel)
	MunStatus1:SetImage("icon16/tick.png")
	MunStatus1:SizeToContents()
	function MunStatus1:Think()
		MunStatus1:SetPos(MunExtraPanel:GetWide()-30,15)
		if string.len(MunChannelName:GetValue())>0 and LP["Channels"][MunChannelName:GetValue()]==nil and string.Explode("",MunChannelName:GetValue())[1]==string.upper(string.Explode("",MunChannelName:GetValue())[1]) then
			MunStatus1:SetImage("icon16/accept.png")
			LP["correct1"]=true
		else
			MunStatus1:SetImage("icon16/exclamation.png")
			LP["correct1"]=false
		end
		MunStatus1:SizeToContents()
	end
	
	local MunStatus2 = vgui.Create("DImage",MunExtraPanel)
	function MunStatus2:Think()
		MunStatus2:SetPos(MunExtraPanel:GetWide()-30,55)
		if string.len(MunChannelName:GetValue())>0 and LP["Channels"][MunChannelName:GetValue()]==nil and MunChannelName:GetValue()~=prevar1 and string.len(MunChannelPass:GetValue())>0 then
			MunStatus2:SetImage("icon16/accept.png")
			LP["correct2"]=true
		else
			MunStatus2:SetImage("icon16/exclamation.png")
			LP["correct2"]=false
		end
		MunStatus2:SizeToContents()
	end
end

concommand.Add("munspeak",MunSpeakShowUi)
hook.Add("Tick","MunSpeakMute",MunSpeakCheck)
hook.Add("InitPostEntity","MunSpeakInit",MunSpeakInit)
hook.Add("OnContextMenuOpen","MunContextOpen",MunContext)
hook.Add("OnContextMenuClose","MunContextClose",MunContextClose)
net.Receive( "MunSpeakShowUi", MunSpeakShowUi )
net.Receive( "MunSpeakChannels", MunSpeakGetChannels )
