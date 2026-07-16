
local light_table = {
	L_HeadLampPos = Vector(-64,140,53.5),Vector(-58,140,53.5),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(64,140,53.5),Vector(58,140,53.5),
	R_HeadLampAng = Angle(15,90,0),
	
	Headlight_sprites = { 
		Vector(-35,123,44),Vector(-35,123,44),
		Vector(35,123,44),Vector(35,123,44),
	},
	
}
list.Set( "simfphys_lights", "t80", light_table)

local V = {
	Name = "T-80U",
	Model = "models/t80.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "SIMER Cold War",
	SpawnOffset = Vector(0,0,30),
	SpawnAngleOffset = -90,

	Members = {
		Mass = 8000,
		AirFriction = 0,
		Inertia = Vector(10000,30000,50000),
		
		LightsTable = "t80",
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", false ) 
			end,

		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,
		
		OnDestroyed =
			function(ent)
				if IsValid( ent.Gib ) then
					ent.Gib:PhysicsInit(6)
					ent.Gib:SetCollisionGroup(0)
					local yaw = ent.sm_pp_yaw or 0
					local pitch = ent.sm_pp_pitch or 0
					ent.Gib:SetPoseParameter("cannon_aim_yaw", yaw )
					ent.Gib:SetPoseParameter("cannon_aim_pitch", -pitch )
				end
			end,
		
		MaxHealth = 22000,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,-50,50),
		
		FrontWheelRadius = 29,
		RearWheelRadius = 29,
		
		EnginePos = Vector(0,-125.72,69.45),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		
		CustomWheelPosFL = Vector(-65,132,32),
		CustomWheelPosFR = Vector(65,132,32),
		CustomWheelPosML = Vector(-65,10,32),
		CustomWheelPosMR = Vector(65,10,32),
		CustomWheelPosRL = Vector(-65,-120,32),
		CustomWheelPosRR = Vector(65,-120,32),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,8),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(30,0,39),
		SeatPitch = -15,
		SeatYaw = 0,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-0,-155,46),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(0,-155,46),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(-10,-155,46),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(10,-155,46),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(-15,-155,46),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(15,-155,46),
				ang = Angle(90,-90,0)
			},
			
		},

		
		PassengerSeats = {
			{
				pos = Vector(24,-24,52),
				ang = Angle(0,0,0)
			},
		},
		
		FrontHeight = 19,
		FrontConstant = 50000,
		FrontDamping = 8000,
		FrontRelativeDamping = 40000,

		RearHeight = 19,
		RearConstant = 50000,
		RearDamping = 8000,
		RearRelativeDamping = 40000,

		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 6,
		
	    MaxGrip = 800,
		Efficiency = 0.42,
		GripOffset = -300,
		BrakePower = 100,
		BulletProofTires = true,
		
		IdleRPM = 350,
		LimitRPM = 5000,
		PeakTorque = 250,
		PowerbandStart = 1000,
		PowerbandEnd = 5500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-34,0,72),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 90,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/leopard/start.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/sherman/low.wav",
		Sound_MidPitch = 1.3,
		Sound_MidVolume = 0.75,
		Sound_MidFadeOutRPMpercent = 50,
		Sound_MidFadeOutRate = 0.85,
		
		Sound_High = "simulated_vehicles/sherman/high.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 20,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.05,0.08,0.11,0.14}
	}
}
list.Set( "simfphys_vehicles", "t80", V )
