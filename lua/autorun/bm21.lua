local V = {
	Name = "BM-21 GRAD",
	Model = "models/bm21.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "SIMER Cold War",
	SpawnOffset = Vector(0,0,50),

	Members = {
		Mass = 4800,
		
		MaxHealth = 1800,
		
		IsArmored = true,
		
		GibModels = {
			"models/bm21.mdl",
		},
		
		EnginePos = Vector(0,98,60),
		
		LightsTable = "bm21",
		
		OnSpawn = 
			function(ent) 
				ent:SetNWBool( "simfphys_NoRacingHud", true )
				ent:SetNWBool( "simfphys_NoHud", true ) 
			end,
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/Swhel.mdl",
		CustomWheelPosFL = Vector(-45,90,3),
		CustomWheelPosFR = Vector(45,90,3),
		CustomWheelPosRL = Vector(-45,-50,5),
		CustomWheelPosRR = Vector(45,-50,5),
		CustomWheelPosML = Vector(-45,-110,5),
        CustomWheelPosMR = Vector(45,-110,5),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(40,-15,55),
		SeatPitch = 0,
		SeatYaw = 0,
		
			ExhaustPositions = {
			
	

	
		},
		
		PassengerSeats = {
			{
				pos = Vector(10,50,25),
				ang = Angle(0,0,0)
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

		FuelFillPos = Vector(-60,30,40),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 90,

		
		PowerBias = 0,5,
		
		EngineSoundPreset = -1, 

        snd_pitch = 1,
		snd_idle = "vehicles/crane/crane_startengine1.wav",
		
		snd_low ="simulated_vehicles/alfaromeo/alfaromeo_low.wav",
		snd_low_pitch = 0.35,
		
		snd_mid = "simulated_vehicles/alfaromeo/alfaromeo_mid.wav",
		snd_mid_gearup = "simulated_vehicles/alfaromeo/alfaromeo_second.wav",
		snd_mid_pitch = 0.5,

		
		DifferentialGear = 0.8,
		Gears = {-0.12,0,0.06,0.12,0.21,0.32,0.42}
	}
}
list.Set( "simfphys_vehicles", "bm21", V )


local light_table = {

   L_HeadLampPos = Vector(50,90,0),
	L_HeadLampAng = Angle(0,90,0),

	
	
	Headlight_sprites = {
		Vector(-33,133,27),
		Vector(-33,133,27),
		Vector(33,133,27),
		Vector(33,133,27),
	},	

}
list.Set( "simfphys_lights", "bm21", light_table)
                         