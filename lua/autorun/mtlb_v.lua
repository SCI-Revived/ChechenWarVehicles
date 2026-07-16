
local V = {
	Name = "MT-LB Vasiliek",
	Model = "models/mtlb.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "SIMER Cold War",
	SpawnOffset = Vector(0,0,60),
	SpawnAngleOffset = 0,

	Members = {
		Mass = 8000,
		AirFriction = 7,
		Inertia = Vector(10000,80000,100000),
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
			
		ApplyDamage = function( ent, damage, type ) 
			simfphys.TankApplyDamage(ent, damage, type)
		end,
		
		OnSpawn = function(ent) ent:SetNWBool( "simfphys_NoRacingHud", true ) end,
		
		MaxHealth = 4000,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		LightsTable = "mt1",
		
		FirstPersonViewPos = Vector(0,-50,15),
		
		FrontWheelRadius = 29,
		RearWheelRadius = 29,
		
		EnginePos = Vector(-79.66,0,50.21),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(115,40,35),
		CustomWheelPosFR = Vector(115,-40,35),
		CustomWheelPosML = Vector(-10,50,35),
		CustomWheelPosMR = Vector(-10,-50,35),
		CustomWheelPosRL = Vector(-120,40,35),
		CustomWheelPosRR = Vector(-120,-40,35),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,3),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(40,5,50),
		SeatAnim = "pose_ducking_02",
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
		

		
		PassengerSeats = {
			{
				pos = Vector(-90,-25,50),
				ang = Angle(0,-60,0),
				anim="pose_ducking_01"
			},
			{
				pos = Vector(-100,25,50),
				ang = Angle(0,-90,0),
				anim="pose_ducking_01"
			},
			{
				pos = Vector(-10,15,15),
				ang = Angle(0,-90,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(-30,15,15),
				ang = Angle(0,-90,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(-50,15,15),
				ang = Angle(0,-90,0),
				anim="pose_ducking_02"
			},
			{
				pos = Vector(-70,15,15),
				ang = Angle(0,-90,0),
				anim="pose_ducking_02"
			},
	
		},
		
		FrontHeight = 25,
		FrontConstant = 50000,
		FrontDamping = 5000,
		FrontRelativeDamping = 5000,
		
		RearHeight = 25,
		RearConstant = 50000,
		RearDamping = 5000,
		RearRelativeDamping = 5000,
		
		FastSteeringAngle = 20,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 6,
		
		MaxGrip = 800,
		Efficiency = 0.85,
		GripOffset = -300,
		BrakePower = 100,
		BulletProofTires = true,
		
		IdleRPM = 650,
		LimitRPM = 5000,
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
list.Set( "simfphys_vehicles", "mt1", V )


local light_table = {
	
	
	L_HeadLampPos = Vector(92,37.5,56),
	L_HeadLampAng = Angle(0,0,0),
	
	
	Headlight_sprites = {
		Vector(85.5,40,44),
		Vector(85.5,40,44),
		Vector(85.5,-40,44),
		Vector(85.5,-40,44),
		Vector(80.5,0,54),
		Vector(80.5,0,54),
	},	
	
}
list.Set( "simfphys_lights", "mt1", light_table)
                         