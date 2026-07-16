local mt2_susdata = {}
for i = 1,8 do
	mt2_susdata[i] = { 
		attachment = "vehicle_suspension_l_"..i,
		poseparameter = "suspension_left_"..i,
	}
	
	local ir = i + 8
	mt2_susdata[ir] = { 
		attachment = "vehicle_suspension_r_"..i,
		poseparameter = "suspension_right_"..i,
	}
end

local function hmg_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("tiger_fire_mg")
	
	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.Spread = Vector(0.01,0.01,0.01)
		projectile.HullSize = 5
		projectile.attackingent = vehicle
		projectile.Damage = 20
		projectile.Force = 12
	simfphys.FireHitScan( projectile )
end

local function mg_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("sherman_fire")
	vehicle:EmitSound("tiger_reload")
	
	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "simfphys_leopard_muzzle", effectdata )
	
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 100000, shootOrigin ) 
	
	 local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.Damage = 1500
		projectile.Force = 8000
		projectile.Size = 10
		projectile.DeflectAng = 1
		projectile.BlastRadius = 500
		projectile.BlastDamage = 5000
		projectile.MuzzleVelocity = 65
		projectile.BlastEffect = "simfphys_tankweapon_explosion"
	
	AVX.FirePhysProjectile( projectile )
end

local function cannon_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("tiger_fire_mg")
	
	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.Tracer	= 1
		projectile.Spread = Vector(0.015,0.015,0.015)
		projectile.HullSize = 5
		projectile.attackingent = vehicle
		projectile.Damage = 20
		projectile.Force = 12
	simfphys.FireHitScan( projectile )
end

local function Hcannon_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("sherman_fire")
	vehicle:EmitSound("tiger_reload")
	
	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "simfphys_leopard_muzzle", effectdata )
	
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 290000, shootOrigin ) 
	
    local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.Damage = 10200
		projectile.Force = 8000
		projectile.Size = 23
		projectile.DeflectAng = 1
		projectile.BlastRadius = 1000
		projectile.BlastDamage = 10000
		projectile.MuzzleVelocity = 48
		projectile.BlastEffect = "simfphys_tankweapon_explosion"
	
	AVX.FirePhysProjectile( projectile )
end

function simfphys.weapon:ValidClasses()
	
	local classes = {
		"mt2"
	}
	
	return classes
end

function simfphys.weapon:Initialize( vehicle )
   net.Start( "mt2_register_tank" )
		net.WriteEntity( vehicle )
		net.WriteString( "mt2" )
	net.Broadcast()
	vehicle:SetNWBool( "SpecialCam_Loader", true )
	vehicle:SetNWFloat( "SpecialCam_LoaderTime", 5 )
	
	simfphys.RegisterCrosshair( vehicle.pSeat[1], { Direction = Vector(0,0,1), Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(-5,-6,-15), Vector(0,60,75), true, "muzzle" )
	
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(20,-50,5), Vector(0,50,70), false )
	simfphys.RegisterCamera( vehicle.pSeat[2], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[3], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[4], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[5], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[6], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[7], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[8], Vector(0,0,25), Vector(0,0,25), false )
	simfphys.RegisterCamera( vehicle.pSeat[9], Vector(0,0,25), Vector(0,0,25), false )
	
	timer.Simple( 1, function()
		if not IsValid( vehicle ) then return end
		if not vehicle.VehicleData["filter"] then print("[simfphys Armed Vehicle Pack] ERROR:TRACE FILTER IS INVALID. PLEASE UPDATE SIMFPHYS BASE") return end
		
		vehicle.WheelOnGround = function( ent )
			ent.FrontWheelPowered = ent:GetPowerDistribution() ~= 1
			ent.RearWheelPowered = ent:GetPowerDistribution() ~= -1
			
			for i = 1, table.Count( ent.Wheels ) do
				local Wheel = ent.Wheels[i]		
				if IsValid( Wheel ) then
					local dmgMul = Wheel:GetDamaged() and 0.5 or 1
					local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]
					
					ent.VehicleData[ "SurfaceMul_" .. i ] = (surfacemul and math.max(surfacemul,0.001) or 1) * dmgMul
					
					local WheelPos = ent:LogicWheelPos( i )
					
					local WheelRadius = WheelPos.IsFrontWheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local startpos = Wheel:GetPos()
					local dir = -ent.Up
					local len = WheelRadius + math.Clamp(-ent.Vel.z / 50,2.5,6)
					local HullSize = Vector(WheelRadius,WheelRadius,0)
					local tr = util.TraceHull( {
						start = startpos,
						endpos = startpos + dir * len,
						maxs = HullSize,
						mins = -HullSize,
						filter = ent.VehicleData["filter"]
					} )
					
					local onground = self:IsOnGround( vehicle ) and 1 or 0
					Wheel:SetOnGround( onground )
					ent.VehicleData[ "onGround_" .. i ] = onground
					
					if tr.Hit then
						Wheel:SetSpeed( Wheel.FX )
						Wheel:SetSkidSound( Wheel.skid )
						Wheel:SetSurfaceMaterial( util.GetSurfacePropName( tr.SurfaceProps ) )
					end
				end
			end
			
			local FrontOnGround = math.max(ent.VehicleData[ "onGround_1" ],ent.VehicleData[ "onGround_2" ])
			local RearOnGround = math.max(ent.VehicleData[ "onGround_3" ],ent.VehicleData[ "onGround_4" ])
			
			ent.DriveWheelsOnGround = math.max(ent.FrontWheelPowered and FrontOnGround or 0,ent.RearWheelPowered and RearOnGround or 0)
		end
	end)
end

function simfphys.weapon:ControlTurret( vehicle, deltapos )
	local pod = vehicle.pSeat[1]
	
	if not IsValid( pod ) then return end
	
	local ply = pod:GetDriver()
	
	if not IsValid( ply ) then return end
	
	local safemode = ply:KeyDown( IN_WALK )

	if vehicle.ButtonSafeMode ~= safemode then
		vehicle.ButtonSafeMode = safemode
		
		if safemode then
			vehicle:SetNWBool( "TurretSafeMode", not vehicle:GetNWBool( "TurretSafeMode", true ) )
		end
	end
	
	if vehicle:GetNWBool( "TurretSafeMode", true ) then return end
	
	local ID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( ID )
	
	self:AimCannon( ply, vehicle, pod, Attachment )
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	
	local fire = ply:KeyDown( IN_ATTACK )
	
		--перезарядка орудия---
	local change =ply:KeyDown( IN_RELOAD)
	vehicle.FireMode = vehicle.FireMode or 0
			if vehicle.FireMode >= 2 then
				vehicle.FireMode = 0
			end


	if fire then
		self:SecondaryAttack( vehicle, ply, shootOrigin - Attachment.Ang:Up() * 0 - Attachment.Ang:Forward() * 0 , Attachment.Ang )
	end
	
	local Rate = FrameTime() / 8
	vehicle.smTmpHMG = vehicle.smTmpHMG and vehicle.smTmpHMG + math.Clamp((fire2 and 1 or 0) - vehicle.smTmpHMG,-Rate * 4,Rate) or 0
	
	if fire2 then
		self:TurretAttack( vehicle, ply, vehicle:GetAttachment( vehicle:LookupAttachment( "turret" ) ).Pos + deltapos * engine.TickInterval(), Attachment, vehicle:LookupAttachment( "turret" ))
	end
end

function simfphys.weapon:ControlMachinegun( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	local pod = vehicle.pSeat[1]
	
	if not IsValid( pod ) then return end
	
	local ply = pod:GetDriver()
	
	if not IsValid( ply ) then return end
	
	self:AimMachinegun( ply, vehicle, pod )
	
	local ID = vehicle:LookupAttachment( "muzzle_machinegun" )
	local Attachment = vehicle:GetAttachment( ID )

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	
	local fire = ply:KeyDown( IN_ATTACK )

	local Rate = FrameTime() / 8
	vehicle.smTmpMG = vehicle.smTmpMG and vehicle.smTmpMG + math.Clamp((fire and 1 or 0) - vehicle.smTmpMG,-Rate * 4,Rate) or 0
	
	if fire then
		self:TertiaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	end
end

function simfphys.weapon:GetForwardSpeed( vehicle )
	return vehicle.ForwardSpeed
end

function simfphys.weapon:IsOnGround( vehicle )
	return (vehicle.susOnGround == true)
end

function simfphys.weapon:ModPhysics( vehicle, wheelslocked )
	if wheelslocked and self:IsOnGround( vehicle ) then
		local phys = vehicle:GetPhysicsObject()
		phys:ApplyForceCenter( -vehicle:GetVelocity() * phys:GetMass() * 0.04 )
	end
end

function simfphys.weapon:ControlTrackSounds( vehicle, wheelslocked ) 
	local speed = math.abs( self:GetForwardSpeed( vehicle ) )
	local fastenuf = speed > 20 and not wheelslocked and self:IsOnGround( vehicle )
	
	if fastenuf ~= vehicle.fastenuf then
		vehicle.fastenuf = fastenuf
		
		if fastenuf then
			vehicle.track_snd = CreateSound( vehicle, "simulated_vehicles/sherman/tracks.wav" )
			vehicle.track_snd:PlayEx(0,0)
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if vehicle.track_snd then
					vehicle.track_snd:Stop()
				end
			end)
		else
			if vehicle.track_snd then
				vehicle.track_snd:Stop()
				vehicle.track_snd = nil
			end
		end
	end
	
	if vehicle.track_snd then
		vehicle.track_snd:ChangePitch( math.Clamp(60 + speed / 80,0,150) ) 
		vehicle.track_snd:ChangeVolume( math.min( math.max(speed - 20,0) / 600,1) ) 
	end
end


function simfphys.weapon:Think( vehicle )
	if not IsValid( vehicle ) or not vehicle:IsInitialized() then return end
	
	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	
	local handbrake = vehicle:GetHandBrakeEnabled()
	
	self:UpdateSuspension( vehicle )
	self:DoWheelSpin( vehicle )
	self:ControlTurret( vehicle, deltapos )
	self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )
	local trackss
	local gear = vehicle:GetGear()
    local mass = vehicle:GetPhysicsObject():GetMass()
    local TrackTurnRate = 30
    local TrackMultRate = 60
    local AntiFrictionRate = 0.1
    trackss= CreateSound( vehicle, "simulated_vehicles/sherman/tracks.wav")
	if vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["A"] == true and vehicle.susOnGround == true then
        if vehicle:GetPhysicsObject():GetAngleVelocity().z <= TrackTurnRate then
            vehicle:GetPhysicsObject():ApplyTorqueCenter( Vector(0,0, mass * TrackMultRate ))
            vehicle:GetPhysicsObject():ApplyForceCenter( Vector( 0,0, mass * AntiFrictionRate ))
			trackss:Play()
			trackss:ChangePitch( math.Clamp(50+TrackTurnRate / 80,0,150) ) 
			trackss:ChangeVolume( math.min( math.max(222 - 20,0) / 600,1) ) 
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if trackss then
					trackss:Stop()
				end
			end)
        end
    elseif vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["A"] == false and vehicle.susOnGround == false then
		trackss:Stop()
    end
    if vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["D"] == true and vehicle.susOnGround == true then
        if math.abs(vehicle:GetPhysicsObject():GetAngleVelocity().z) <= TrackTurnRate then
            vehicle:GetPhysicsObject():ApplyTorqueCenter( Vector(0,0, -mass * TrackMultRate  ))
            vehicle:GetPhysicsObject():ApplyForceCenter( Vector( 0,0, mass * AntiFrictionRate ))
			trackss:Play()
			trackss:ChangePitch( math.Clamp(50+TrackTurnRate / 80,0,150) ) 
			trackss:ChangeVolume( math.min( math.max(222 - 20,0) / 600,1) ) 
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if trackss then
					trackss:Stop()
				end
			end)
        end
    elseif vehicle:EngineActive() and gear == 2 and vehicle.PressedKeys["D"] == false and vehicle.susOnGround == false then
		trackss:Stop()
	end	
	
	if vehicle:WaterLevel()==3 then
	vehicle:StopEngine()
	end
end

function simfphys.weapon:PrimaryAttackreload( vehicle, ply, shootOrigin, Attachment )
	--if not self:CanPrimaryAttack2( vehicle ) then return end
		if self:CanPrimaryAttack( vehicle ) then
			local shootDirection = Attachment.Ang:Forward()
			cannon_firereload(vehicle)	
			--cannon_firereload2(vehicle)
			self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
		elseif self:CanPrimaryAttack2 ( vehicle ) then
			local shootDirection = Attachment.Ang:Forward()	
			cannon_firereload2(vehicle)
			self:SetNextPrimaryFire2( vehicle, CurTime() + 1 )
			self:SetNextPrimaryFire( vehicle, CurTime() + 4.5 )
		end
end
function simfphys.weapon:SetNextPrimaryFire2( vehicle, time )
	vehicle.NextShootR = time
	vehicle:SetNWFloat( "SpecialCam_LoaderNext", time )
end
function simfphys.weapon:CanPrimaryAttack2( vehicle )
	vehicle.NextShootR = vehicle.NextShootR or 0
	return vehicle.NextShootR < CurTime()
end

local reloudsmg=0
local reloudf=0
local relouds=0

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )
	if not self:CanPrimaryAttack( vehicle ) then return end
	
	cannon_fire( ply, vehicle, shootOrigin, Attachment.Ang:Up() )
	
	if reloudsmg<101 then
		mg_fire( ply, vehicle, Attachment.Pos, (Attachment.Ang - Angle(0,0.5,0)):Forward())
		self:SetNextPrimaryFire( vehicle, CurTime() + 0.04 )
	else
		vehicle:EmitSound("pz2/mgun_reload_01.wav")
		reloudsmg=0
		self:SetNextPrimaryFire( vehicle, CurTime() + 13)
	end
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, shootDir )
	
	if not self:CanSecondaryAttack( vehicle ) then return end

	hmg_fire( ply, vehicle, shootOrigin, (shootDir + Angle(0,0.5,0)):Up() )
	
	self:SetNextSecondaryFire( vehicle, CurTime() + 0.08 + (vehicle.smTmpHMG ^ 5) * 0.08 )
end

function simfphys.weapon:TertiaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	if not self:CanPrimaryAttack( vehicle ) then return end
	
	local shootDirection = Attachment.Ang:Forward()
	vehicle:PlayAnimation( "fire" )	
	mg_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	--дым после выстрела
	local effectdata = EffectData()
		effectdata:SetEntity( vehicle )
	util.Effect( "", effectdata, true, true )
	relouds=relouds+1
	if relouds<4 then
	self:SetNextPrimaryFire( vehicle, CurTime() + 0.2)
	else
		vehicle:EmitSound("tiger_reload")
		relouds=0
		self:SetNextPrimaryFire( vehicle, CurTime() + 5)
	end
end

function simfphys.weapon:AimMachinegun( ply, vehicle, pod )	
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	
	local Angles = vehicle:WorldToLocalAngles( Aimang )
	Angles:Normalize()
	
	local TargetPitch = Angles.p
	local TargetYaw = Angles.y
	
	vehicle:SetPoseParameter("machinegun_yaw", -TargetYaw )
	vehicle:SetPoseParameter("machinegun_pitch", TargetPitch )
end

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )	
	if not IsValid( pod ) then return end
	
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	
	local AimRate = 25
	
	local Angles = vehicle:WorldToLocalAngles( Aimang )
	
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0
	
	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize() 

	vehicle:SetPoseParameter("turret_yaw", TargetAng.y )
	vehicle:SetPoseParameter("turret_pitch", TargetAng.p )
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:CanTertiaryAttack( vehicle )
	vehicle.NextShoot3 = vehicle.NextShoot3 or 0
	return vehicle.NextShoot3 < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
	vehicle:SetNWFloat( "SpecialCam_LoaderNext", time )
end

function simfphys.weapon:SetNextSecondaryFire( vehicle, time )
	vehicle.NextShoot2 = time
end

function simfphys.weapon:SetNextTertiaryFire( vehicle, time )
	vehicle.NextShoot3 = time
end

function simfphys.weapon:UpdateSuspension( vehicle )
	if not vehicle.filterEntities then
		vehicle.filterEntities = player.GetAll()
		table.insert(vehicle.filterEntities, vehicle)
		
		for i, wheel in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_wheel" ) ) do
			table.insert(vehicle.filterEntities, wheel)
		end
	end
	
	vehicle.oldDist = istable( vehicle.oldDist ) and vehicle.oldDist or {}
	
	vehicle.susOnGround = false
	
	for i, v in pairs( mt2_susdata ) do
		local pos = vehicle:GetAttachment( vehicle:LookupAttachment( mt2_susdata[i].attachment ) ).Pos
		
		local trace = util.TraceHull( {
			start = pos,
			endpos = pos + vehicle:GetUp() * - 100,
			maxs = Vector(15,15,0),
			mins = -Vector(15,15,0),
			filter = vehicle.filterEntities,
		} )
		local Dist = (pos - trace.HitPos):Length() - 41
		
		if trace.Hit then
			vehicle.susOnGround = true
		end
		
		vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-5,1)) or 0
		
		vehicle:SetPoseParameter(mt2_susdata[i].poseparameter, vehicle.oldDist[i] )
	end
end

function simfphys.weapon:DoWheelSpin( vehicle )
	local spin_r = vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ]
	local spin_l = vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ]
	
	vehicle:SetPoseParameter("spin_wheels_right", spin_r)
	vehicle:SetPoseParameter("spin_wheels_left", spin_l )
	
	net.Start( "mt2_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r ) 
		net.WriteFloat( spin_l ) 
	net.Broadcast()
end