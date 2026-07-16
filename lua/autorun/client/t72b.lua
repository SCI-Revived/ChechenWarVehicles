local next_think = 0
local next_find = 0
local t72bs = {}



local function 	t72bsGetAll()
	local t72bs_tanks = {}
	
	for i, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
		local class = ent:GetSpawn_List()
		
		if class == "sim_fphys_tank" then
			table.insert(t72bs_tanks, ent)
		end
	end
	
	return t72bs_tanks 
end




local function GetTrackPos( ent, div, smoother )
	local FT =  FrameTime()
	local spin_left = ent.trackspin_l and (-ent.trackspin_l / div) or 0
	local spin_right = ent.trackspin_r and (-ent.trackspin_r / div) or 0
	ent.sm_TrackDelta_L = ent.sm_TrackDelta_L and (ent.sm_TrackDelta_L + (spin_left - ent.sm_TrackDelta_L) * smoother) or 0
	ent.sm_TrackDelta_R = ent.sm_TrackDelta_R and (ent.sm_TrackDelta_R + (spin_right - ent.sm_TrackDelta_R) * smoother) or 0

	return {Left = ent.sm_TrackDelta_L,Right = ent.sm_TrackDelta_R}
	
end


local function Updatet72bScrollTexture( ent )
	local id = ent:EntIndex()

	if not ent.wheel_left_mat then
		ent.wheel_left_mat = CreateMaterial("t72b_trackmat_"..id.."_left", "VertexLitGeneric", 
		{ ["$basetexture"] = "models/t72_b/tr",

											
		["$alphatest"] 					= "1",
		["$nocull"] 					= "1",
				
		["$phong"] 						= "1",
		["$phongboost"] 				= "3",
		["$phongexponent"] 				= "15",
		["$phongfresnelranges"] 		= "[0.3 1 4]",
		["$translate"] = "[0.0 0.0 0.0]",
		["Proxies"] =
		{ ["TextureTransform"] = 
		{ ["translateVar"] = "$translate", ["centerVar"]    = "$center",["resultVar"]    = "$basetexturetransform", } } } )
	end

	if not ent.wheel_right_mat then
		ent.wheel_right_mat = CreateMaterial("t72b_trackmat_"..id.."_right", "VertexLitGeneric", 
		{ ["$basetexture"] = "models/t72_b/tr",
											
		["$alphatest"] 					= "1",
		["$nocull"] 					= "1",
				
		["$phong"] 						= "1",
		["$phongboost"] 				= "3",
		["$phongexponent"] 				= "15",
		["$phongfresnelranges"] 		= "[0.3 1 4]",
		["$translate"] = "[0.0 0.0 0.0]",
		["Proxies"] =
		{ ["TextureTransform"] = 
		{ ["translateVar"] = "$translate", ["centerVar"]    = "$center",["resultVar"]    = "$basetexturetransform", } } } )
	end
	
	
	local TrackPos = GetTrackPos( ent, 70, 0.5 )
	--движение
	ent.wheel_left_mat:SetVector("$translate", Vector(0,TrackPos.Left,0) )
	ent.wheel_right_mat:SetVector("$translate", Vector(0,TrackPos.Right,0) )
	
--сдесь накладывается текстура на каккой либо объект (ent:SetSubMaterial( "выбор объекта", "!t26_trackmat_"..id.."выбор текстуры" ) )
	ent:SetSubMaterial( 2, "!t72b_trackmat_"..id.."_left" ) 
	ent:SetSubMaterial( 2, "!t72b_trackmat_"..id.."_right" )
end

local function UpdateTracks()
	if t72bs then
		for index, ent in pairs( t72bs ) do
			if IsValid( ent ) then
				Updatet72bScrollTexture( ent )
			else
				t72bs[index] = nil
			end
		end
	end
	
end

net.Receive( "t72b_register_tank", function( length )
	local tank = net.ReadEntity()
	local type = net.ReadString()
	
	if not IsValid( tank ) then return end
	
	if type == "t72b" then
		table.insert(t72bs, tank)	
	
	end
end)

net.Receive( "t72b_update_tracks", function( length )
	local tank = net.ReadEntity()
	if not IsValid( tank ) then return end
	
	tank.trackspin_r = net.ReadFloat() 
	tank.trackspin_l = net.ReadFloat() 
	
end)

local NumCycl = 0
hook.Add( "Think", "t72b_manage_tanks", function()
	local curtime = CurTime()
	
	if curtime > next_find then
		next_find = curtime + 30
		
		NumCycl = NumCycl + 1
		if NumCycl == 1 then
			t72bs = t72bsGetAll()
			
		end
	end
	
	
	if curtime > next_think then
		next_think = curtime + 0.02
		
		UpdateTracks()
	end 
end)