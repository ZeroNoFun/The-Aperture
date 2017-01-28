--[[

	GMOD APERTURE SCIENCE CONTROL PANEL
	
]]


if ( SERVER ) then return end

surface.CreateFont( "GASL_SecFont", {
	font = "Arial",
	size = 17,
	weight = 1000,
	antialias = true,
	italic = true,
} )

local function GASL_BuildPanel( Panel )

	Panel:ClearControls()
	
	-- //
	-- if not LocalPlayer():IsSuperAdmin() then
		-- //
		-- Panel.StateText=vgui.Create("DLabel")
			-- Panel.StateText:SetColor(BackColor)
			-- Panel.StateText:SetFont("GASL_SecFont")
			-- Panel.StateText:SetText("You GASL status: "..tostring(GetPlyAccess(LocalPlayer())))
			-- Panel.StateText:SizeToContents()
		-- Panel:AddItem(Panel.StateText)
		-- //
		-- local CrosLine=vgui.Create('DPanelList')
			-- CrosLine:SetSize(200,2)
			-- CrosLine.Paint=function() draw.RoundedBox(0,0,0,CrosLine:GetWide(),CrosLine:GetTall(),BackColor) end
		-- Panel:AddItem(CrosLine)
		-- //
		-- Panel.UserPanel=vgui.Create('DPanelList')
			-- Panel.UserPanel:SetPadding(1)
			-- Panel.UserPanel:SetSpacing(1)
			-- Panel.UserPanel:SetAutoSize(true)
			-- Panel.UserPanel.Paint=function()
				-- draw.RoundedBox(0,0,0,Panel.UserPanel:GetWide(),Panel.UserPanel:GetTall(),BackColor)
			-- end
		-- Panel:AddItem(Panel.UserPanel)
		-- //
		-- Panel.PassBox=vgui.Create("DTextEntry")
			-- Panel.PassBox:SetText("Enter password")
			-- Panel.PassBox:SetSize(200,22)
			-- Panel.PassBox:SelectAllOnFocus()
		-- Panel.UserPanel:AddItem(Panel.PassBox)
		-- //
		-- Panel.PassBut=vgui.Create("DButton")
			-- Panel.PassBut:SetText("Okay")
			-- Panel.PassBut:SetSize(200,18)
			-- Panel.PassBut.DoClick=function()
				-- local Pass=Panel.PassBox:GetValue()
				-- RunConsoleCommand("GASL_pass",Pass)
				-- timer.Simple(0.2,function() Panel.StateText:SetText("You GASL status: "..tostring(GetPlyAccess(LocalPlayer()))) end)
			-- end
		-- Panel.UserPanel:AddItem(Panel.PassBut)
		-- //
		-- Panel.GetListBut=vgui.Create("DButton")
			-- Panel.GetListBut:SetText("Get player list")
			-- Panel.GetListBut:SetSize(200,18)
			-- Panel.GetListBut.DoClick=function()
				-- for _,ply in pairs(player.GetAll()) do
					-- LocalPlayer():ChatPrint(ply:Nick()..' - '..tostring(GetPlyAccess(ply)))
				-- end
			-- end
		-- Panel.UserPanel:AddItem(Panel.GetListBut)
		-- //
		-- return
	-- end
	-- ////////////////////
	-- /// Player panel
	-- Panel.PlayerText=vgui.Create("DLabel")
		-- Panel.PlayerText:SetColor(BackColor)
		-- Panel.PlayerText:SetFont("GASL_SecFont")
		-- Panel.PlayerText:SetText("Click on line and chose an option")
		-- Panel.PlayerText:SizeToContents()
	-- Panel:AddItem(Panel.PlayerText)
	-- //
	-- Panel.PlayerPanel=vgui.Create('DPanelList')
		-- Panel.PlayerPanel:SetPadding(1)
		-- Panel.PlayerPanel:SetSpacing(1)
		-- Panel.PlayerPanel:SetAutoSize(true)
		-- Panel.PlayerPanel.Paint=function()
			-- draw.RoundedBox(0,0,0,Panel.PlayerPanel:GetWide(),Panel.PlayerPanel:GetTall(),BackColor)
		-- end
	-- Panel:AddItem(Panel.PlayerPanel)
	-- //
	-- Panel.PlyList=vgui.Create('DListView')
		-- Panel.PlyList:SetSize(100,150)
		-- Panel.PlyList:AddColumn("Nick")
		-- Panel.PlyList:AddColumn("Access"):SetFixedWidth(60)
		-- Panel.PlyList:SetMultiSelect(false)
		-- Panel.PlyList.LoadPlyList=function(self)
			-- Panel.PlyList:Clear()
			-- for _,ply in pairs(player.GetAll()) do
				-- Panel.PlyList:AddLine(ply:Nick(),tostring(GetPlyAccess(ply)))
			-- end
		-- end
		-- Panel.PlyList.OnClickLine=function(parent,line,isselected)
			-- local Pl=line:GetValue(1)
			-- local Stat=tobool(line:GetValue(2))
			-- local ContMenu=DermaMenu()
				-- if not Stat then
					-- ContMenu:AddOption("Give Access",function()  
						-- RunConsoleCommand('GASL_give_access',Pl)
						-- timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
					-- end)
				-- else
					-- ContMenu:AddOption("Remove Access",function()  
						-- RunConsoleCommand('GASL_remove_access',Pl)
						-- timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
					-- end)
				-- end
			-- ContMenu:Open()
		-- end
	-- Panel.PlyList.LoadPlyList()
	-- Panel.PlayerPanel:AddItem(Panel.PlyList)
	-- //
	-- Panel.RemoveAllBut=vgui.Create("DButton")
		-- Panel.RemoveAllBut:SetText("Remove access for all players")
		-- Panel.RemoveAllBut:SetSize(200,18)
		-- Panel.RemoveAllBut.DoClick=function()
			-- RunConsoleCommand('GASL_all_remove_access')
			-- timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
		-- end
	-- Panel.PlayerPanel:AddItem(Panel.RemoveAllBut)
	-- /////////////////////
	-- /// Other function panel
	-- Panel.OptionText=vgui.Create("DLabel")
		-- Panel.OptionText:SetColor(BackColor)
		-- Panel.OptionText:SetFont("GASL_SecFont")
		-- Panel.OptionText:SetText("Password manager")
		-- Panel.OptionText:SizeToContents()
	-- Panel:AddItem(Panel.OptionText)
	-- //
	-- Panel.FuncPanel=vgui.Create('DPanelList')
		-- Panel.FuncPanel:SetPadding(1)
		-- Panel.FuncPanel:SetSpacing(1)
		-- Panel.FuncPanel:SetAutoSize(true)
		-- Panel.FuncPanel.Paint=function()
			-- draw.RoundedBox(0,0,0,Panel.FuncPanel:GetWide(),Panel.FuncPanel:GetTall(),BackColor)
		-- end
	-- Panel:AddItem(Panel.FuncPanel)
	-- //
	-- Panel.DisPassBut=vgui.Create("DButton")
		-- Panel.DisPassBut:SetText("Disable password")
		-- Panel.DisPassBut:SetSize(200,18)
		-- Panel.DisPassBut.DoClick=function()
			-- RunConsoleCommand('GASL_disable_pass')
			-- timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
		-- end
	-- Panel.FuncPanel:AddItem(Panel.DisPassBut)
	-- //
	-- Panel.GetPassBut=vgui.Create("DButton")
		-- Panel.GetPassBut:SetText("Get password")
		-- Panel.GetPassBut:SetSize(200,18)
		-- Panel.GetPassBut.DoClick=function()
			-- RunConsoleCommand('GASL_get_pass')
		-- end
	-- Panel.FuncPanel:AddItem(Panel.GetPassBut)
	-- //
	-- Panel.SetFreeBut=vgui.Create("DButton")
		-- Panel.SetFreeBut:SetSize(200,18)
		-- Panel.SetFreeBut:SetText("Set free password. Status: "..tostring(GetGlobalBool("GASLFreeStatus")))
		-- Panel.SetFreeBut.DoClick=function()
			-- RunConsoleCommand('GASL_set_pass_free')
			-- timer.Simple(0.2,function() 
				-- Panel.SetFreeBut:SetText("Set free pass. Status: "..tostring(GetGlobalBool("GASLFreeStatus")))
			-- end)
		-- end
	-- Panel.FuncPanel:AddItem(Panel.SetFreeBut)
	-- //
	-- Panel.PassBox=vgui.Create("DTextEntry")
		-- Panel.PassBox:SetText("Enter new password")
		-- Panel.PassBox:SetSize(200,22)
		-- Panel.PassBox:SelectAllOnFocus()
	-- Panel.FuncPanel:AddItem(Panel.PassBox)
	-- //
	-- Panel.PassBut=vgui.Create("DButton")
		-- Panel.PassBut:SetText("Setup new password")
		-- Panel.PassBut:SetSize(200,18)
		-- Panel.PassBut.DoClick=function()
			-- local NewPass=Panel.PassBox:GetValue()
			-- if NewPass!="Enter new password" then
				-- RunConsoleCommand("GASL_set_pass",NewPass)
			-- else
				-- LocalPlayer():ChatPrint('[GASL]: Enter normal pass!!')
			-- end
		-- end
	-- Panel.FuncPanel:AddItem(Panel.PassBut)
	-- /////////////////////
	-- /// Groups panel
	-- Panel.GroupText=vgui.Create("DLabel")
		-- Panel.GroupText:SetColor(BackColor)
		-- Panel.GroupText:SetFont("GASL_SecFont")
		-- Panel.GroupText:SetText("To remove a group, click on its name")
		-- Panel.GroupText:SizeToContents()
	-- Panel:AddItem(Panel.GroupText)
	-- //
	-- Panel.GroupPanel=vgui.Create('DPanelList')
		-- Panel.GroupPanel:SetPadding(1)
		-- Panel.GroupPanel:SetSpacing(1)
		-- Panel.GroupPanel:SetAutoSize(true)
		-- Panel.GroupPanel.Paint=function()
			-- draw.RoundedBox(0,0,0,Panel.GroupPanel:GetWide(),Panel.GroupPanel:GetTall(),BackColor)
		-- end
	-- Panel:AddItem(Panel.GroupPanel)
	-- //
	-- Panel.GroupList=vgui.Create('DListView')
		-- Panel.GroupList:SetSize(200,100)
		-- Panel.GroupList:AddColumn("Group Name")
		-- Panel.GroupList:SetMultiSelect(false)
		-- Panel.GroupList.LoadGroupList=function(self)
			-- Panel.GroupList:Clear()
			-- local Groups=util.JSONToTable(GetGlobalString("GASLGroupList")) or {}
			-- for _,group in pairs(Groups) do
				-- Panel.GroupList:AddLine(group)
			-- end
		-- end
		-- Panel.GroupList.OnClickLine=function(parent,line,isselected)
			-- local Group=line:GetValue(1)
			-- local ContMenu=DermaMenu()
				-- ContMenu:AddOption("Remove group",function()  
					-- RunConsoleCommand('GASL_remove_access_group',Group)
					-- timer.Simple(0.2,function() 
						-- Panel.GroupList.LoadGroupList() 
						-- Panel.PlyList.LoadPlyList()
					-- end)
				-- end)
			-- ContMenu:Open()
		-- end
	-- Panel.GroupList.LoadGroupList()
	-- Panel.GroupPanel:AddItem(Panel.GroupList)
	-- //
	-- Panel.GroupBox=vgui.Create("DTextEntry")
		-- Panel.GroupBox:SetText("Enter new group name")
		-- Panel.GroupBox:SetSize(200,22)
		-- Panel.GroupBox:SelectAllOnFocus()
	-- Panel.GroupPanel:AddItem(Panel.GroupBox)
	-- //
	-- Panel.GroupBut=vgui.Create("DButton")
		-- Panel.GroupBut:SetText("Create group")
		-- Panel.GroupBut:SetSize(200,18)
		-- Panel.GroupBut.DoClick=function()
			-- local NewName=Panel.GroupBox:GetValue()
			-- if NewName!="Enter new group name" then
				-- RunConsoleCommand("GASL_give_access_group",NewName)
				-- Panel.GroupBox:SetText("Enter new group name")
				-- timer.Simple(0.2,function() 
					-- Panel.GroupList.LoadGroupList()
					-- Panel.PlyList.LoadPlyList()
				-- end)
			-- else
				-- LocalPlayer():ChatPrint('[GASL]: Enter normal name!!')
			-- end
		-- end
	-- Panel.GroupPanel:AddItem(Panel.GroupBut)
	-- /////////////////////
	-- /// Version and Logo
	-- local E2PVersion=GetGlobalString("GASLVersion")
	-- Panel.VersionText=vgui.Create("DLabel")
		-- Panel.VersionText:SetColor(BackColor)
		-- Panel.VersionText:SetFont("GASL_SecFont")
		-- Panel.VersionText:SetText(E2PVersion)
		-- Panel.VersionText:SizeToContents()
	-- Panel:AddItem(Panel.VersionText)
	-- //
	-- Panel.LogoPanel=vgui.Create('DPanelList')
		-- Panel.LogoPanel:SetNoSizing(true)
		-- Panel.LogoPanel:SetAutoSize(true)
		-- Panel.LogoPanel.Paint=nil
	-- Panel:AddItem(Panel.LogoPanel)
	-- //
	-- Panel.Logo=vgui.Create('DPanel')
		-- Panel.Logo:SetSize(250,250)
		-- Panel.Logo.Paint=function()
			-- surface.SetTexture(surface.GetTextureID("expression 2/cog"))
			-- surface.SetDrawColor(BackColor)
			-- surface.DrawTexturedRectRotated(Panel.Logo:GetWide()/2,Panel.Logo:GetTall()/2,Panel.Logo:GetWide()-2,Panel.Logo:GetTall()-2,RealTime()*20)
		-- end
	-- Panel.LogoPanel:AddItem(Panel.Logo)
	-- //
	-- local CrosLine=vgui.Create('DPanelList')
		-- CrosLine:SetSize(200,2)
		-- CrosLine.Paint=function() draw.RoundedBox(0,0,0,CrosLine:GetWide(),CrosLine:GetTall(),BackColor) end
	-- Panel:AddItem(CrosLine)
	//
	
	if !GASL_Panel then
		GASL_Panel = Panel
	end
end


function GASL_SMO()

	if GASL_Panel then
		GASL_BuildPanel( GASL_Panel )
	end
	
end

hook.Add("SpawnMenuOpen","GASL_SpawnMenuOpen", GASL_SMO)

hook.Add( "PopulateToolMenu", "GASL_PopulateToolMenu", function()

	spawnmenu.AddToolMenuOption( "Utilities", "GMOD Aperture Science Laboratories", "Menu", "GMOD Aperture Science Laboratories", "", "", GASL_BuildPanel )
	
end )

/// ULX Integr 
/// Don't remove this if you not use ULX !
for name,data in pairs(hook.GetTable()) do
	if name=="UCLChanged" then
		hook.Add("UCLChanged","GASL_Update",GASL_SMO)
		break
	end
end