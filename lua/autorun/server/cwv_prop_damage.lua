--[[--------------------------------------------------------------------------
	Chechen War Vehicles  --  Prop Damage Multiplier system
	--------------------------------------------------------------------------

	WHY THIS EXISTS
	--------------------------------------------------------------------------
	CWV weapons are balanced to fight tanks (LVS, other simfphys packs, etc).
	That same damage, dumped into a build prop, deletes anything a player made.
	This lets every weapon carry its own "vs prop" multiplier, exactly like
	LVS' `bullet.SPD_PropDamageMultiplier`, so a cannon can stay lethal to
	armour while barely scratching props -- tuned per weapon, by hand.

	HOW TO USE IT  (one line, in a weapon's fire function)
	--------------------------------------------------------------------------
	Hitscan / autocannon / MG  (simfphys.FireHitScan) and
	shells / rockets           (simfphys.FirePhysProjectile):

		local projectile = {}
			projectile.filter         = vehicle.VehicleData["filter"]
			projectile.shootOrigin    = shootOrigin
			projectile.shootDirection = shootDirection
			projectile.attacker       = ply
			projectile.attackingent   = vehicle
			projectile.Damage         = 3500
			projectile.BlastDamage    = 500

			projectile.CWV_PropDamageMultiplier = 0.05   -- <-- THIS. 0.05 = 5% vs props

		simfphys.FirePhysProjectile( projectile )

	Missile ENTITIES you spawn yourself (e.g. arctic_avx_atgm):

		vehicle.missile = ents.Create( "arctic_avx_atgm" )
		...
		vehicle.missile:Spawn()
		vehicle.missile.CWV_PropDamageMultiplier = 0.1      -- field, or...
		CWV_PropDamage.SetPropDamageMultiplier( vehicle.missile, 0.1 )   -- ...helper

	MEANING OF THE NUMBER
		1   = unchanged (default -- weapons that set nothing are never touched)
		0   = this weapon cannot hurt props at all
		0.05= 5% of its normal damage lands on props
		>1  = hits props HARDER than vehicles (rarely wanted)

	SERVER CONVARS
		cwv_propdamage_enabled     1   master switch for this whole system
		cwv_propdamage_multiplier  1   fallback multiplier for CWV weapons that
		                               don't set their own. 1 = leave them alone.

	SERVER-WIDE OVERRIDE HOOK
		hook.Add( "CWV_PropDamageMultiplier", "MyServer",
			function( propEnt, propTable, dmginfo, multiplier )
				-- return a number to replace `multiplier` for this hit
			end )

	--------------------------------------------------------------------------
	CONFLICT SAFETY  (read the memory note cwv-simfphys-shell-damage)
	--------------------------------------------------------------------------
	* Everything here is namespaced `CWV_` / `cwv_` -- no shared names with
	  Simple Prop Damage, LVS, M9K, GBombs-5.
	* The multiplier is applied in exactly ONE place (a single dmg:ScaleDamage
	  call), gated by a per-frame "window" that only opens while a CWV weapon
	  is dealing damage. Non-CWV damage to props is never seen by this system.
	* We do NOT set `SPD_PropDamageMultiplier` on any entity. SPD's own
	  lvs.lua scales by that field with no LVS guard, so reusing it would
	  double-apply (m^2). That is deliberately avoided.
	* The detours on simfphys.FireHitScan / simfphys.FirePhysProjectile /
	  Entity:FireBullets / util.BlastDamage are transparent pass-throughs
	  unless a CWV tag is present, and are re-installed on a timer because the
	  vehicle pack rewrites the simfphys functions from inline copies and the
	  base has an ~18s self-repair.
----------------------------------------------------------------------------]]

if not SERVER then return end

CWV_PropDamage = CWV_PropDamage or {}
local M = CWV_PropDamage

--------------------------------------------------------------------------------
-- ConVars
--------------------------------------------------------------------------------

if not ConVarExists( "cwv_propdamage_enabled" ) then
	CreateConVar( "cwv_propdamage_enabled", "1", FCVAR_ARCHIVE,
		"Master switch for the Chechen War Vehicles prop-damage multiplier system." )
end

if not ConVarExists( "cwv_propdamage_multiplier" ) then
	CreateConVar( "cwv_propdamage_multiplier", "1", FCVAR_ARCHIVE,
		"Fallback vs-prop damage multiplier for CWV weapons that do not set their own CWV_PropDamageMultiplier. 1 = unchanged." )
end

local cvEnabled 	= GetConVar( "cwv_propdamage_enabled" )
local cvFallback 	= GetConVar( "cwv_propdamage_multiplier" )

local FIELD 		= "CWV_PropDamageMultiplier" 	-- public, set by weapon authors
local PROP_CLASS 	= "prop_physics" 				-- the only class SPD / we scale

--------------------------------------------------------------------------------
-- The damage "window"
--
-- Opened around a CWV weapon's synchronous damage call, stamped with the frame
-- it was opened on. The damage hook only acts while a window for the current
-- frame is open, so nothing else on the server is ever affected.
--------------------------------------------------------------------------------

local g_window 		-- { m = number, f = frame } | nil

local function OpenWindow( mult )
	local prev = g_window
	g_window = { m = mult, f = FrameNumber() }
	return prev
end

local function RestoreWindow( prev )
	g_window = prev
end

-- Public: lets the arctic_avx_atgm entity (and any custom projectile) bracket
-- its own damage without reaching into this file's locals.
function M.OpenWindow( mult )
	if not isnumber( mult ) then return end
	return OpenWindow( mult )
end

function M.CloseWindow( prev )
	g_window = prev -- prev is nil in the common (non-nested) case
end

function M.SetPropDamageMultiplier( ent, mult )
	if not IsValid( ent ) or not isnumber( mult ) then return false end
	ent[ FIELD ] = mult
	return true
end

function M.GetPropDamageMultiplier( ent )
	if not IsValid( ent ) then return end
	return ent[ FIELD ]
end

-- Resolve the multiplier a weapon table / entity asks for, honouring the
-- fallback convar. Returns nil when nothing should be scaled.
local function ResolveMultiplier( explicit )
	if isnumber( explicit ) then return explicit end

	local fb = cvFallback:GetFloat()
	if fb ~= 1 then return fb end

	return nil
end

--------------------------------------------------------------------------------
-- The one and only place damage is scaled
--------------------------------------------------------------------------------

local function ApplyScaling( propEnt, propTable, dmginfo )
	if not cvEnabled:GetBool() then return end

	local w = g_window
	if not w or w.f ~= FrameNumber() then return end

	local m = w.m

	local override = hook.Run( "CWV_PropDamageMultiplier", propEnt, propTable, dmginfo, m )
	if isnumber( override ) then m = override end

	if m == 1 then return end

	dmginfo:ScaleDamage( math.max( m, 0 ) )
end

-- Preferred path: Simple Prop Damage's sanctioned pre-hook, which runs before
-- SPD reads the damage value, so our scaling is reflected in the prop's health.
hook.Add( "SPD_PreEntityTakeDamage", "CWV_PropDamageScale", function( ent, entTable, dmginfo )
	ApplyScaling( ent, entTable, dmginfo )
	-- never return a value -- other SPD extensions must keep running
end )

-- Fallback path: only registered if Simple Prop Damage is not installed, so the
-- system still does something on servers without SPD. Guarded so it can never
-- run alongside the SPD hook above (no double scaling).
local function InstallFallbackDamageHook()
	if ConVarExists( "spd_enabled" ) then return end 	-- SPD present -> use its hook
	if M._fallbackHook then return end
	M._fallbackHook = true

	hook.Add( "EntityTakeDamage", "CWV_PropDamageScale_Fallback", function( ent, dmginfo )
		if not IsValid( ent ) or ent:GetClass() ~= PROP_CLASS then return end
		ApplyScaling( ent, ent:GetTable(), dmginfo )
	end )
end

--------------------------------------------------------------------------------
-- Detours -- transparent unless a CWV tag is in play
--------------------------------------------------------------------------------

-- Entity:FireBullets : catches direct hits from any CWV-tagged entity
-- (simfphys_tankprojectile shell, arctic_avx_atgm missile, ...). Untagged
-- entities (every other gun on the server) fall straight through.
local function InstallFireBulletsDetour()
	if M._fireBulletsDetoured then return end
	M._fireBulletsDetoured = true

	local ENT_META = FindMetaTable( "Entity" )
	local realFireBullets = ENT_META.FireBullets
	M._realFireBullets = realFireBullets

	function ENT_META:FireBullets( data, suppressHostEvents )
		local m = self[ FIELD ]
		if not isnumber( m ) then
			return realFireBullets( self, data, suppressHostEvents )
		end

		local prev = OpenWindow( m )
		local ok, err = pcall( realFireBullets, self, data, suppressHostEvents )
		RestoreWindow( prev )
		if not ok then ErrorNoHaltWithStack( err ) end
	end
end

-- util.BlastDamage : catches splash from CWV shells / missiles. It is called
-- with the vehicle or the missile as inflictor; we act on a CWV tag on either
-- inflictor or attacker, or when a CWV window is already open this frame
-- (shell splash fires from inside the shell's think, which we bracket).
local function InstallBlastDamageDetour()
	if M._blastDetoured then return end
	M._blastDetoured = true

	local realBlastDamage = util.BlastDamage
	M._realBlastDamage = realBlastDamage

	function util.BlastDamage( inflictor, attacker, pos, radius, damage )
		local m

		if IsValid( inflictor ) and isnumber( inflictor[ FIELD ] ) then
			m = inflictor[ FIELD ]
		elseif IsValid( attacker ) and isnumber( attacker[ FIELD ] ) then
			m = attacker[ FIELD ]
		elseif g_window and g_window.f == FrameNumber() then
			m = g_window.m
		end

		if not isnumber( m ) then
			return realBlastDamage( inflictor, attacker, pos, radius, damage )
		end

		local prev = OpenWindow( m )
		local ok, err = pcall( realBlastDamage, inflictor, attacker, pos, radius, damage )
		RestoreWindow( prev )
		if not ok then ErrorNoHaltWithStack( err ) end
	end
end

-- simfphys.FireHitScan : the plain `projectile` table never becomes an entity,
-- so we read the field here and open a window around the synchronous
-- attackingent:FireBullets( bullet ) call it makes.
local function WrapFireHitScan( real )
	return function( data )
		local m = ResolveMultiplier( istable( data ) and data[ FIELD ] or nil )
		if not isnumber( m ) then return real( data ) end

		local prev = OpenWindow( m )
		local ok, err = pcall( real, data )
		RestoreWindow( prev )
		if not ok then ErrorNoHaltWithStack( err ) end
	end
end

-- simfphys.FirePhysProjectile : creates a `simfphys_tankprojectile` that deals
-- its damage frames later. We can't open a window now, so we tag the shell as
-- it is created (ents.Create is swapped only for the duration of this call,
-- never globally) and the shell's own damage is caught by the detours above.
local function WrapFirePhysProjectile( real )
	return function( data )
		local m = ResolveMultiplier( istable( data ) and data[ FIELD ] or nil )
		if not isnumber( m ) then return real( data ) end

		local realCreate = ents.Create
		ents.Create = function( class )
			local e = realCreate( class )
			if IsValid( e ) and class == "simfphys_tankprojectile" then
				e[ FIELD ] = m
			end
			return e
		end

		local ok, err = pcall( real, data )
		ents.Create = realCreate
		if not ok then ErrorNoHaltWithStack( err ) end
	end
end

-- The vehicle pack rewrites simfphys.FireHitScan / FirePhysProjectile from
-- inline copies in several autorun files, and the simfphys base re-installs
-- them ~18s after load. Re-wrap whenever we notice the current function is not
-- ours, capturing whatever is there now as the inner call.
local function ReinstallSimfphysDetours()
	if not istable( simfphys ) then return end

	if isfunction( simfphys.FireHitScan ) and simfphys.FireHitScan ~= M._wrappedFireHitScan then
		M._wrappedFireHitScan = WrapFireHitScan( simfphys.FireHitScan )
		simfphys.FireHitScan = M._wrappedFireHitScan
	end

	if isfunction( simfphys.FirePhysProjectile ) and simfphys.FirePhysProjectile ~= M._wrappedFirePhys then
		M._wrappedFirePhys = WrapFirePhysProjectile( simfphys.FirePhysProjectile )
		simfphys.FirePhysProjectile = M._wrappedFirePhys
	end
end

-- The simfphys_tankprojectile shell does its direct hit AND its splash from
-- inside its own think/collision. Bracket those entrypoints with a window so
-- both are covered even if a future base version changes how it deals damage.
local SHELL_ENTRYPOINTS = { "Think", "PhysicsCollide", "Touch", "StartTouch" }

local function WrapShellEntrypoints()
	local stored = scripted_ents.GetStored( "simfphys_tankprojectile" )
	if not stored or not stored.t then return end
	local t = stored.t
	if t.__cwvWrapped then return end
	t.__cwvWrapped = true

	for _, name in ipairs( SHELL_ENTRYPOINTS ) do
		local real = t[ name ]
		if isfunction( real ) then
			t[ name ] = function( selfEnt, ... )
				local m = selfEnt[ FIELD ]
				if not isnumber( m ) then return real( selfEnt, ... ) end

				local prev = OpenWindow( m )
				local a, b, c, d = real( selfEnt, ... )
				RestoreWindow( prev )
				return a, b, c, d
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Boot
--------------------------------------------------------------------------------

local function Boot()
	InstallFallbackDamageHook()
	InstallFireBulletsDetour()
	InstallBlastDamageDetour()
	ReinstallSimfphysDetours()
	WrapShellEntrypoints()
end

hook.Add( "InitPostEntity", "CWV_PropDamage_Boot", Boot )
-- also run now in case of lua auto-refresh after the server is already up
Boot()

-- Keep the simfphys detours alive through the pack's re-includes and the base's
-- self-repair. Two identity comparisons every few seconds -- negligible.
timer.Create( "CWV_PropDamage_Guard", 5, 0, function()
	ReinstallSimfphysDetours()
	WrapShellEntrypoints()
end )
