--[Undertale Death Screen by VictorienXP@Xperidia]--
local ver = 1.0
if SERVER then

	resource.AddWorkshop("587343641")

	util.AddNetworkString("XP_UDS_CallScreen")

	xp_uds_sv_enabled = CreateConVar("xp_uds_sv_enabled", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable/disable the screen for all players.")

	hook.Add("PlayerDeathSound", "XP_UDS_MuteDeathSound", function()
		if xp_uds_sv_enabled:GetBool() then return true end
	end)

	hook.Add("PostPlayerDeath", "XP_UDS_DeathScreen", function(ply)
		if xp_uds_sv_enabled:GetBool() and ply:GetInfoNum("xp_uds_enabled", 1) == 1 then
			net.Start("XP_UDS_CallScreen")
			net.Send(ply)
		end
	end)

	MsgC(Color(255, 255, 85), "XP_UDS V" .. ver .. " loaded! (SV)\n")

end


if CLIENT then

	if !XP_UDS then XP_UDS = {} end

	XP_UDS.Strings =	{
							"Y o u    c a n n o t    g i v e\nu p    j u s t    y e t . . .",
							"D o n' t    l o s e    h o p e !",
							"Y o u' r e    g o i n g    t o\nb e    a l r i g h t!",
							"O u r    f a t e    r e s t s\nu p o n    y o u . . .",
							"I t    c a n n o t    e n d\nn o w !"
						}

	XP_UDS.Musics = {}
	XP_UDS.Musics.gameover = Sound("xp_uds/mus_gameover.ogg")
	XP_UDS.Musics.dogsong = Sound("xp_uds/mus_dogsong.ogg")

	function XP_UDS:SaveStrings()

		if !file.IsDir("xp_uds", "DATA") then
			file.CreateDir("xp_uds")
		end

		file.Write("xp_uds/strings.txt", util.TableToJSON(XP_UDS.Strings))

	end

	function XP_UDS:LoadStrings()

		local filep = file.Read("xp_uds/strings.txt")

		if filep then

			local tab = util.JSONToTable(filep)
			if tab then
				XP_UDS.Strings = tab
				MsgC(Color(255, 255, 85), "XP_UDS: Strings Loaded!\n")
			end

		else

			if !file.IsDir("xp_uds", "DATA") then
				file.CreateDir("xp_uds")
			end

			file.Write("xp_uds/strings.txt", util.TableToJSON(XP_UDS.Strings))

		end

	end

	xp_uds_enabled = CreateConVar("xp_uds_enabled", 1, { FCVAR_ARCHIVE, FCVAR_USERINFO }, "Enable/disable the screen for yourself.")
	xp_uds_playercolor = CreateConVar("xp_uds_playercolor", 1, { FCVAR_ARCHIVE }, "If it should use your player color (1) or the original color (0) for the heart/soul.")
	xp_uds_special = CreateConVar("xp_uds_special", 0, { FCVAR_ARCHIVE }, "Change the game over screen by a special game over screen:\n    1 Flowey\n    2 Sans")
	xp_uds_name = CreateConVar("xp_uds_name", "", { FCVAR_ARCHIVE }, "Change the displayed name.")
	xp_uds_color = CreateConVar("xp_uds_color", "0 0 0", { FCVAR_ARCHIVE }, "Change the heart/soul color. The value is a Vector - so between 0-1 - not between 0-255")
	xp_uds_force = CreateConVar("xp_uds_force", 0, { FCVAR_ARCHIVE }, "Force the use of the death screen. Only work in servers with \"sv_allowcslua 1\".")

	local function ForceUDS()
		if xp_uds_force:GetBool() then

			if !XP_UDS.DeathCount then XP_UDS.DeathCount = LocalPlayer():Deaths() end

			if LocalPlayer():Deaths() != XP_UDS.DeathCount then
				XP_UDS.ScreenFunc()
				XP_UDS.DeathCount = LocalPlayer():Deaths()
			end

		end
	end
	hook.Add("Think", "XP_UDS_Force", ForceUDS)

	surface.CreateFont("XP_UDS_MAIN", {
		font = "8bitoperator JVE",
		size = 35 * (ScrH() / 480),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})

	net.Receive("XP_UDS_CallScreen", function(len)
		XP_UDS.ScreenFunc()
	end)

	XP_UDS:LoadStrings()

	XP_UDS.StringSans = "g e e e t t t t t t t\nd u n k e d    o n ! ! !"

	XP_UDS.StringsFlowey = { "T h i s    i s    a l l    j u s t\na    b a d    d r e a m . . .", "A n d    y o u ' r e    N E V E R\nw a k i n g    u p !" }

	function XP_UDS.ScreenFunc()

		if !IsValid(XP_UDS.Screen) then

			XP_UDS.Screen = vgui.Create("DFrame")
			XP_UDS.Screen:ParentToHUD()
			XP_UDS.Screen:SetPos(0, 0)
			XP_UDS.Screen:SetSize(ScrW(), ScrH())
			XP_UDS.Screen:SetTitle("")
			XP_UDS.Screen:SetVisible(true)
			XP_UDS.Screen:SetDraggable(false)
			XP_UDS.Screen:ShowCloseButton(false)
			XP_UDS.Screen:SetScreenLock(true)
			XP_UDS.Screen:SetWorldClicker(true)
			XP_UDS.Screen.Paint = function(self, w, h)
				if XP_UDS.Screen.EndingAnim and XP_UDS.Screen.EndingTime + 0.4 > SysTime() then
					draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, math.Remap(255 * math.Remap(SysTime() - XP_UDS.Screen.EndingTime, 0, 0.4, 0, 1), 0, 255, 255, 0)))
				elseif XP_UDS.Screen.EndingAnim then
					draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
				else
					draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 255))
				end
			end
			XP_UDS.Screen.Think = function()

				if XP_UDS.GameoverAnim and XP_UDS.GameoverAnim:Active() then XP_UDS.GameoverAnim:Run() end
				if XP_UDS.TXTAnim and XP_UDS.TXTAnim:Active() then XP_UDS.TXTAnim:Run() end
				if XP_UDS.TXTAnimC and XP_UDS.TXTAnimC:Active() then XP_UDS.TXTAnimC:Run() end
				if XP_UDS.HeartShard_Anim_0 and XP_UDS.HeartShard_Anim_0:Active() then XP_UDS.HeartShard_Anim_0:Run() end
				if XP_UDS.HeartShard_Anim_1 and XP_UDS.HeartShard_Anim_1:Active() then XP_UDS.HeartShard_Anim_1:Run() end
				if XP_UDS.HeartShard_Anim_2 and XP_UDS.HeartShard_Anim_2:Active() then XP_UDS.HeartShard_Anim_2:Run() end
				if XP_UDS.HeartShard_Anim_3 and XP_UDS.HeartShard_Anim_3:Active() then XP_UDS.HeartShard_Anim_3:Run() end
				if XP_UDS.HeartShard_Anim_4 and XP_UDS.HeartShard_Anim_4:Active() then XP_UDS.HeartShard_Anim_4:Run() end
				if XP_UDS.HeartShard_Anim_5 and XP_UDS.HeartShard_Anim_5:Active() then XP_UDS.HeartShard_Anim_5:Run() end

				if XP_UDS.Screen.m_fCreateTime + 2.5 < SysTime() and (LocalPlayer():Alive() or LocalPlayer():KeyDown(IN_DUCK)) and !XP_UDS.Screen.Ending then
					if XP_UDS.GameoverAnim then XP_UDS.GameoverAnim:Stop() end
					if XP_UDS.GameoverAnim then XP_UDS.GameoverAnim:Start(2, "OFF") end
					if XP_UDS.TXTAnimC then XP_UDS.TXTAnimC:Start(1) end
					XP_UDS.Screen.Ending = true
					timer.Create("XP_UDS_GameoverEnding", 2, 1, function()
						XP_UDS.Screen.EndingAnim = true
						XP_UDS.Screen.EndingTime = SysTime()
					end)
					timer.Create("XP_UDS_GameoverEnding2", 2.4, 1, function()
						XP_UDS.Screen:Close()
					end)
				end

				if XP_UDS.Screen.Ending and XP_UDS.Screen.EndingTime and IsValid(XP_UDS.CurMusic) then
					XP_UDS.CurMusic:SetVolume(math.Clamp(math.Remap(SysTime() - XP_UDS.Screen.EndingTime, 0, 0.4, 1, 0), 0, 1))
				end

			end
			XP_UDS.Screen.OnClose = function()
				XP_UDS:Music("stop")
				timer.Remove("XP_UDS_Heart")
				timer.Remove("XP_UDS_GameoverSound")
				timer.Remove("XP_UDS_GameoverAnimTimer")
				timer.Remove("XP_UDS_GameoverAnimTXT")
				timer.Remove("XP_UDS_GameoverAnimTXT2")
			end
			XP_UDS.Screen:MakePopup()
			XP_UDS.Screen:SetKeyboardInputEnabled(false)

			if Vector(xp_uds_color:GetString()) and Vector(xp_uds_color:GetString()) != Vector(0, 0, 0) then
				XP_UDS.PlayerColor = Vector(xp_uds_color:GetString()):ToColor() or Color( 255, 0, 0, 255 )
			elseif LocalPlayer() and xp_uds_playercolor:GetBool() and LocalPlayer():GetInfo( "cl_playercolor" ) and LocalPlayer():GetInfo( "cl_playercolor" ) != "" and Vector(LocalPlayer():GetInfo( "cl_playercolor" )) != Vector(0, 0, 0) and Vector(LocalPlayer():GetInfo( "cl_playercolor" )) != Vector(0.24, 0.34, 0.41) then
				XP_UDS.PlayerColor = Vector(LocalPlayer():GetInfo( "cl_playercolor" )):ToColor() or Color( 255, 0, 0, 255 )
			else
				XP_UDS.PlayerColor = Color( 255, 0, 0, 255 )
			end

			XP_UDS.Screen.Heart = vgui.Create("DImage", XP_UDS.Screen)
			XP_UDS.Screen.Heart:SetImage("xp_uds/heart")
			XP_UDS.Screen.Heart:SetPos(ScrW() / 2 - (32 * (ScrH() / 480)) / 2, ScrH() / 1.5 - (32 * (ScrH() / 480)) / 2)
			XP_UDS.Screen.Heart:SetSize(32 * (ScrH() / 480), 32 * (ScrH() / 480))
			XP_UDS.Screen.Heart:SetImageColor(XP_UDS.PlayerColor)


			XP_UDS.Screen.GameoverLogo = vgui.Create("DImage", XP_UDS.Screen)
			XP_UDS.Screen.GameoverLogo:SetImage("xp_uds/gameover")
			XP_UDS.Screen.GameoverLogo:SetPos(ScrW() / 2-(422 * (ScrH() / 480)) / 2, (32 * (ScrH() / 480)) / 2)
			XP_UDS.Screen.GameoverLogo:SetSize(422 * (ScrH() / 480), 182 * (ScrH() / 480) + 17 * (ScrH() / 480))
			XP_UDS.Screen.GameoverLogo:SetImageColor(Color( 255, 255, 255, 0 ))


			XP_UDS.Screen.qt = vgui.Create("DPanel", XP_UDS.Screen)
			XP_UDS.Screen.qt:SetPos(ScrW() / 2 - (240 * (ScrH() / 480)), ScrH() / 1.5)
			XP_UDS.Screen.qt:SetBackgroundColor(Color(255, 255, 255, 0))
			XP_UDS.Screen.qt:SetSize(640 * (ScrH() / 640), (480 * (ScrH() / 480)) / 1.5)
			XP_UDS.Screen.qt:SetWorldClicker(true)

			if xp_uds_name:GetString() and xp_uds_name:GetString() != "" then
				XP_UDS.FinalString = (xp_uds_name:GetString():gsub(".", "%1 "):sub(1, -2) or "C H A R A") .. " !\nS t a y    d e t e r m i n e d . . ."
			elseif LocalPlayer() then
				XP_UDS.FinalString = (LocalPlayer():GetName():gsub(".", "%1 "):sub(1, -2) or "C H A R A") .. " !\nS t a y    d e t e r m i n e d . . ."
			else
				XP_UDS.FinalString = "C H A R A !\nS t a y    d e t e r m i n e d . . ."
			end

			XP_UDS.Screen.TXT = vgui.Create("DLabel", XP_UDS.Screen.qt)
			XP_UDS.Screen.TXT:SetPos(160, 0)
			XP_UDS.Screen.TXT:SetText("")
			XP_UDS.Screen.TXT:SetTextColor( Color( 255, 255, 255, 255 ) )
			XP_UDS.Screen.TXT:SetFont("XP_UDS_MAIN")
			XP_UDS.Screen.TXT:SetSize(640 * (ScrH() / 640), 74 * (ScrH() / 480))

			XP_UDS.GameoverAnim = Derma_Anim("XP_UDS_GameoverAnim", XP_UDS.Screen.GameoverLogo, function(pnl, anim, delta, data)
				if data == "ON" then
					pnl:SetImageColor(Color(255, 255, 255, 255 * delta))
				elseif data == "OFF" then
					pnl:SetImageColor(Color(255, 255, 255, 255 - (255 * delta)))
				end
			end)

			XP_UDS.TXTAnim = Derma_Anim("XP_UDS_TXTAnim", XP_UDS.Screen.TXT, function(pnl, anim, delta, data)
				local lasttext = pnl:GetText()
				if data == "Flowey" then
					pnl:SetText(string.sub(XP_UDS.StringsFlowey[2], 0, math.Remap(delta, 0, 1, 0, #XP_UDS.StringsFlowey[2])))
					XP_UDS:Music("stop")
				elseif data == "END" then
					pnl:SetText(string.sub(XP_UDS.FinalString, 0, math.Remap(delta, 0, 1, 0, #XP_UDS.FinalString)))
				elseif xp_uds_special:GetInt() == 1 and XP_UDS.StringsFlowey then
					pnl:SetText(string.sub(XP_UDS.StringsFlowey[1], 0, math.Remap(delta, 0, 1, 0, #XP_UDS.StringsFlowey[1])))
				elseif xp_uds_special:GetInt() == 2 and XP_UDS.StringSans then
					pnl:SetText(string.sub(XP_UDS.StringSans, 0, math.Remap(delta, 0, 1, 0, #XP_UDS.StringSans)))
				elseif XP_UDS.Strings[data] then
					pnl:SetText(string.sub(XP_UDS.Strings[data], 0, math.Remap(delta, 0, 1, 0, #XP_UDS.Strings[data])))
				else
					local txt = "S o m e t h i n g    w e n t\nw r o n g . . ."
					pnl:SetText(string.sub(txt, 0, math.Remap(delta,0,1,0,#txt)))
				end
				if data == "Flowey" and pnl:GetText():gsub(" ", "") != lasttext:gsub(" ", "") then
					surface.PlaySound("xp_uds/000029f0.wav")
				elseif xp_uds_special:GetInt() == 2 and pnl:GetText():gsub(" ", "") != lasttext:gsub(" ", "") then
					surface.PlaySound("xp_uds/000029e6.wav")
				elseif pnl:GetText():gsub(" ", "") != lasttext:gsub(" ", "") then
					surface.PlaySound("xp_uds/000029e8.wav")
				end
			end)

			XP_UDS.TXTAnimC = Derma_Anim("XP_UDS_TXTAnimC", XP_UDS.Screen.TXT, function(pnl, anim, delta, data)
				pnl:SetTextColor(Color(255, 255, 255, 255 - (255 * delta)))
			end)

			timer.Create("XP_UDS_Heart", 0.2, 1, function()
				if IsValid(XP_UDS.Screen) then
					surface.PlaySound("xp_uds/00002a19.wav")
					XP_UDS.Screen.Heart:SetImage("xp_uds/heartbreak")
				end
			end)

			timer.Create("XP_UDS_GameoverSound", 1.2, 1, function()

				if IsValid(XP_UDS.Screen) then

					surface.PlaySound("xp_uds/00002a1a.wav")

					XP_UDS.Screen.Heart:Remove()
					XP_UDS.Screen.HeartShard_0 = vgui.Create("DImage", XP_UDS.Screen)
					XP_UDS.Screen.HeartShard_0:SetImage("xp_uds/heartshards")
					XP_UDS.Screen.HeartShard_0:SetPos(ScrW() / 2 - (8 * (ScrH() / 480)) / 1.5, ScrH() / 1.5 - (8 * (ScrH() / 480)))
					XP_UDS.Screen.HeartShard_0:SetSize(8 * (ScrH() / 480), 8 * (ScrH() / 480))
					XP_UDS.Screen.HeartShard_0:SetImageColor(XP_UDS.PlayerColor)
					XP_UDS.HeartShard_Anim_0 = Derma_Anim("XP_UDS_HeartShard_0", XP_UDS.Screen.HeartShard_0, function(pnl, anim, delta, data)
						pnl:SetPos(ScrW() / 2 - (8 * (ScrH() / 480)) / 1.5 - math.Remap(delta, 0, 1, 0, 480 * (ScrH() / 480)), ScrH() / 1.5 - (8 * (ScrH() / 480)) + math.Remap(delta ^ 6, 0 , 1, 0, 480 * (ScrH() / 480)))
					end)
					XP_UDS.HeartShard_Anim_0:Start(2.5)

					XP_UDS.Screen.HeartShard_1 = vgui.Create("DImage", XP_UDS.Screen)
					XP_UDS.Screen.HeartShard_1:SetImage("xp_uds/heartshards")
					XP_UDS.Screen.HeartShard_1:SetPos(ScrW() / 2 - (8 * (ScrH() / 480)) / 2, ScrH() / 1.5 - (8 * (ScrH() / 480)) / 2)
					XP_UDS.Screen.HeartShard_1:SetSize(8 * (ScrH() / 480), 8 * (ScrH() / 480))
					XP_UDS.Screen.HeartShard_1:SetImageColor(XP_UDS.PlayerColor)
					XP_UDS.HeartShard_Anim_1 = Derma_Anim("XP_UDS_HeartShard_1", XP_UDS.Screen.HeartShard_1, function(pnl, anim, delta, data)
						pnl:SetPos(ScrW() / 2 - (8 * (ScrH() / 480)) / 2 - math.Remap(delta, 0, 1, 0, 480 * (ScrH() / 480)), ScrH() / 1.5 - (8 * (ScrH() / 480)) / 2 + math.Remap(delta ^ 1.5, 0, 1, 0, 480 * (ScrH() / 480)))
					end)
					XP_UDS.HeartShard_Anim_1:Start(2.5)

					XP_UDS.Screen.HeartShard_2 = vgui.Create("DImage", XP_UDS.Screen)
					XP_UDS.Screen.HeartShard_2:SetImage("xp_uds/heartshards")
					XP_UDS.Screen.HeartShard_2:SetPos(ScrW() / 2 - (8 * (ScrH() / 480)) / 4, ScrH() / 1.5 - (8 * (ScrH() / 480)) / 6)
					XP_UDS.Screen.HeartShard_2:SetSize(8 * (ScrH() / 480), 8 * (ScrH() / 480))
					XP_UDS.Screen.HeartShard_2:SetImageColor(XP_UDS.PlayerColor)
					XP_UDS.HeartShard_Anim_2 = Derma_Anim("XP_UDS_HeartShard_2", XP_UDS.Screen.HeartShard_2, function(pnl, anim, delta, data)
						pnl:SetPos(ScrW() / 2 - (8 * (ScrH() / 480)) / 4 - math.Remap(delta, 0, 1, 0, 400), ScrH() / 1.5 - (8 * (ScrH() / 480)) / 6 + math.Remap(delta, 0, 1, 0, 480 * (ScrH() / 480)))
					end)
					XP_UDS.HeartShard_Anim_2:Start(2.5)

					XP_UDS.Screen.HeartShard_3 = vgui.Create("DImage", XP_UDS.Screen)
					XP_UDS.Screen.HeartShard_3:SetImage("xp_uds/heartshards")
					XP_UDS.Screen.HeartShard_3:SetPos(ScrW() / 2 + (8 * (ScrH() / 480)) / 1.5, ScrH() / 1.5 - (8 * (ScrH() / 480)))
					XP_UDS.Screen.HeartShard_3:SetSize(8 * (ScrH() / 480), 8 * (ScrH() / 480))
					XP_UDS.Screen.HeartShard_3:SetImageColor(XP_UDS.PlayerColor)
					XP_UDS.HeartShard_Anim_3 = Derma_Anim("XP_UDS_HeartShard_3", XP_UDS.Screen.HeartShard_3, function( pnl, anim, delta, data )
						pnl:SetPos(ScrW() / 2 + (8 * (ScrH() / 480)) / 1.5 + math.Remap(delta, 0, 1, 0, 480 * (ScrH() / 480)), ScrH() / 1.5 - (8 * (ScrH() / 480)) + math.Remap(delta ^ 4, 0, 1, 0, 480 * (ScrH() / 480)))
					end)
					XP_UDS.HeartShard_Anim_3:Start(2.5)

					XP_UDS.Screen.HeartShard_4 = vgui.Create("DImage", XP_UDS.Screen)
					XP_UDS.Screen.HeartShard_4:SetImage("xp_uds/heartshards")
					XP_UDS.Screen.HeartShard_4:SetPos(ScrW() / 2 + (8 * (ScrH() / 480)) / 2, ScrH() / 1.5 - (8 * (ScrH() / 480)) / 2)
					XP_UDS.Screen.HeartShard_4:SetSize(8 * (ScrH() / 480), 8 * (ScrH() / 480))
					XP_UDS.Screen.HeartShard_4:SetImageColor(XP_UDS.PlayerColor)
					XP_UDS.HeartShard_Anim_4 = Derma_Anim("XP_UDS_HeartShard_4", XP_UDS.Screen.HeartShard_4, function(pnl, anim, delta, data)
						pnl:SetPos(ScrW() / 2 + (8 * (ScrH() / 480)) / 2 + math.Remap(delta, 0, 1, 0, 480 * (ScrH() / 480)), ScrH() / 1.5 - (8 * (ScrH() / 480)) / 2 + math.Remap(delta ^ 1.25, 0, 1, 0, 480 * (ScrH() / 480)))
					end)
					XP_UDS.HeartShard_Anim_4:Start(2.5)

					XP_UDS.Screen.HeartShard_5 = vgui.Create("DImage", XP_UDS.Screen)
					XP_UDS.Screen.HeartShard_5:SetImage("xp_uds/heartshards")
					XP_UDS.Screen.HeartShard_5:SetPos(ScrW() / 2 + (8 * (ScrH() / 480)) / 4, ScrH() / 1.5 - (8 * (ScrH() / 480)) / 6)
					XP_UDS.Screen.HeartShard_5:SetSize(8 * (ScrH() / 480), 8 * (ScrH() / 480))
					XP_UDS.Screen.HeartShard_5:SetImageColor(XP_UDS.PlayerColor)
					XP_UDS.HeartShard_Anim_5 = Derma_Anim("XP_UDS_HeartShard_5", XP_UDS.Screen.HeartShard_5, function(pnl, anim, delta, data)
						pnl:SetPos(ScrW() / 2 + (8 * (ScrH() / 480)) / 4 + math.Remap(delta, 0, 1, 0, 400), ScrH() / 1.5 - (8 * (ScrH() / 480)) / 6 + math.Remap(delta, 0, 1, 0, 480 * (ScrH() / 480)))
					end)
					XP_UDS.HeartShard_Anim_5:Start(2.5)

				end

			end)

			timer.Create( "XP_UDS_GameoverAnimTimer", 2.5, 1, function()
				if IsValid(XP_UDS.Screen) and xp_uds_special:GetInt() == 2 and !XP_UDS.Screen.Ending then
					XP_UDS.GameoverAnim:Start(3, "ON")
					XP_UDS:Music(XP_UDS.Musics.dogsong)
				elseif IsValid(XP_UDS.Screen) and !XP_UDS.Screen.Ending then
					XP_UDS.GameoverAnim:Start(3, "ON")
					XP_UDS:Music(XP_UDS.Musics.gameover)
				elseif IsValid(XP_UDS.Screen) then
					XP_UDS:Music(XP_UDS.Musics.gameover)
				end
			end)

			timer.Create( "XP_UDS_GameoverAnimTXT", 4.5, 1, function()
				if IsValid(XP_UDS.Screen) and !XP_UDS.Screen.Ending then
					local rand = math.random(1, #XP_UDS.Strings)
					XP_UDS.TXTAnim:Start(2,rand)
				end
			end)

			timer.Create( "XP_UDS_GameoverAnimTXT2", 8, 1, function()
				if IsValid(XP_UDS.Screen) and !XP_UDS.Screen.Ending and xp_uds_special:GetInt() != 2 then
					if xp_uds_special:GetInt() == 1 then
						XP_UDS.TXTAnim:Start(3,"Flowey")
					else
						XP_UDS.TXTAnim:Start(2,"END")
					end
				end
			end)

		end

	end

	function XP_UDS:Music(src)

		if IsValid(XP_UDS.CurMusic) and src == "play" then
			XP_UDS.CurMusic:Play()
		elseif IsValid(XP_UDS.CurMusic) and src == "pause" then
			XP_UDS.CurMusic:Pause()
		elseif IsValid(XP_UDS.CurMusic) then
			XP_UDS.CurMusic:Stop()
			XP_UDS.CurMusic = nil
		end

		if src != "stop" and src != "pause" and src != "play" then

			local function domusicstuff(mus, errorID, errorName)

				if IsValid(mus) then
					mus:SetVolume(1)
					mus:EnableLooping(true)
					XP_UDS.CurMusic = mus
				end

				if errorID or errorName then
					Error("Error while starting music \"" .. src .. "\": " .. errorName .. " (" .. errorID .. ")\n")
				end

			end

			sound.PlayFile("sound/" .. src, "noblock", domusicstuff)

		end

	end

	MsgC(Color(255, 255, 85), "XP_UDS V" .. ver .. " loaded! (CL)\n")

end
