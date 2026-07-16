local next_think = 0
local next_find = 0
local mt1s = {}



local function 	mt1sGetAll()
	local mt1s_tanks = {}
	
	for i, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
		local class = ent:GetSpawn_List()
		
		if class == "sim_fphys_tank" then
			table.insert(mt1s_tanks, ent)
		end
	end
	
	return mt1s_tanks 
end




local function GetTrackPos( ent, div, smoother )
	local FT =  FrameTime()
	local spin_left = ent.trackspin_l and (-ent.trackspin_l / div) or 0
	local spin_right = ent.trackspin_r and (-ent.trackspin_r / div) or 0
	ent.sm_TrackDelta_L = ent.sm_TrackDelta_L and (ent.sm_TrackDelta_L + (spin_left - ent.sm_TrackDelta_L) * smoother) or 0
	ent.sm_TrackDelta_R = ent.sm_TrackDelta_R and (ent.sm_TrackDelta_R + (spin_right - ent.sm_TrackDelta_R) * smoother) or 0

	return {Left = ent.sm_TrackDelta_L,Right = ent.sm_TrackDelta_R}
	
end


local function Updatemt1ScrollTexture( ent )
	local id = ent:EntIndex()

	if not ent.wheel_left_mat then
		ent.wheel_left_mat = CreateMaterial("mt1_trackmat_"..id.."_left", "VertexLitGeneric", 
		{ ["$basetexture"] = "models/mb/tr",

											
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
		ent.wheel_right_mat = CreateMaterial("mt1_trackmat_"..id.."_right", "VertexLitGeneric", 
		{ ["$basetexture"] = "models/mb/tr",
											
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
	ent:SetSubMaterial( 1, "!mt1_trackmat_"..id.."_right" ) 
	ent:SetSubMaterial( 2, "!mt1_trackmat_"..id.."_left" )
end

local function UpdateTracks()
	if mt1s then
		for index, ent in pairs( mt1s ) do
			if IsValid( ent ) then
				Updatemt1ScrollTexture( ent )
			else
				mt1s[index] = nil
			end
		end
	end
	
end

net.Receive( "mt1_register_tank", function( length )
	local tank = net.ReadEntity()
	local type = net.ReadString()
	
	if not IsValid( tank ) then return end
	
	if type == "mt1" then
		table.insert(mt1s, tank)	
	
	end
end)

net.Receive( "mt1_update_tracks", function( length )
	local tank = net.ReadEntity()
	if not IsValid( tank ) then return end
	
	tank.trackspin_r = net.ReadFloat() 
	tank.trackspin_l = net.ReadFloat() 
	
end)

local NumCycl = 0
hook.Add( "Think", "mt1_manage_tanks", function()
	local curtime = CurTime()
	
	if curtime > next_find then
		next_find = curtime + 30
		
		NumCycl = NumCycl + 1
		if NumCycl == 1 then
			mt1s = mt1sGetAll()
			
		end
	end
	
	
	if curtime > next_think then
		next_think = curtime + 0.02
		
		UpdateTracks()
	end 
end)