
local light_table = {
	L_HeadLampPos = Vector(-45,65,52),Vector(-58,140,53.5),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(43,65,52),Vector(58,140,53.5),
	R_HeadLampAng = Angle(15,90,0),
	
	Headlight_sprites = { 
		Vector(-45,65,52),
		Vector(43,65,52),
	},
	
}
list.Set( "simfphys_lights", "bm2", light_table)

local V = {
	Name = "BMD-2K",
	Model = "models/bm2.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "SIMER Cold War",
	SpawnOffset = Vector(0,0,30),
	SpawnAngleOffset = -90,

	Members = {
		Mass = 8000,
		AirFriction = 0,
		Inertia = Vector(10000,30000,50000),
		
		LightsTable = "bm2",
		
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
		
		MaxHealth =5000,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,-50,50),
		
		FrontWheelRadius = 29,
		RearWheelRadius = 29,
		
		EnginePos = Vector(0,-95.72,69.45),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		--CustomWheelModel = "models/props_vehicles/apc_tire001.mdl",
		
		CustomWheelPosFL = Vector(-35,100,35),
		CustomWheelPosFR = Vector(35,100,35),
		CustomWheelPosML = Vector(-45,0,35),
		CustomWheelPosMR = Vector(45,0,35),
		CustomWheelPosRL = Vector(-45,-100,35),
		CustomWheelPosRR = Vector(45,-100,35),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,8),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(0,0,70),
		SeatPitch = -15,
		SeatYaw = 0,
			SeatAnim = "pose_ducking_02",
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-35,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-35,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-35,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-28,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-28,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(-28,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(35,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(35,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(35,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(28,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(28,-100,37),
				ang = Angle(90,-90,90)
			},
			{
				pos = Vector(28,-100,37),
				ang = Angle(90,-90,90)
			},
			
		},

		
		PassengerSeats = {
			{
				pos = Vector(0,0,15),
				ang = Angle(0,0,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(0,0,15),
				ang = Angle(0,0,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(0,0,15),
				ang = Angle(0,0,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(0,0,15),
				ang = Angle(0,0,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(0,0,15),
				ang = Angle(0,0,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(0,0,15),
				ang = Angle(0,0,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(-35,-30,47),
				ang = Angle(0,90,0),
				
			},
			{
				pos = Vector(-35,-60,47),
				ang = Angle(0,90,0),
				
			},
			{
				pos = Vector(30,-30,47),
				ang = Angle(0,-90,0),
				
			},
			{
				pos = Vector(30,-60,47),
				ang = Angle(0,-90,0),
				
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
		Efficiency = 0.85,
		GripOffset = -300,
		BrakePower = 100,
		BulletProofTires = true,
		
		IdleRPM = 650,
		LimitRPM = 4500,
		PeakTorque = 200,
		PowerbandStart = 650,
		PowerbandEnd = 3500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-46.03,-34.64,75.23),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 160,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "simulated_vehicles/t90ms/idle.wav",
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
list.Set( "simfphys_vehicles", "bm2", V )
