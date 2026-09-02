--[[==========================================================================
	Chechen War Vehicles  --  per-weapon prop-damage multiplier

	WHY
	---
	These vehicles are balanced against each other. A shell tuned to be fair
	against another tank instantly deletes anything a player built once Simple
	Prop Damage gives props health. This lets each weapon scale the damage it
	does *to props only* - its damage to vehicles, players and NPCs is untouched.

	HOW TO USE
	----------
	In a weapon's fire function (lua/simfphys_weapons/<name>.lua) add ONE line to
	the `projectile` table, anywhere before the simfphys.Fire* call:

		projectile.SPD_PropDamageMultiplier = 0.1

		1   = unchanged (also the default when the line is absent)
		0   = this weapon does no damage to props at all
		0.1 = props take 10% of this weapon's damage
		2   = props take 200% (harder on props than on vehicles)

	The number covers the direct hit AND the shell's blast. Blast still falls off
	with distance exactly as before, so a prop at the edge of the radius takes
	roughly  BlastDamage * multiplier * (distance falloff).

	For the BMP-1 wire-guided missile (an entity, not a projectile table) the
	line is already wired in lua/simfphys_weapons/bm.lua via
	CWV_SetPropDamageMultiplier( vehicle.missile, n ).

	WHY IT DOES NOT CONFLICT WITH OTHER ADDONS
	-----------------------------------------
	* `projectile.SPD_PropDamageMultiplier` is a key on a plain Lua table this
	  pack owns. It is never written onto an entity, so nothing else reads it.
	* The multiplier is applied once, inside a frame-scoped window opened around
	  the exact FireBullets call that deals the damage. We never tag entities with
	  `SPD_PropDamageMultiplier`, so Simple Prop Damage's own LVS layer (which
	  blindly scales by that entity field) never sees our shots - the multiplier
	  can't be applied twice.
	* Only prop_physics damage is ever touched, through SPD's public
	  SPD_PreEntityTakeDamage hook.

	ConVars:
		cwv_propdmg_enabled 1   master toggle
		cwv_propdmg_debug   0   log every prop hit and the multiplier resolved
========================================================================== ]]

if not SERVER then return end

CWV_PropDamage = CWV_PropDamage or {}
local S = CWV_PropDamage          -- shared state, survives lua_openscript / autorefresh
S.window = S.window or nil        -- { mult = number, frame = number } | nil
S.pendingShellTag = S.pendingShellTag or nil

local FIELD = "CWV_PropDmgMult"   -- private tag, deliberately NOT SPD_PropDamageMultiplier

local cv_enabled = CreateConVar( "cwv_propdmg_enabled", "1", FCVAR_ARCHIVE,
	"Chechen War Vehicles: scale weapon damage dealt to props. 0 = off (props take full damage)." )
local cv_debug = CreateConVar( "cwv_propdmg_debug", "0", FCVAR_ARCHIVE,
	"Chechen War Vehicles: print each prop hit and the prop-damage multiplier resolved for it." )

local function scales( n )       -- true when this multiplier changes anything
	return isnumber( n ) and n ~= 1
end

--------------------------------------------------------------------------------
-- The only place damage is rescaled. SPD calls this for prop_physics only, on
-- the prop-damage path only, with a DamageInfo private to that one victim - so
-- scaling here can never reach the same shot's damage to a vehicle or player.
--------------------------------------------------------------------------------

hook.Add( "SPD_PreEntityTakeDamage", "CWV_PropDamage", function( prop, propTbl, dmg )
	if not cv_enabled:GetBool() then return end

	local mult, why

	local w = S.window
	if w and w.frame == FrameNumber() then
		mult, why = w.mult, "shot window"
	else
		local inf = dmg:GetInflictor() -- fallback: tagged inflictor, damage dealt outside FireBullets
		if IsValid( inf ) and isnumber( inf[ FIELD ] ) then
			mult, why = inf[ FIELD ], "tagged inflictor"
		end
	end

	if cv_debug:GetBool() then
		local inf = dmg:GetInflictor()
		MsgN( string.format( "[CWV PropDmg] %s takes %.0f (inflictor %s) -> %s",
			tostring( prop ), dmg:GetDamage(),
			IsValid( inf ) and inf:GetClass() or "world",
			mult and ( "x" .. mult .. " [" .. why .. "]" ) or "not a CWV shot, unchanged" ) )
	end

	if not isnumber( mult ) or not scales( mult ) then return end

	dmg:ScaleDamage( math.max( mult, 0 ) )
end )

--------------------------------------------------------------------------------
-- Entity:FireBullets detour.
--
-- Tank shells (simfphys_tankprojectile) and the ATGM deal their damage by
-- calling self:FireBullets() at the moment of impact - both the direct hit and
-- the util.BlastDamage fired from inside the bullet callback happen synchronously
-- inside that one call, so a window around it covers both. Guarded to entities
-- we tagged, so it is inert for every other FireBullets call on the server.
--------------------------------------------------------------------------------

local ENT_META = FindMetaTable( "Entity" )
ENT_META.CWV_BaseFireBullets = ENT_META.CWV_BaseFireBullets or ENT_META.FireBullets

function ENT_META:FireBullets( ... )
	local m = self[ FIELD ]
	if not isnumber( m ) or m == 1 then
		return ENT_META.CWV_BaseFireBullets( self, ... )
	end

	local prev = S.window
	S.window = { mult = m, frame = FrameNumber() }
	local ok, a, b = pcall( ENT_META.CWV_BaseFireBullets, self, ... )
	S.window = prev
	if not ok then ErrorNoHaltWithStack( a ) end
	return a, b
end

--------------------------------------------------------------------------------
-- Tag a shell with its multiplier the instant it is created. OnEntityCreated
-- fires synchronously inside ents.Create() within simfphys.FirePhysProjectile,
-- so the tag is set before the shell can travel or detonate.
--------------------------------------------------------------------------------

hook.Add( "OnEntityCreated", "CWV_PropDamage_TagShell", function( ent )
	if S.pendingShellTag == nil then return end
	if ent:GetClass() ~= "simfphys_tankprojectile" then return end
	ent[ FIELD ] = S.pendingShellTag
end )

--------------------------------------------------------------------------------
-- Detour this pack's fire entry points so they read
-- projectile.SPD_PropDamageMultiplier off the fire table:
--   * FireHitScan        - hitscan MGs / autocannons. The base calls
--                          vehicle:FireBullets synchronously, so a window around
--                          the whole call is enough (the vehicle is never tagged).
--   * FirePhysProjectile - spawns the shell; we arm pendingShellTag so the
--                          OnEntityCreated hook above stamps the new shell.
--
-- simfphys re-defines these from several places (its base, this pack's bundled
-- copy, a self-repair timer at ~18s), so we re-install on a few events and
-- guard against wrapping our own wrapper.
--------------------------------------------------------------------------------

local myHitScan, myPhysProj

local function installDetours()
	if not istable( simfphys ) then return end

	if isfunction( simfphys.FireHitScan ) and simfphys.FireHitScan ~= myHitScan then
		local base = simfphys.FireHitScan
		myHitScan = function( data )
			local m = istable( data ) and data.SPD_PropDamageMultiplier or nil
			if not isnumber( m ) or m == 1 then return base( data ) end

			local prev = S.window
			S.window = { mult = m, frame = FrameNumber() }
			local ok, err = pcall( base, data )
			S.window = prev
			if not ok then ErrorNoHaltWithStack( err ) end
		end
		simfphys.FireHitScan = myHitScan
	end

	if isfunction( simfphys.FirePhysProjectile ) and simfphys.FirePhysProjectile ~= myPhysProj then
		local base = simfphys.FirePhysProjectile
		myPhysProj = function( data )
			local m = istable( data ) and data.SPD_PropDamageMultiplier or nil
			if not isnumber( m ) or m == 1 then return base( data ) end

			S.pendingShellTag = m
			local ok, err = pcall( base, data )
			S.pendingShellTag = nil
			if not ok then ErrorNoHaltWithStack( err ) end
		end
		simfphys.FirePhysProjectile = myPhysProj
	end
end

hook.Add( "Initialize",     "CWV_PropDamage_Detours", installDetours )
hook.Add( "InitPostEntity", "CWV_PropDamage_Detours", installDetours )
timer.Simple( 0,  installDetours )
timer.Simple( 20, installDetours ) -- after simfphys' ~18s self-repair timer
installDetours()

--------------------------------------------------------------------------------
-- Public helper for entity weapons (e.g. the BMP-1 missile in
-- lua/entities/arctic_avx_atgm) that don't pass through a `projectile` table.
--------------------------------------------------------------------------------

function CWV_SetPropDamageMultiplier( ent, n )
	if IsValid( ent ) and isnumber( n ) then
		ent[ FIELD ] = n
		return true
	end
	return false
end
