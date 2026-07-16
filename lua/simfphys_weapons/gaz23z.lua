local function mg_fire(ply,vehicle,shootOrigin,shootDirection)

	vehicle:EmitSound("apc_fire")
	
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 20000, shootOrigin ) 
	
	local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.Damage = 50
		projectile.Force = 50
		projectile.Size = 3
		projectile.BlastRadius = 50
		projectile.BlastDamage = 25
		projectile.DeflectAng = 40
		projectile.BlastEffect = "simfphys_tankweapon_explosion_micro"
	
	simfphys.FirePhysProjectile( projectile )
end

function simfphys.weapon:ValidClasses()
	
	local classes = {
		"gaz66"
	}
	
	return classes
end

function simfphys.weapon:Initialize( vehicle )
	vehicle:SetNWBool( "SpecialCam_Loader", true )
	vehicle:SetNWFloat( "SpecialCam_LoaderTime", 5 )
	
	local data = {}
	data.Attachment = "muzzle_left"
	data.Direction = Vector(1,0,0)
	data.Attach_Start_Left = "muzzle_right"
	data.Attach_Start_Right = "muzzle_left"
	data.Type = 0



	vehicle.MaxMag = 250
	vehicle:SetNWString( "WeaponMode", tostring( vehicle.MaxMag ) )
	
    simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), data )  
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), Vector(0,-15,10), Vector(-17,-25,60), true )
	
	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	for i = 1, table.Count( vehicle.pSeat ) do
		simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = "muzzle_left", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], Vector(-25,140,20), Vector(-25,120,70), true )
	end
end

function simfphys.weapon:AimWeapon( ply, vehicle, pod )	
	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	local AimRate = 70
	
	local Angles = vehicle:WorldToLocalAngles( Aimang ) - Angle(0,90,0)
	
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p, AimRate * FrameTime() ) or 0
	
	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize() 
	
	vehicle:SetPoseParameter("turret_yaw", TargetAng.y )
	vehicle:SetPoseParameter("turret_pitch", -TargetAng.p )
end

function simfphys.weapon:Think( vehicle )
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
	
	local curtime = CurTime()
	
	if not IsValid( ply ) then 
		if vehicle.wpn then
			vehicle.wpn:Stop()
			vehicle.wpn = nil
		end
		
		return
	end
	
	self:AimWeapon( ply, vehicle, pod )
	
	local fire = ply:KeyDown( IN_ATTACK )
	local reload = ply:KeyDown( IN_RELOAD )
	
	if fire then
		self:PrimaryAttack( vehicle, ply, shootOrigin )
	end
	
	if reload then
		self:ReloadPrimary( vehicle )
	end
end

function simfphys.weapon:ReloadPrimary( vehicle )
	if not IsValid( vehicle ) then return end
	if vehicle.CurMag == vehicle.MaxMag then return end
	
	vehicle.CurMag = vehicle.MaxMag
	
	vehicle:EmitSound("simulated_vehicles/weapons/apc_reload.wav")
	
	self:SetNextPrimaryFire( vehicle, CurTime() + 6 )
	
	vehicle:SetNWString( "WeaponMode", tostring( vehicle.CurMag ) )
	
	vehicle:SetIsCruiseModeOn( false )
end

function simfphys.weapon:TakePrimaryAmmo( vehicle )
	vehicle.CurMag = isnumber( vehicle.CurMag ) and vehicle.CurMag - 1 or vehicle.MaxMag
	
	vehicle:SetNWString( "WeaponMode", tostring( vehicle.CurMag ) )
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.CurMag = isnumber( vehicle.CurMag ) and vehicle.CurMag or vehicle.MaxMag
	
	if vehicle.CurMag <= 0 then
		self:ReloadPrimary( vehicle )
		return false
	end
	
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time
end

function simfphys.weapon:PrimaryAttack( vehicle, ply )
	if not self:CanPrimaryAttack( vehicle ) then return end
	
	vehicle.wOldPos = vehicle.wOldPos or vehicle:GetPos()
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	
	if vehicle.swapMuzzle then
		vehicle.swapMuzzle = false
	else
		vehicle.swapMuzzle = true
	end
	
	local AttachmentID = vehicle.swapMuzzle and vehicle:LookupAttachment( "muzzle_right" ) or vehicle:LookupAttachment( "muzzle_left" )
	local Attachment = vehicle:GetAttachment( AttachmentID )
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootDirection = Attachment.Ang:Forward()
	
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment( AttachmentID )
		effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash", effectdata, true, true )
	
	mg_fire( ply, vehicle, shootOrigin, shootDirection )
	
	self:TakePrimaryAmmo( vehicle )
	
	self:SetNextPrimaryFire( vehicle, CurTime() + 0.04 )
end
