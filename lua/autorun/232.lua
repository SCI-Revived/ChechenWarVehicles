local V = {
	Name = "ZU-23-2",
	Model = "models/zsu23.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "SIMER Cold War",
	SpawnOffset = Vector(0,0,50),

	Members = {
		Mass = 3000,
		
		MaxHealth = 1000,
		
		IsArmored = true,
		
		GibModels = {
			"models/zsu23.mdl",
		},
		
		EnginePos = Vector(0,78,-500),
		
		LightsTable = "",
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		CustomWheelPosFL = Vector(20,20,25),
		CustomWheelPosFR = Vector(-20,20,25),
		CustomWheelPosRL = Vector(20,-20,25),
		CustomWheelPosRR = Vector(-20,-20,25),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-19,-17,50),
		SeatPitch = -20,
		SeatYaw = 0,
		
			ExhaustPositions = {
	

	
		},
		
		PassengerSeats = {
			{
				pos = Vector(20,-23,11),
				ang = Angle(0,0,20)
			},
		
			
		},
		
			
		
		FrontHeight = 20,
		FrontConstant = 50000,
		FrontDamping = 50000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 20,
		RearConstant = 50000,
		RearDamping = 50000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 10,
		
		FastSteeringAngle = 1000,
		SteeringFadeFastSpeed = 535,

		
		MaxGrip = 70,
		Efficiency = 1.0,
		GripOffset = -2,
		BrakePower = 80,
		
		IdleRPM = 650,
		LimitRPM = 5000,
		PeakTorque = 100,
		Revlimiter = false,
		PowerbandStart = 650,
		PowerbandEnd = 4700,
		Turbocharged = false,

		FuelFillPos = Vector(-34,0,72),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 90,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "",
		Sound_MidPitch = 1.3,
		Sound_MidVolume = 0.75,
		Sound_MidFadeOutRPMpercent = 50,
		Sound_MidFadeOutRate = 0.85,
		
		Sound_High = "",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 20,
		Sound_HighFadeInRate = 0.2,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.05,0.08,0.11,0.14}
	}
}
list.Set( "simfphys_vehicles", "232", V )



                         