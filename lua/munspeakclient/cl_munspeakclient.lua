function MunSpeakInit()
	LP = LocalPlayer()
	LP["MS"]={}
	LP["MS"]["X"]=0
	LP["MS"]["XX"]=0
	LP["MS"]["H"]=0
	LP["MS"]["HH"]=0
	LP["MS"]["TH"]=0
	LP["MS"]["THH"]=0
	LP["MS"]["SI"]=""
	LP["MS"]["BH"]=0
	LP["MS"]["BHH"]=0
	local open=false
end

function MunSpeakGetChannels()
	LP = LocalPlayer()
	LP["Channels"] = net.ReadTable()
end

function MunSpeakShowUi()
	LP = LocalPlayer()

	if LP["MS"]==nil then
		MunSpeakInit()
	end
	
	local MunSpeakUI = vgui.Create( "DFrame" )
	open = true
	MunSpeakUI:SetPos( -400,50 )
	MunSpeakUI:SetSize( 400, ScrH()/2 )
	MunSpeakUI:SetTitle( "MunSpeak 0.1" )
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
	end
	
	function MunSpeakUI:OnClose()
		open = false
		LP["MS"]["X"]=-400
		LP["MS"]["XX"]=-400
		LP["MS"]["SI"]=""
	end
	
	local MunTree = vgui.Create("DTree",MunSpeakUI)
	MunTree:SetPos(10,40)
	MunTree:SetSize(MunSpeakUI:GetWide()-20,MunSpeakUI:GetTall()-50)
	for k,v in pairs(LP["Channels"]) do
		if v["Password"]~=nil and string.len(v["Password"])>0 then
			local ChannelNode = MunTree:AddNode(k,"icon16/bullet_key.png")
			ChannelNode["Channel"]=k
			for kk,vv in pairs(LP["Channels"][k]["Members"]) do
				local PlayerNode = ChannelNode:AddNode(vv:GetName(),"icon16/user.png")
				PlayerNode["Channel"]="Player"
			end
		else
			local ChannelNode = MunTree:AddNode(k,"icon16/bullet_go.png")
			ChannelNode["Channel"]=k
			for kk,vv in pairs(LP["Channels"][k]["Members"]) do
				if IsValid(vv) then
					local PlayerNode = ChannelNode:AddNode(vv:GetName(),"icon16/user.png")
					PlayerNode["Channel"]="Player"
				end
			end
		end
	end
	
	MunTree.DoClick = function(self)
		LP["MS"]["SI"]=MunTree:GetSelectedItem()["Channel"]
		print(table.ToString(LP["Channels"]))
	end
	
	function MunTree:Think()
		if LP["MS"]["SI"]~="Player" and string.len(LP["MS"]["SI"])>0 then
			LP["MS"]["THH"]=MunSpeakUI:GetTall()-170
		else
			LP["MS"]["THH"]=MunSpeakUI:GetTall()-50
		end
		LP["MS"]["TH"] = LP["MS"]["TH"] + (LP["MS"]["THH"]-LP["MS"]["TH"])/20
		MunTree:SetSize(MunSpeakUI:GetWide()-20,LP["MS"]["TH"])
	end
	
	local MunButtons = vgui.Create("DPanel",MunSpeakUI)
	function MunButtons:Think()
		MunButtons:SetPos(10,LP["MS"]["TH"]+60)
		MunButtons:SetSize(MunSpeakUI:GetWide()-20,100)
	end
	
	local MunPassword = vgui.Create("DTextEntry", MunButtons)
	MunPassword:SetPos(10,55)
	MunPassword:SetSize(MunSpeakUI:GetWide()-40,30)
	MunPassword:SetVisible(true)
	
	local MunJoinButton = vgui.Create("DButton", MunButtons)
	MunJoinButton:SetPos(10,10)
	MunJoinButton:SetText("Join")
	MunJoinButton.Paint = function(self)
		draw.RoundedBox( 4, 0, 0, MunJoinButton:GetWide(),MunJoinButton:GetTall(), Color(50,255,50,255) )
	end
	MunJoinButton.DoClick = function(self)
		net.Start("MunSpeakClientJoin")
		net.WriteTable({LocalPlayer(),LP["MS"]["SI"],MunPassword:GetValue()})
		net.SendToServer()
		MunSpeakUI:Close()
	end
	function MunJoinButton:Think()
		if LP["MS"]["SI"]~="" and LP["MS"]["SI"]~="Player" and string.len(LP["Channels"][LP["MS"]["SI"]]["Password"])>0 then
			LP["MS"]["BHH"]=40
		else
			LP["MS"]["BHH"]=80
		end
		LP["MS"]["BH"] = LP["MS"]["BH"] + (LP["MS"]["BHH"]-LP["MS"]["BH"])/10
		MunJoinButton:SetSize(MunSpeakUI:GetWide()-40,LP["MS"]["BH"])
	end
	
end


hook.Add("InitPostEntity","MunSpeakInit",MunSpeakInit)
net.Receive( "MunSpeakShowUi", MunSpeakShowUi )
net.Receive( "MunSpeakChannels", MunSpeakGetChannels )
