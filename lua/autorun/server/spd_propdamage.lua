--[[--------------------------------------------------------------------------
	Chechen War Vehicles  <->  Simple Prop Damage  -  per-vehicle prop scaling

	THE PROBLEM
	-----------
	The vehicles in this pack are balanced against each other. A cannon round
	tuned to be fair against another tank will vaporise anything a player built.
	Simple Prop Damage (SPD) gives props health, but every shell still lands on
	them with its full anti-vehicle damage.

	WHAT THIS FILE DOES
	-------------------
	It re-scales a vehicle's weapon damage *only at the moment it lands on a
	prop_physics*. Vehicle-vs-vehicle and vehicle-vs-player combat is never
	touched - that damage never routes through the prop_physics EntityTakeDamage
	path SPD listens on, and this file only acts inside SPD's own
	SPD_PreEntityTakeDamage extension point.

	The scale factor is resolved per hit as:

		final = perVehicleMultiplier  *  cwv_spd_propdamage_mult (convar)

	1  = unchanged, 0 = this vehicle cannot hurt props at all,
	>1 = hits props harder than it hits vehicles.

	HOW TO TUNE  (this is the whole point - every vehicle individually)
	-----------------------------------------------------------------
	Edit the CWV_PropDamage.Multipliers table below. The key is the vehicle's
	simfphys spawn-list name (the string returned by that weapon's
	ValidClasses()), the value is its multiplier. Anything not listed uses
	CWV_PropDamage.Default.

	Live, without a map change:
		cwv_spd_propdamage_enabled 1      -- master toggle
		cwv_spd_propdamage_mult    1      -- global multiplier stacked on top
		lua_run CWV_PropDamage.Multipliers.t62 = 0.05

	Per-weapon override (optional, finer than per-vehicle): set
		projectile.SPD_PropDamageMultiplier = <n>
	on the projectile table in that weapon's fire function in
	lua/simfphys_weapons/<name>.lua, before the simfphys.Fire* call. When set it
	replaces the per-vehicle number for that one weapon.

	Server-wide last word:
		hook.Add( "SPD_CWVPropDamageMultiplier", "id",
			function( propEnt, dmginfo, multiplier ) return <number or nil> end )
----------------------------------------------------------------------------]]

if not SERVER then return end

CWV_PropDamage = CWV_PropDamage or {}

--------------------------------------------------------------------------------
-- TUNING TABLE  -  key = simfphys spawn-list name, value = prop-damage multiplier
--------------------------------------------------------------------------------

CWV_PropDamage.Default = 0.15

CWV_PropDamage.Multipliers = CWV_PropDamage.Multipliers or {
	t62   = 0.57142857142,  -- T-62, about 2285 prop damage per shot.
	t80   = 0.666,  -- T-80U, about 3333 prop damage per shot.
	t72b  = 0.614,  -- T-72B, about 2763 prop damage per shot
	bm2   = 0.2,  -- BMD-2, it's an autocannon, it's barely damaging anything.
	bm3   = 0.20,  -- BMP-3, 
	bm1   = 0.20,  -- BMP-1 (bm.lua)
	c21   = 0.10,  -- 2S1 Gvozdika
	bm21  = 0.27,  -- BM-21 Grad, 405 prop damage PER rocket.
	["232"] = 1, -- 2S3 Akatsiya, full damage, you should use this to siege bases from range.
	mt1   = 0.6,  -- MT-LB (mtlb_v.lua)
	mt2   = 0.0,  -- MT-LB variant (mtlb.lua)
	gaz66 = 0.1,  -- GAZ-66 (ZU-23 truck)
}

--------------------------------------------------------------------------------
-- ConVars
--------------------------------------------------------------------------------

local cv_enabled = CreateConVar( "cwv_spd_propdamage_enabled", "1", FCVAR_ARCHIVE,
	"Scale Chechen War Vehicles weapon damage when it lands on a prop (needs Simple Prop Damage). 0 = off." )

local cv_mult = CreateConVar( "cwv_spd_propdamage_mult", "1", FCVAR_ARCHIVE,
	"Global multiplier stacked on top of every per-vehicle prop-damage multiplier. 1 = unchanged." )

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Final multiplier for a shot fired by `vehicle`. `override` (a number, usually
-- projectile.SPD_PropDamageMultiplier) replaces the per-vehicle value when given.
function CWV_PropDamage.Resolve( vehicle, override )
	local base
	if isnumber( override ) then
		base = override
	elseif IsValid( vehicle ) and isfunction( vehicle.GetSpawn_List ) then
		local name = vehicle:GetSpawn_List()
		base = CWV_PropDamage.Multipliers[ name ]
	end
	base = base or CWV_PropDamage.Default
	return base * cv_mult:GetFloat()
end

function CWV_PropDamage.SetVehicleMultiplier( ent, n )
	if not IsValid( ent ) then return false end
	if not isnumber( n ) then return false end
	ent.SPD_PropDamageMultiplier = n
	return true
end

--------------------------------------------------------------------------------
-- Shared state
--
-- simfphys.FireHitScan runs FireBullets synchronously, so the hit + damage land
-- inside the same call. We stamp with FrameNumber() so a stale value from a shot
-- that hit only the world can never be picked up on a later frame.
--------------------------------------------------------------------------------

local pendingHitScan   -- { m = number, f = frame } | nil
local pendingProjTag   -- number | nil : multiplier to stamp on the next simfphys_tankprojectile

local PROP_CLASS = "prop_physics"

--------------------------------------------------------------------------------
-- SPD hook: the only place damage is actually rescaled. SPD calls this for
-- prop_physics only, and only ever on the prop-damage code path - so scaling
-- here cannot touch vehicle or player damage.
--------------------------------------------------------------------------------

local DMG_WEAPONISH = bit.bor( DMG_BULLET, DMG_BLAST, DMG_AIRBOAT, DMG_BUCKSHOT, DMG_SLASH )

hook.Add( "SPD_PreEntityTakeDamage", "CWV_SPD_PropDamage", function( propEnt, propTable, dmg )
	if not cv_enabled:GetBool() then return end

	local mult

	if pendingHitScan and pendingHitScan.f == FrameNumber() then
		mult = pendingHitScan.m
	else
		local inflictor = dmg:GetInflictor()
		if IsValid( inflictor ) and isnumber( inflictor.SPD_PropDamageMultiplier ) then
			mult = inflictor.SPD_PropDamageMultiplier
		else
			local attacker = dmg:GetAttacker()
			if IsValid( attacker ) and isnumber( attacker.SPD_PropDamageMultiplier )
				and dmg:IsDamageType( DMG_WEAPONISH ) then
				mult = attacker.SPD_PropDamageMultiplier
			end
		end
	end

	if mult == nil then return end

	local override = hook.Run( "SPD_CWVPropDamageMultiplier", propEnt, dmg, mult )
	if isnumber( override ) then mult = override end

	if mult == 1 then return end
	dmg:ScaleDamage( math.max( mult, 0 ) )
end )

--------------------------------------------------------------------------------
-- Detours on this pack's own simfphys.FireHitScan / simfphys.FirePhysProjectile.
--
-- Those two functions are (re)defined by every file in lua/autorun/server/, so
-- we (re)install after all of them have run - on Initialize and again on
-- InitPostEntity - and guard against wrapping our own wrapper.
--------------------------------------------------------------------------------

local myHitScan, myPhysProj -- identities of the wrappers we installed

local function installDetours()
	if not istable( simfphys ) then return end

	-- FireHitScan: was reassigned by a pack file since we last wrapped it, so
	-- wrap whatever is current (unless it is already our wrapper).
	if isfunction( simfphys.FireHitScan ) and simfphys.FireHitScan ~= myHitScan then
		local inner = simfphys.FireHitScan

		myHitScan = function( data )
			if istable( data ) and IsValid( data.attackingent ) then
				local m = CWV_PropDamage.Resolve( data.attackingent, data.SPD_PropDamageMultiplier )
				data.attackingent.SPD_PropDamageMultiplier = m
				pendingHitScan = { m = m, f = FrameNumber() }
				local ok, err = pcall( inner, data )
				pendingHitScan = nil
				if not ok then ErrorNoHaltWithStack( err ) end
				return
			end
			return inner( data )
		end

		simfphys.FireHitScan = myHitScan
	end

	if isfunction( simfphys.FirePhysProjectile ) and simfphys.FirePhysProjectile ~= myPhysProj then
		local inner = simfphys.FirePhysProjectile

		myPhysProj = function( data )
			if istable( data ) and IsValid( data.attackingent ) then
				local m = CWV_PropDamage.Resolve( data.attackingent, data.SPD_PropDamageMultiplier )
				data.attackingent.SPD_PropDamageMultiplier = m
				pendingProjTag = m
				local ok, err = pcall( inner, data )
				pendingProjTag = nil
				if not ok then ErrorNoHaltWithStack( err ) end
				return
			end
			return inner( data )
		end

		simfphys.FirePhysProjectile = myPhysProj
	end
end

hook.Add( "Initialize",      "CWV_SPD_PropDamage_Detours", installDetours )
hook.Add( "InitPostEntity",  "CWV_SPD_PropDamage_Detours", installDetours )
installDetours() -- autorefresh / hot reload

-- Stamp the multiplier onto the shell entity the instant it is created, before
-- it can possibly detonate (point-blank shots detonate the same tick).
hook.Add( "OnEntityCreated", "CWV_SPD_PropDamage_TagProjectile", function( ent )
	if pendingProjTag == nil then return end
	if ent:GetClass() ~= "simfphys_tankprojectile" then return end
	ent.SPD_PropDamageMultiplier = pendingProjTag
end )
